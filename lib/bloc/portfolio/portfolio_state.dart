import '../../models/portfolio_item.dart';
import '../../models/sort_option.dart';

abstract class PortfolioState {}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<PortfolioItem> portfolio;
  final double totalValue;
  final bool isRefreshing;
  final SortOption sortOption;

  PortfolioLoaded({
    required this.portfolio,
    required this.totalValue,
    this.isRefreshing = false,
    this.sortOption = SortOption.valueDescending,
  });

  PortfolioLoaded copyWith({
    List<PortfolioItem>? portfolio,
    double? totalValue,
    bool? isRefreshing,
    SortOption? sortOption,
  }) {
    return PortfolioLoaded(
      portfolio: portfolio ?? this.portfolio,
      totalValue: totalValue ?? this.totalValue,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  List<PortfolioItem> get sortedPortfolio {
    final sortedList = List<PortfolioItem>.from(portfolio);
    
    switch (sortOption) {
      case SortOption.nameAscending:
        sortedList.sort((a, b) => a.coinName.compareTo(b.coinName));
        break;
      case SortOption.nameDescending:
        sortedList.sort((a, b) => b.coinName.compareTo(a.coinName));
        break;
      case SortOption.valueAscending:
        sortedList.sort((a, b) => (a.totalValue ?? 0).compareTo(b.totalValue ?? 0));
        break;
      case SortOption.valueDescending:
        sortedList.sort((a, b) => (b.totalValue ?? 0).compareTo(a.totalValue ?? 0));
        break;
      case SortOption.symbolAscending:
        sortedList.sort((a, b) => a.coinSymbol.compareTo(b.coinSymbol));
        break;
      case SortOption.symbolDescending:
        sortedList.sort((a, b) => b.coinSymbol.compareTo(a.coinSymbol));
        break;
    }
    
    return sortedList;
  }
}

class PortfolioError extends PortfolioState {
  final String message;

  PortfolioError({required this.message});
}
