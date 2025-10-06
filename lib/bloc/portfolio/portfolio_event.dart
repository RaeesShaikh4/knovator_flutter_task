import '../../models/portfolio_item.dart';

abstract class PortfolioEvent {}

class LoadPortfolio extends PortfolioEvent {}

class RefreshPortfolio extends PortfolioEvent {}

class AddPortfolioItem extends PortfolioEvent {
  final PortfolioItem item;

  AddPortfolioItem({required this.item});
}

class RemovePortfolioItem extends PortfolioEvent {
  final String coinId;

  RemovePortfolioItem({required this.coinId});
}

class UpdatePortfolioItem extends PortfolioEvent {
  final PortfolioItem item;

  UpdatePortfolioItem({required this.item});
}

class UpdatePrices extends PortfolioEvent {
  final Map<String, double> prices;

  UpdatePrices({required this.prices});
}
