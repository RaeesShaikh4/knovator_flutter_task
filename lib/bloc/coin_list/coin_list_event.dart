abstract class CoinListEvent {}

class LoadCoinList extends CoinListEvent {}

class FilterCoins extends CoinListEvent {
  final String query;

  FilterCoins({required this.query});
}

class ClearFilter extends CoinListEvent {}
