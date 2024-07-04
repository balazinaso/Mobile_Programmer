class Crypto {
  final String name;
  final String symbol;
  double priceUsd;

  Crypto({
    required this.name,
    required this.symbol,
    required this.priceUsd,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      name: json['name'],
      symbol: json['symbol'],
      priceUsd: double.parse(json['price_usd']),
    );
  }
}
