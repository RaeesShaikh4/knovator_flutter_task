import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/portfolio_repository.dart';
import '../../repositories/coin_repository.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final PortfolioRepository _portfolioRepository;
  final CoinRepository _coinRepository;

  PortfolioBloc({
    required PortfolioRepository portfolioRepository,
    required CoinRepository coinRepository,
  })  : _portfolioRepository = portfolioRepository,
        _coinRepository = coinRepository,
        super(PortfolioInitial()) {
    on<LoadPortfolio>(_onLoadPortfolio);
    on<RefreshPortfolio>(_onRefreshPortfolio);
        on<AddPortfolioItem>(_onAddPortfolioItem);
        on<RemovePortfolioItem>(_onRemovePortfolioItem);
        on<UpdatePortfolioItem>(_onUpdatePortfolioItem);
        on<UpdatePrices>(_onUpdatePrices);
        on<SortPortfolio>(_onSortPortfolio);
  }

  Future<void> _onLoadPortfolio(
    LoadPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      emit(PortfolioLoading());
      
      final portfolio = await _portfolioRepository.getPortfolio();
      
      if (portfolio.isEmpty) {
        emit(PortfolioLoaded(portfolio: [], totalValue: 0.0));
        return;
      }

      final coinIds = portfolio.map((item) => item.coinId).toList();
      final prices = await _coinRepository.getPrices(coinIds);
      
      // Update portfolio with current prices and track changes
      final updatedPortfolio = portfolio.map((item) {
        final price = prices[item.coinId]?.price;
        final totalValue = price != null ? item.quantity * price : 0.0;
        
        // Calculate price change
        double? priceChange;
        double? priceChangePercent;
        if (price != null && item.currentPrice != null) {
          priceChange = price - item.currentPrice!;
          priceChangePercent = (priceChange / item.currentPrice!) * 100;
        }
        
        return item.copyWith(
          previousPrice: item.currentPrice,
          currentPrice: price,
          totalValue: totalValue,
          priceChange: priceChange,
          priceChangePercent: priceChangePercent,
        );
      }).toList();

      final totalPortfolioValue = updatedPortfolio
          .map((item) => item.totalValue ?? 0.0)
          .fold(0.0, (sum, value) => sum + value);

      emit(PortfolioLoaded(
        portfolio: updatedPortfolio,
        totalValue: totalPortfolioValue,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      
      // Check if it's a rate limit error
      if (errorMessage.contains('429') || errorMessage.contains('Rate Limit')) {
        errorMessage = 'API rate limit exceeded. Using sample prices for demonstration.';
      }
      
      emit(PortfolioError(message: errorMessage));
    }
  }

  Future<void> _onRefreshPortfolio(
    RefreshPortfolio event,
    Emitter<PortfolioState> emit,
  ) async {
    if (state is! PortfolioLoaded) return;

    final currentState = state as PortfolioLoaded;
    emit(currentState.copyWith(isRefreshing: true));

    try {
      final portfolio = currentState.portfolio;
      
      if (portfolio.isEmpty) {
        emit(currentState.copyWith(isRefreshing: false));
        return;
      }

      // Fetch current prices
      final coinIds = portfolio.map((item) => item.coinId).toList();
      final prices = await _coinRepository.getPrices(coinIds);
      
      // Update portfolio with current prices and track changes
      final updatedPortfolio = portfolio.map((item) {
        final price = prices[item.coinId]?.price;
        final totalValue = price != null ? item.quantity * price : 0.0;
        
        // Calculate price change
        double? priceChange;
        double? priceChangePercent;
        if (price != null && item.currentPrice != null) {
          priceChange = price - item.currentPrice!;
          priceChangePercent = (priceChange / item.currentPrice!) * 100;
        }
        
        return item.copyWith(
          previousPrice: item.currentPrice,
          currentPrice: price,
          totalValue: totalValue,
          priceChange: priceChange,
          priceChangePercent: priceChangePercent,
        );
      }).toList();

      final totalPortfolioValue = updatedPortfolio
          .map((item) => item.totalValue ?? 0.0)
          .fold(0.0, (sum, value) => sum + value);

      emit(PortfolioLoaded(
        portfolio: updatedPortfolio,
        totalValue: totalPortfolioValue,
        isRefreshing: false,
      ));
    } catch (e) {
      String errorMessage = e.toString();
      
      // Check if it's a rate limit error
      if (errorMessage.contains('429') || errorMessage.contains('Rate Limit')) {
        errorMessage = 'API rate limit exceeded. Using sample prices for demonstration.';
      }
      
      emit(PortfolioError(message: errorMessage));
    }
  }

  Future<void> _onAddPortfolioItem(
    AddPortfolioItem event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      await _portfolioRepository.addPortfolioItem(event.item);
      add(LoadPortfolio());
    } catch (e) {
      String errorMessage = e.toString();
      
      // Check if it's a rate limit error
      if (errorMessage.contains('429') || errorMessage.contains('Rate Limit')) {
        errorMessage = 'API rate limit exceeded. Using sample prices for demonstration.';
      }
      
      emit(PortfolioError(message: errorMessage));
    }
  }

  Future<void> _onRemovePortfolioItem(
    RemovePortfolioItem event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      await _portfolioRepository.removePortfolioItem(event.coinId);
      add(LoadPortfolio());
    } catch (e) {
      String errorMessage = e.toString();
      
      // Check if it's a rate limit error
      if (errorMessage.contains('429') || errorMessage.contains('Rate Limit')) {
        errorMessage = 'API rate limit exceeded. Using sample prices for demonstration.';
      }
      
      emit(PortfolioError(message: errorMessage));
    }
  }

  Future<void> _onUpdatePortfolioItem(
    UpdatePortfolioItem event,
    Emitter<PortfolioState> emit,
  ) async {
    try {
      await _portfolioRepository.updatePortfolioItem(event.item);
      add(LoadPortfolio());
    } catch (e) {
      String errorMessage = e.toString();
      
      // Check if it's a rate limit error
      if (errorMessage.contains('429') || errorMessage.contains('Rate Limit')) {
        errorMessage = 'API rate limit exceeded. Using sample prices for demonstration.';
      }
      
      emit(PortfolioError(message: errorMessage));
    }
  }

  Future<void> _onUpdatePrices(
    UpdatePrices event,
    Emitter<PortfolioState> emit,
  ) async {
    if (state is! PortfolioLoaded) return;

    final currentState = state as PortfolioLoaded;
    final updatedPortfolio = currentState.portfolio.map((item) {
      final price = event.prices[item.coinId];
      final totalValue = price != null ? item.quantity * price : 0.0;
      
      return item.copyWith(
        currentPrice: price,
        totalValue: totalValue,
      );
    }).toList();

    final totalPortfolioValue = updatedPortfolio
        .map((item) => item.totalValue ?? 0.0)
        .fold(0.0, (sum, value) => sum + value);

    emit(PortfolioLoaded(
      portfolio: updatedPortfolio,
      totalValue: totalPortfolioValue,
    ));
  }

  void _onSortPortfolio(
    SortPortfolio event,
    Emitter<PortfolioState> emit,
  ) {
    if (state is! PortfolioLoaded) return;
    
    final currentState = state as PortfolioLoaded;
    emit(currentState.copyWith(sortOption: event.sortOption));
  }
}
