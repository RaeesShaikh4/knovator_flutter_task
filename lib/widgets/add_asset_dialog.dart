import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../bloc/coin_list/coin_list_bloc.dart';
import '../bloc/coin_list/coin_list_event.dart';
import '../bloc/coin_list/coin_list_state.dart';
import '../bloc/portfolio/portfolio_bloc.dart';
import '../bloc/portfolio/portfolio_event.dart';
import '../models/coin.dart';
import '../models/portfolio_item.dart';
import '../repositories/coin_repository.dart';

class AddAssetDialog extends StatefulWidget {
  const AddAssetDialog({super.key});

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final FocusNode _quantityFocusNode = FocusNode();
  
  Coin? _selectedCoin;
  late CoinListBloc _coinListBloc;
  Timer? _searchTimer;

  @override
  void initState() {
    super.initState();
    _coinListBloc = CoinListBloc(coinRepository: CoinRepository());
    _coinListBloc.add(LoadCoinList());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    _searchTimer?.cancel();
    _coinListBloc.close();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _searchTimer?.cancel();
    
    if (query.isEmpty) {
      _coinListBloc.add(ClearFilter());
    } else {
      // Debounce search to avoid excessive filtering
      _searchTimer = Timer(const Duration(milliseconds: 300), () {
        _coinListBloc.add(FilterCoins(query: query));
      });
    }
  }

  void _selectCoin(Coin coin) {
    setState(() {
      _selectedCoin = coin;
      _searchController.text = '${coin.name} (${coin.symbol.toUpperCase()})';
    });
    _quantityFocusNode.requestFocus();
  }

  void _addAsset() {
    if (_selectedCoin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a cryptocurrency')),
      );
      return;
    }

    final quantityText = _quantityController.text.trim();
    if (quantityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quantity')),
      );
      return;
    }

    final quantity = double.tryParse(quantityText);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    final portfolioItem = PortfolioItem(
      coinId: _selectedCoin!.id,
      coinSymbol: _selectedCoin!.symbol,
      coinName: _selectedCoin!.name,
      quantity: quantity,
    );

    context.read<PortfolioBloc>().add(AddPortfolioItem(item: portfolioItem));
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedCoin!.name} added to portfolio')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final availableHeight = screenHeight - keyboardHeight;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: keyboardHeight > 0 
              ? availableHeight * 0.9
              : screenHeight * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Add Asset',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Search Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search cryptocurrencies...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity Field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _quantityController,
                    focusNode: _quantityFocusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      hintText: 'Enter quantity (e.g., 0.5)',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.numbers,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
            const SizedBox(height: 16),

            // Selected Coin Display
            if (_selectedCoin != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getCoinColor(_selectedCoin!.symbol),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _selectedCoin!.symbol.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedCoin!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _selectedCoin!.symbol.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Coin List
            Flexible(
              child: BlocBuilder<CoinListBloc, CoinListState>(
                bloc: _coinListBloc,
                builder: (context, state) {
                  if (state is CoinListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A2E)),
                      ),
                    );
                  }

                  if (state is CoinListError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _coinListBloc.add(LoadCoinList()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is CoinListLoaded) {
                    final coins = state.filteredCoins.take(30).toList(); // Limit to 30 for better performance
                    
                    if (coins.isEmpty) {
                      return const Center(
                        child: Text(
                          'No cryptocurrencies found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 200, // Fixed height for the ListView
                      child: ListView.builder(
                        itemCount: coins.length,
                        itemBuilder: (context, index) {
                          final coin = coins[index];
                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _getCoinColor(coin.symbol),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  coin.symbol.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              coin.name,
                              
                              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                            ),
                            subtitle: Text(
                              coin.symbol.toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () => _selectCoin(coin),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),

            const SizedBox(height: 16),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addAsset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add to Portfolio',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCoinColor(String symbol) {
    final colors = [
      const Color(0xFF4CAF50), // Green
      const Color(0xFF2196F3), // Blue
      const Color(0xFFFF9800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFF44336), // Red
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFC107), // Amber
      const Color(0xFF795548), // Brown
    ];
    
    return colors[symbol.hashCode % colors.length];
  }
}
