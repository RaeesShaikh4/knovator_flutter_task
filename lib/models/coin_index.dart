import 'package:knovator_task/models/coin.dart';

class CoinIndex {
  final Map<String, Coin> _coinsById;
  final Map<String, List<Coin>> _coinsBySymbol;
  final Map<String, List<Coin>> _coinsByName;
  final List<Coin> _allCoins;

  CoinIndex({
    required Map<String, Coin> coinsById,
    required Map<String, List<Coin>> coinsBySymbol,
    required Map<String, List<Coin>> coinsByName,
    required List<Coin> allCoins,
  }) : _coinsById = coinsById,
       _coinsBySymbol = coinsBySymbol,
       _coinsByName = coinsByName,
       _allCoins = allCoins;

  factory CoinIndex.fromCoins(List<Coin> coins) {
    final coinsById = <String, Coin>{};
    final coinsBySymbol = <String, List<Coin>>{};
    final coinsByName = <String, List<Coin>>{};

    for (final coin in coins) {
      // Index by ID
      coinsById[coin.id] = coin;

      // Index by symbol (case insensitive)
      final symbolKey = coin.symbol.toLowerCase();
      coinsBySymbol[symbolKey] = (coinsBySymbol[symbolKey] ?? [])..add(coin);

      // Index by name (case insensitive)
      final nameKey = coin.name.toLowerCase();
      coinsByName[nameKey] = (coinsByName[nameKey] ?? [])..add(coin);
    }

    return CoinIndex(
      coinsById: coinsById,
      coinsBySymbol: coinsBySymbol,
      coinsByName: coinsByName,
      allCoins: coins,
    );
  }

  // Fast O(1) lookup by ID
  Coin? getById(String id) => _coinsById[id];

  // Fast O(1) lookup by symbol
  List<Coin> getBySymbol(String symbol) => 
      _coinsBySymbol[symbol.toLowerCase()] ?? [];

  // Fast O(1) lookup by name
  List<Coin> getByName(String name) => 
      _coinsByName[name.toLowerCase()] ?? [];

  // Optimized search with multiple strategies
  List<Coin> search(String query, {int maxResults = 50}) {
    if (query.isEmpty) return _allCoins.take(maxResults).toList();

    final results = <Coin>{};
    final lowerQuery = query.toLowerCase().trim();

    // Strategy 1: Exact symbol match (highest priority)
    final exactSymbolMatches = getBySymbol(lowerQuery);
    results.addAll(exactSymbolMatches);

    // Strategy 2: Symbol starts with query
    for (final symbol in _coinsBySymbol.keys) {
      if (symbol.startsWith(lowerQuery)) {
        results.addAll(_coinsBySymbol[symbol]!);
        if (results.length >= maxResults) break;
      }
    }

    // Strategy 3: Name starts with query
    for (final name in _coinsByName.keys) {
      if (name.startsWith(lowerQuery)) {
        results.addAll(_coinsByName[name]!);
        if (results.length >= maxResults) break;
      }
    }

    // Strategy 4: Symbol contains query
    if (results.length < maxResults) {
      for (final symbol in _coinsBySymbol.keys) {
        if (symbol.contains(lowerQuery) && !symbol.startsWith(lowerQuery)) {
          results.addAll(_coinsBySymbol[symbol]!);
          if (results.length >= maxResults) break;
        }
      }
    }

    // Strategy 5: Name contains query
    if (results.length < maxResults) {
      for (final name in _coinsByName.keys) {
        if (name.contains(lowerQuery) && !name.startsWith(lowerQuery)) {
          results.addAll(_coinsByName[name]!);
          if (results.length >= maxResults) break;
        }
      }
    }

    return results.take(maxResults).toList();
  }

  // Get all coins
  List<Coin> get allCoins => _allCoins;

  // Get popular coins (predefined list)
  List<Coin> get popularCoins {
    const popularSymbols = {
      'btc', 'eth', 'bnb', 'xrp', 'ada', 'sol', 'doge', 'dot', 'dai', 'avax',
      'shib', 'matic', 'ltc', 'link', 'atom', 'uni', 'etc', 'xlm', 'bch', 'near',
      'algo', 'vet', 'fil', 'trx', 'icp', 'hbar', 'mana', 'sand', 'axs', 'flow',
      'theta', 'ftm', 'xtz', 'egld', 'klay', 'crv', 'comp', 'mkr', 'snx', 'aave',
      'yfi', 'sushi', '1inch', 'enj', 'bat', 'zec', 'dash', 'xmr', 'neo', 'qtum'
    };

    final popular = <Coin>[];
    for (final symbol in popularSymbols) {
      popular.addAll(getBySymbol(symbol));
    }
    return popular;
  }

  // Get total count
  int get totalCount => _allCoins.length;
}
