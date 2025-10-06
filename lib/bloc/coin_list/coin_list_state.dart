import '../../models/coin.dart';

abstract class CoinListState {}

class CoinListInitial extends CoinListState {}

class CoinListLoading extends CoinListState {}

class CoinListLoaded extends CoinListState {
  final List<Coin> coins;
  final List<Coin> filteredCoins;
  final bool isProcessing;

  CoinListLoaded({
    required this.coins,
    required this.filteredCoins,
    this.isProcessing = false,
  });

  CoinListLoaded copyWith({
    List<Coin>? coins,
    List<Coin>? filteredCoins,
    bool? isProcessing,
  }) {
    return CoinListLoaded(
      coins: coins ?? this.coins,
      filteredCoins: filteredCoins ?? this.filteredCoins,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class CoinListError extends CoinListState {
  final String message;

  CoinListError({required this.message});
}
