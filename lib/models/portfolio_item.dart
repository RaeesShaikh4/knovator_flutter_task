class PortfolioItem {
  final String coinId;
  final String coinSymbol;
  final String coinName;
  final double quantity;
  final double? currentPrice;
  final double? totalValue;
  final double? previousPrice;
  final double? priceChange;
  final double? priceChangePercent;

  const PortfolioItem({
    required this.coinId,
    required this.coinSymbol,
    required this.coinName,
    required this.quantity,
    this.currentPrice,
    this.totalValue,
    this.previousPrice,
    this.priceChange,
    this.priceChangePercent,
  });

  PortfolioItem copyWith({
    String? coinId,
    String? coinSymbol,
    String? coinName,
    double? quantity,
    double? currentPrice,
    double? totalValue,
    double? previousPrice,
    double? priceChange,
    double? priceChangePercent,
  }) {
    return PortfolioItem(
      coinId: coinId ?? this.coinId,
      coinSymbol: coinSymbol ?? this.coinSymbol,
      coinName: coinName ?? this.coinName,
      quantity: quantity ?? this.quantity,
      currentPrice: currentPrice ?? this.currentPrice,
      totalValue: totalValue ?? this.totalValue,
      previousPrice: previousPrice ?? this.previousPrice,
      priceChange: priceChange ?? this.priceChange,
      priceChangePercent: priceChangePercent ?? this.priceChangePercent,
    );
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      coinId: json['coinId'] as String,
      coinSymbol: json['coinSymbol'] as String,
      coinName: json['coinName'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      currentPrice: json['currentPrice'] != null 
          ? (json['currentPrice'] as num).toDouble() 
          : null,
      totalValue: json['totalValue'] != null 
          ? (json['totalValue'] as num).toDouble() 
          : null,
      previousPrice: json['previousPrice'] != null 
          ? (json['previousPrice'] as num).toDouble() 
          : null,
      priceChange: json['priceChange'] != null 
          ? (json['priceChange'] as num).toDouble() 
          : null,
      priceChangePercent: json['priceChangePercent'] != null 
          ? (json['priceChangePercent'] as num).toDouble() 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coinId': coinId,
      'coinSymbol': coinSymbol,
      'coinName': coinName,
      'quantity': quantity,
      'currentPrice': currentPrice,
      'totalValue': totalValue,
      'previousPrice': previousPrice,
      'priceChange': priceChange,
      'priceChangePercent': priceChangePercent,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioItem && other.coinId == coinId;
  }

  @override
  int get hashCode => coinId.hashCode;

  @override
  String toString() {
    return 'PortfolioItem(coinId: $coinId, symbol: $coinSymbol, name: $coinName, quantity: $quantity, price: $currentPrice, total: $totalValue)';
  }
}
