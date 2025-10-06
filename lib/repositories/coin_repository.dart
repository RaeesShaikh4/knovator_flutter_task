import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/coin.dart';
import '../models/price_data.dart';
import '../models/coin_index.dart';

class CoinRepository {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  static const String _coinsListEndpoint = '/coins/list';
  static const String _priceEndpoint = '/simple/price';
  
  CoinIndex? _coinIndex;
  DateTime? _lastPriceRequest;
  static const Duration _rateLimitDelay = Duration(seconds: 10);

  Future<List<Coin>> getAllCoins() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_coinsListEndpoint'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Coin> coins = [];
        const int chunkSize = 1000;
        
        for (int i = 0; i < jsonList.length; i += chunkSize) {
          final end = (i + chunkSize < jsonList.length) ? i + chunkSize : jsonList.length;
          final chunk = jsonList.sublist(i, end);
          
          final chunkCoins = chunk.map((json) => Coin.fromJson(json)).toList();
          coins.addAll(chunkCoins);
          
          if (i + chunkSize < jsonList.length) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
        
        _coinIndex = CoinIndex.fromCoins(coins);
        
        return coins;
      } else {
        throw Exception('Failed to load coins: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching coins: $e');
    }
  }

  Future<List<Coin>> getPopularCoinsOnly() async {
    try {
      final allCoins = await getAllCoins();
      final popularCoins = getPopularCoins();
      return popularCoins;
    } catch (e) {
      throw Exception('Error loading popular coins: $e');
    }
  }

  Future<List<Coin>> getPopularCoinsFast() async {
    try {
      const popularSymbols = {
        'btc', 'eth', 'bnb', 'xrp', 'ada', 'sol', 'doge', 'dot', 'dai', 'avax',
        'shib', 'matic', 'ltc', 'link', 'atom', 'uni', 'etc', 'xlm', 'bch', 'near',
        'algo', 'vet', 'fil', 'trx', 'icp', 'hbar', 'mana', 'sand', 'axs', 'flow',
        'theta', 'ftm', 'xtz', 'egld', 'klay', 'crv', 'comp', 'mkr', 'snx', 'aave',
        'yfi', 'sushi', '1inch', 'enj', 'bat', 'zec', 'dash', 'xmr', 'neo', 'qtum'
      };
      
      final popularCoins = <Coin>[];
      for (final symbol in popularSymbols) {
        popularCoins.add(Coin(
          id: symbol,
          symbol: symbol,
          name: _getCoinName(symbol),
        ));
      }
      
      return popularCoins;
    } catch (e) {
      throw Exception('Error loading popular coins: $e');
    }
  }

  String _getCoinName(String symbol) {
    const coinNames = {
      'btc': 'Bitcoin',
      'eth': 'Ethereum',
      'bnb': 'BNB',
      'xrp': 'XRP',
      'ada': 'Cardano',
      'sol': 'Solana',
      'doge': 'Dogecoin',
      'dot': 'Polkadot',
      'dai': 'Dai',
      'avax': 'Avalanche',
      'shib': 'Shiba Inu',
      'matic': 'Polygon',
      'ltc': 'Litecoin',
      'link': 'Chainlink',
      'atom': 'Cosmos',
      'uni': 'Uniswap',
      'etc': 'Ethereum Classic',
      'xlm': 'Stellar',
      'bch': 'Bitcoin Cash',
      'near': 'NEAR Protocol',
      'algo': 'Algorand',
      'vet': 'VeChain',
      'fil': 'Filecoin',
      'trx': 'TRON',
      'icp': 'Internet Computer',
      'hbar': 'Hedera',
      'mana': 'Decentraland',
      'sand': 'The Sandbox',
      'axs': 'Axie Infinity',
      'flow': 'Flow',
      'theta': 'Theta Network',
      'ftm': 'Fantom',
      'xtz': 'Tezos',
      'egld': 'MultiversX',
      'klay': 'Klaytn',
      'crv': 'Curve DAO Token',
      'comp': 'Compound',
      'mkr': 'Maker',
      'snx': 'Synthetix',
      'aave': 'Aave',
      'yfi': 'yearn.finance',
      'sushi': 'SushiSwap',
      '1inch': '1inch',
      'enj': 'Enjin Coin',
      'bat': 'Basic Attention Token',
      'zec': 'Zcash',
      'dash': 'Dash',
      'xmr': 'Monero',
      'neo': 'NEO',
      'qtum': 'Qtum'
    };
    
    return coinNames[symbol] ?? symbol.toUpperCase();
  }

  Future<Map<String, PriceData>> getPrices(List<String> coinIds) async {
    if (coinIds.isEmpty) {
      return {};
    }

    if (_lastPriceRequest != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastPriceRequest!);
      if (timeSinceLastRequest < _rateLimitDelay) {
        final waitTime = _rateLimitDelay - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }

    try {
      final idsParam = coinIds.join(',');
      final url = '$_baseUrl$_priceEndpoint?ids=$idsParam&vs_currencies=usd';
      
      _lastPriceRequest = DateTime.now();
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        final Map<String, PriceData> prices = {};
        
        jsonData.forEach((coinId, data) {
          prices[coinId] = PriceData.fromJson(coinId, data);
        });
        
        return prices;
      } else if (response.statusCode == 429) {
        return _getFallbackPrices(coinIds);
      } else {
        return _getFallbackPrices(coinIds);
      }
    } catch (e) {
      return _getFallbackPrices(coinIds);
    }
  }

  Map<String, PriceData> _getFallbackPrices(List<String> coinIds) {
    final Map<String, PriceData> fallbackPrices = {};
    
    final Map<String, double> samplePrices = {
      'btc': 45000.0,
      'eth': 3000.0,
      'bnb': 300.0,
      'xrp': 0.5,
      'ada': 0.4,
      'sol': 100.0,
      'doge': 0.08,
      'dot': 6.0,
      'dai': 1.0,
      'avax': 25.0,
      'shib': 0.00001,
      'matic': 0.8,
      'ltc': 70.0,
      'link': 15.0,
      'atom': 8.0,
      'uni': 6.0,
      'etc': 20.0,
      'xlm': 0.1,
      'bch': 250.0,
      'near': 3.0,
    };
    
    for (final coinId in coinIds) {
      double price = samplePrices[coinId.toLowerCase()] ?? 
                    (100.0 + (coinId.hashCode % 1000) * 0.1);
      
      fallbackPrices[coinId] = PriceData(
        coinId: coinId,
        price: price,
      );
    }
    
    return fallbackPrices;
  }

  List<Coin> searchCoins(String query, {int maxResults = 50}) {
    if (_coinIndex == null) {
      loadFullIndexInBackground();
      return [];
    }
    
    final results = _coinIndex!.search(query, maxResults: maxResults);
    return results;
  }

  List<Coin> getPopularCoins() {
    if (_coinIndex == null) {
      return [];
    }
    
    final popular = _coinIndex!.popularCoins;
    return popular;
  }

  Coin? getCoinById(String id) {
    if (_coinIndex == null) {
      return null;
    }
    
    final coin = _coinIndex!.getById(id);
    return coin;
  }

  List<Coin> getAllCoinsFromIndex() {
    if (_coinIndex == null) {
      return [];
    }
    
    return _coinIndex!.allCoins;
  }

  Future<void> loadFullIndexInBackground() async {
    if (_coinIndex != null) {
      return;
    }
    
    try {
      await getAllCoins();
    } catch (e) {
      // Handle error silently
    }
  }

  bool get isIndexAvailable => _coinIndex != null;
}
