import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_item.dart';

class PortfolioRepository {
  static const String _portfolioKey = 'portfolio_items';

  Future<List<PortfolioItem>> getPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? portfolioJson = prefs.getString(_portfolioKey);
      
      if (portfolioJson == null || portfolioJson.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(portfolioJson);
      final portfolio = jsonList.map((json) => PortfolioItem.fromJson(json)).toList();
      
      // Check if portfolio contains old incorrect coin IDs and clear if so
      final hasOldIds = portfolio.any((item) => 
        item.coinId == 'btc' || item.coinId == 'bnb' || item.coinId == 'eth' ||
        item.coinId == 'xrp' || item.coinId == 'ada' || item.coinId == 'sol'
      );
      
      if (hasOldIds) {
        print('[PortfolioRepository] 🔄 Found old coin IDs, clearing portfolio for migration...');
        await clearPortfolio();
        return [];
      }
      
      return portfolio;
    } catch (e) {
      throw Exception('Error loading portfolio: $e');
    }
  }

  Future<void> savePortfolio(List<PortfolioItem> portfolio) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String portfolioJson = json.encode(
        portfolio.map((item) => item.toJson()).toList(),
      );
      await prefs.setString(_portfolioKey, portfolioJson);
    } catch (e) {
      throw Exception('Error saving portfolio: $e');
    }
  }

  Future<void> addPortfolioItem(PortfolioItem item) async {
    try {
      final portfolio = await getPortfolio();
      
      // Check if coin already exists
      final existingIndex = portfolio.indexWhere((p) => p.coinId == item.coinId);
      
      if (existingIndex != -1) {
        // Update existing item
        portfolio[existingIndex] = portfolio[existingIndex].copyWith(
          quantity: portfolio[existingIndex].quantity + item.quantity,
        );
      } else {
        // Add new item
        portfolio.add(item);
      }
      
      await savePortfolio(portfolio);
    } catch (e) {
      throw Exception('Error adding portfolio item: $e');
    }
  }

  Future<void> removePortfolioItem(String coinId) async {
    try {
      final portfolio = await getPortfolio();
      portfolio.removeWhere((item) => item.coinId == coinId);
      await savePortfolio(portfolio);
    } catch (e) {
      throw Exception('Error removing portfolio item: $e');
    }
  }

  Future<void> updatePortfolioItem(PortfolioItem updatedItem) async {
    try {
      final portfolio = await getPortfolio();
      final index = portfolio.indexWhere((item) => item.coinId == updatedItem.coinId);
      
      if (index != -1) {
        portfolio[index] = updatedItem;
        await savePortfolio(portfolio);
      }
    } catch (e) {
      throw Exception('Error updating portfolio item: $e');
    }
  }

  Future<void> clearPortfolio() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_portfolioKey);
      print('[PortfolioRepository] 🗑️ Portfolio cleared successfully');
    } catch (e) {
      throw Exception('Error clearing portfolio: $e');
    }
  }
}
