import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/coin_repository.dart';
import '../../models/coin.dart';
import 'coin_list_event.dart';
import 'coin_list_state.dart';

class CoinListBloc extends Bloc<CoinListEvent, CoinListState> {
  final CoinRepository _coinRepository;

  CoinListBloc({required CoinRepository coinRepository})
      : _coinRepository = coinRepository,
        super(CoinListInitial()) {
    on<LoadCoinList>(_onLoadCoinList);
    on<FilterCoins>(_onFilterCoins);
    on<ClearFilter>(_onClearFilter);
  }

  Future<void> _onLoadCoinList(
    LoadCoinList event,
    Emitter<CoinListState> emit,
  ) async {
    try {
      emit(CoinListLoading());
      
      final popularCoins = await _coinRepository.getPopularCoinsFast();
      
      emit(CoinListLoaded(
        coins: popularCoins,
        filteredCoins: popularCoins,
        isProcessing: false,
      ));
    } catch (e) {
      emit(CoinListError(message: e.toString()));
    }
  }


  void _onFilterCoins(
    FilterCoins event,
    Emitter<CoinListState> emit,
  ) {
    if (state is! CoinListLoaded) return;

    final currentState = state as CoinListLoaded;
    final query = event.query.toLowerCase().trim();

    if (query.isEmpty) {
      emit(currentState.copyWith(filteredCoins: currentState.coins));
      return;
    }

    final filteredCoins = _coinRepository.searchCoins(query, maxResults: 50);

    emit(currentState.copyWith(
      filteredCoins: filteredCoins,
      isProcessing: false,
    ));
  }

  void _onClearFilter(
    ClearFilter event,
    Emitter<CoinListState> emit,
  ) {
    if (state is! CoinListLoaded) return;

    final currentState = state as CoinListLoaded;
    emit(currentState.copyWith(filteredCoins: currentState.coins));
  }
}
