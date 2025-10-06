class PriceData {
  final String coinId;
  final double price;

  const PriceData({
    required this.coinId,
    required this.price,
  });

  factory PriceData.fromJson(String coinId, Map<String, dynamic> json) {
    return PriceData(
      coinId: coinId,
      price: (json['usd'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'PriceData(coinId: $coinId, price: $price)';
  }
}
