class Coin {
  final String id;
  final String symbol;
  final String name;

  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Coin && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Coin(id: $id, symbol: $symbol, name: $name)';
  }
}
