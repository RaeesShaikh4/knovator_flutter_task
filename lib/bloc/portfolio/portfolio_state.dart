import '../../models/portfolio_item.dart';

abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<PortfolioItem> portfolio;
  final double totalValue;
  final bool isRefreshing;

  PortfolioLoaded({
    required this.portfolio,
    required this.totalValue,
    this.isRefreshing = false,
  });

  PortfolioLoaded copyWith({
    List<PortfolioItem>? portfolio,
    double? totalValue,
    bool? isRefreshing,
  }) {
    return PortfolioLoaded(
      portfolio: portfolio ?? this.portfolio,
      totalValue: totalValue ?? this.totalValue,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class PortfolioError extends PortfolioState {
  final String message;

  PortfolioError({required this.message});
}
