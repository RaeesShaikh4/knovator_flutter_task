import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import '../bloc/portfolio/portfolio_state.dart';
import '../repositories/portfolio_repository.dart';
import '../repositories/coin_repository.dart';
import '../widgets/portfolio_item_card.dart';
import '../widgets/add_asset_dialog.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late PortfolioBloc _portfolioBloc;

  @override
  void initState() {
    super.initState();
    _portfolioBloc = PortfolioBloc(
      portfolioRepository: PortfolioRepository(),
      coinRepository: CoinRepository(),
    );
    _portfolioBloc.add(LoadPortfolio());
  }

  @override
  void dispose() {
    _portfolioBloc.close();
    super.dispose();
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => BlocProvider.value(
        value: _portfolioBloc,
        child: const AddAssetDialog(),
      ),
    );
  }

  void _refreshPortfolio() {
    _portfolioBloc.add(RefreshPortfolio());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Crypto Portfolio',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPortfolio,
          ),
        ],
      ),
      body: BlocBuilder<PortfolioBloc, PortfolioState>(
        bloc: _portfolioBloc,
        builder: (context, state) {
          if (state is PortfolioLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A2E)),
              ),
            );
          }

          if (state is PortfolioError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _portfolioBloc.add(LoadPortfolio()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PortfolioLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _refreshPortfolio();
                // Wait for the refresh to complete
                await Future.delayed(const Duration(seconds: 1));
              },
              child: Column(
                children: [
                  // Total Portfolio Value Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Portfolio Value',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 2)
                              .format(state.totalValue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.portfolio.length} Assets',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Portfolio List
                  Expanded(
                    child: state.portfolio.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.wallet_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No assets in your portfolio',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the + button to add your first asset',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: _showAddAssetDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Asset'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A1A2E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: state.portfolio.length,
                            itemBuilder: (context, index) {
                              final item = state.portfolio[index];
                              return PortfolioItemCard(
                                item: item,
                                onRemove: () {
                                  _portfolioBloc.add(
                                    RemovePortfolioItem(coinId: item.coinId),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssetDialog,
        backgroundColor: const Color(0xFF1A1A2E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
