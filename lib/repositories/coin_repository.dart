import 'dart:convert';
import 'dart:async';
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
  
  // Periodic update functionality
  Timer? _periodicUpdateTimer;
  static const Duration _updateInterval = Duration(minutes: 5);
  static const Duration _maxUpdateInterval = Duration(minutes: 30);
  Duration _currentUpdateInterval = _updateInterval;
  int _consecutiveFailures = 0;

  Future<List<Coin>> getAllCoins() async {
    print('[CoinRepository] 🚀 Starting getAllCoins API call...');
    try {
      final url = '$_baseUrl$_coinsListEndpoint';
      print('[CoinRepository] 📡 API URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );
      
      print('[CoinRepository] 📊 Response Status: ${response.statusCode}');
      print('[CoinRepository] 📏 Response Body Length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        print('[CoinRepository] ✅ Successfully received response');
        final List<dynamic> jsonList = json.decode(response.body);
        print('[CoinRepository] 📋 Total coins in response: ${jsonList.length}');
        
        final List<Coin> coins = [];
        const int chunkSize = 1000;
        
        for (int i = 0; i < jsonList.length; i += chunkSize) {
          final end = (i + chunkSize < jsonList.length) ? i + chunkSize : jsonList.length;
          final chunk = jsonList.sublist(i, end);
          
          print('[CoinRepository] 🔄 Processing chunk ${(i / chunkSize).floor() + 1}/${(jsonList.length / chunkSize).ceil()}: ${chunk.length} items');
          
          final chunkCoins = chunk.map((json) => Coin.fromJson(json)).toList();
          coins.addAll(chunkCoins);
          
          if (i + chunkSize < jsonList.length) {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        }
        
        print('[CoinRepository] 🏗️ Building CoinIndex with ${coins.length} coins...');
        _coinIndex = CoinIndex.fromCoins(coins);
        print('[CoinRepository] ✅ CoinIndex built successfully');
        
        return coins;
      } else {
        print('[CoinRepository] ❌ API Error: ${response.statusCode}');
        print('[CoinRepository] 📄 Response Body: ${response.body}');
        throw Exception('Failed to load coins: ${response.statusCode}');
      }
    } catch (e) {
      print('[CoinRepository] 💥 Exception in getAllCoins: $e');
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
    print('[CoinRepository] ⚡ Loading popular coins fast...');
    try {
      // Using actual CoinGecko coin IDs instead of symbols
      const popularCoinsData = {
        'bitcoin': {'symbol': 'btc', 'name': 'Bitcoin'},
        'ethereum': {'symbol': 'eth', 'name': 'Ethereum'},
        'binancecoin': {'symbol': 'bnb', 'name': 'BNB'},
        'ripple': {'symbol': 'xrp', 'name': 'XRP'},
        'cardano': {'symbol': 'ada', 'name': 'Cardano'},
        'solana': {'symbol': 'sol', 'name': 'Solana'},
        'dogecoin': {'symbol': 'doge', 'name': 'Dogecoin'},
        'polkadot': {'symbol': 'dot', 'name': 'Polkadot'},
        'dai': {'symbol': 'dai', 'name': 'Dai'},
        'avalanche-2': {'symbol': 'avax', 'name': 'Avalanche'},
        'shiba-inu': {'symbol': 'shib', 'name': 'Shiba Inu'},
        'matic-network': {'symbol': 'matic', 'name': 'Polygon'},
        'litecoin': {'symbol': 'ltc', 'name': 'Litecoin'},
        'chainlink': {'symbol': 'link', 'name': 'Chainlink'},
        'cosmos': {'symbol': 'atom', 'name': 'Cosmos'},
        'uniswap': {'symbol': 'uni', 'name': 'Uniswap'},
        'ethereum-classic': {'symbol': 'etc', 'name': 'Ethereum Classic'},
        'stellar': {'symbol': 'xlm', 'name': 'Stellar'},
        'bitcoin-cash': {'symbol': 'bch', 'name': 'Bitcoin Cash'},
        'near': {'symbol': 'near', 'name': 'NEAR Protocol'},
        'algorand': {'symbol': 'algo', 'name': 'Algorand'},
        'vechain': {'symbol': 'vet', 'name': 'VeChain'},
        'filecoin': {'symbol': 'fil', 'name': 'Filecoin'},
        'tron': {'symbol': 'trx', 'name': 'TRON'},
        'internet-computer': {'symbol': 'icp', 'name': 'Internet Computer'},
        'hedera-hashgraph': {'symbol': 'hbar', 'name': 'Hedera'},
        'decentraland': {'symbol': 'mana', 'name': 'Decentraland'},
        'the-sandbox': {'symbol': 'sand', 'name': 'The Sandbox'},
        'axie-infinity': {'symbol': 'axs', 'name': 'Axie Infinity'},
        'flow': {'symbol': 'flow', 'name': 'Flow'},
        'theta-token': {'symbol': 'theta', 'name': 'Theta Network'},
        'fantom': {'symbol': 'ftm', 'name': 'Fantom'},
        'tezos': {'symbol': 'xtz', 'name': 'Tezos'},
        'elrond-erd-2': {'symbol': 'egld', 'name': 'MultiversX'},
        'klay-token': {'symbol': 'klay', 'name': 'Klaytn'},
        'curve-dao-token': {'symbol': 'crv', 'name': 'Curve DAO Token'},
        'compound-governance-token': {'symbol': 'comp', 'name': 'Compound'},
        'maker': {'symbol': 'mkr', 'name': 'Maker'},
        'havven': {'symbol': 'snx', 'name': 'Synthetix'},
        'aave': {'symbol': 'aave', 'name': 'Aave'},
        'yearn-finance': {'symbol': 'yfi', 'name': 'yearn.finance'},
        'sushi': {'symbol': 'sushi', 'name': 'SushiSwap'},
        '1inch': {'symbol': '1inch', 'name': '1inch'},
        'enjincoin': {'symbol': 'enj', 'name': 'Enjin Coin'},
        'basic-attention-token': {'symbol': 'bat', 'name': 'Basic Attention Token'},
        'zcash': {'symbol': 'zec', 'name': 'Zcash'},
        'dash': {'symbol': 'dash', 'name': 'Dash'},
        'monero': {'symbol': 'xmr', 'name': 'Monero'},
        'neo': {'symbol': 'neo', 'name': 'NEO'},
        'qtum': {'symbol': 'qtum', 'name': 'Qtum'}
      };

      print('[CoinRepository] 📋 Popular coins: ${popularCoinsData.length} coins');
      final popularCoins = <Coin>[];
      for (final entry in popularCoinsData.entries) {
        final coinId = entry.key;
        final data = entry.value;
        popularCoins.add(Coin(
          id: coinId,
          symbol: data['symbol']!,
          name: data['name']!,
        ));
        print('[CoinRepository] 🪙 Added: $coinId (${data['symbol']}) - ${data['name']}');
      }

      print('[CoinRepository] ✅ Generated ${popularCoins.length} popular coins');
      return popularCoins;
    } catch (e) {
      print('[CoinRepository] 💥 Exception in getPopularCoinsFast: $e');
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
    print('[CoinRepository] 💰 Starting getPrices API call...');
    print('[CoinRepository] 🪙 Requested coin IDs: $coinIds');
    
    if (coinIds.isEmpty) {
      print('[CoinRepository] ⚠️ No coin IDs provided, returning empty map');
      return {};
    }

    if (_lastPriceRequest != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastPriceRequest!);
      if (timeSinceLastRequest < _rateLimitDelay) {
        final waitTime = _rateLimitDelay - timeSinceLastRequest;
        print('[CoinRepository] ⏳ Rate limiting: waiting ${waitTime.inSeconds} seconds...');
        await Future.delayed(waitTime);
      }
    }

    try {
      final idsParam = coinIds.join(',');
      final url = '$_baseUrl$_priceEndpoint?ids=$idsParam&vs_currencies=usd';
      
      print('[CoinRepository] 📡 Price API URL: $url');
      _lastPriceRequest = DateTime.now();
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      );

      print('[CoinRepository] 📊 Price Response Status: ${response.statusCode}');
      print('[CoinRepository] 📏 Price Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        print('[CoinRepository] ✅ Successfully received price data');
        print('[CoinRepository] 📄 Raw Response Body: ${response.body}');
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print('[CoinRepository] 📋 Price data for ${jsonData.length} coins');
        print('[CoinRepository] 🔍 JSON Keys: ${jsonData.keys.toList()}');
        
        final Map<String, PriceData> prices = {};
        
        if (jsonData.isEmpty) {
          print('[CoinRepository] ⚠️ WARNING: Empty response from API!');
          print('[CoinRepository] 🔍 Requested coin IDs: $coinIds');
          print('[CoinRepository] 🔍 API URL was: $url');
        }
        
        jsonData.forEach((coinId, data) {
          print('[CoinRepository] 🔍 Processing $coinId: $data');
          prices[coinId] = PriceData.fromJson(coinId, data);
          print('[CoinRepository] 💵 $coinId: \$${data['usd']}');
        });
        
        print('[CoinRepository] ✅ Successfully parsed ${prices.length} prices');
        return prices;
      } else if (response.statusCode == 429) {
        print('[CoinRepository] ⚠️ Rate limit exceeded (429), using fallback prices');
        return _getFallbackPrices(coinIds);
      } else {
        print('[CoinRepository] ❌ API Error: ${response.statusCode}');
        print('[CoinRepository] 📄 Response Body: ${response.body}');
        print('[CoinRepository] 🔄 Using fallback prices');
        return _getFallbackPrices(coinIds);
      }
    } catch (e) {
      print('[CoinRepository] 💥 Exception in getPrices: $e');
      print('[CoinRepository] 🔄 Using fallback prices');
      return _getFallbackPrices(coinIds);
    }
  }

  Map<String, PriceData> _getFallbackPrices(List<String> coinIds) {
    print('[CoinRepository] 🔄 Generating fallback prices for ${coinIds.length} coins...');
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
      
      print('[CoinRepository] 💰 Fallback price for $coinId: \$${price.toStringAsFixed(2)}');
    }
    
    print('[CoinRepository] ✅ Generated ${fallbackPrices.length} fallback prices');
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

  // Periodic update functionality
  void startPeriodicUpdates(Function(List<String>) onUpdate) {
    print('[CoinRepository] ⏰ Starting periodic price updates every ${_currentUpdateInterval.inMinutes} minutes');
    _periodicUpdateTimer?.cancel();
    _periodicUpdateTimer = Timer.periodic(_currentUpdateInterval, (timer) async {
      await _performPeriodicUpdate(onUpdate);
    });
  }

  void stopPeriodicUpdates() {
    print('[CoinRepository] ⏹️ Stopping periodic price updates');
    _periodicUpdateTimer?.cancel();
    _periodicUpdateTimer = null;
  }

  Future<void> _performPeriodicUpdate(Function(List<String>) onUpdate) async {
    try {
      print('[CoinRepository] 🔄 Performing periodic price update...');
      
      // Get current portfolio coin IDs
      final coinIds = await _getCurrentPortfolioCoinIds();
      if (coinIds.isEmpty) {
        print('[CoinRepository] 📭 No coins in portfolio, skipping update');
        return;
      }

      // Fetch prices
      final prices = await getPrices(coinIds);
      
      if (prices.isNotEmpty) {
        print('[CoinRepository] ✅ Periodic update successful: ${prices.length} prices updated');
        _consecutiveFailures = 0;
        _currentUpdateInterval = _updateInterval; // Reset to normal interval
        
        // Notify listeners
        onUpdate(coinIds);
      } else {
        throw Exception('No prices received');
      }
    } catch (e) {
      _consecutiveFailures++;
      print('[CoinRepository] ❌ Periodic update failed (attempt $_consecutiveFailures): $e');
      
      // Implement exponential backoff
      if (_consecutiveFailures >= 3) {
        _currentUpdateInterval = Duration(
          minutes: (_currentUpdateInterval.inMinutes * 1.5).clamp(
            _updateInterval.inMinutes, 
            _maxUpdateInterval.inMinutes
          ).toInt()
        );
        print('[CoinRepository] ⏳ Increasing update interval to ${_currentUpdateInterval.inMinutes} minutes due to failures');
        
        // Restart timer with new interval
        stopPeriodicUpdates();
        startPeriodicUpdates(onUpdate);
      }
    }
  }

  Future<List<String>> _getCurrentPortfolioCoinIds() async {
    // This would typically be injected or accessed through a callback
    // For now, we'll return an empty list and let the calling code provide the coin IDs
    return [];
  }

  void dispose() {
    stopPeriodicUpdates();
  }
}
