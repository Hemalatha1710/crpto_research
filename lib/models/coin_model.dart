class CoinModel {
  final String id;
  final String name;
  final String symbol;
  final String image;
  final double price;
  final double marketCap;
  final double volume;
  final double priceChange;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;

  CoinModel({
    required this.id,
    required this.name,
    required this.symbol,
    required this.image,
    required this.price,
    required this.marketCap,
    required this.volume,
    required this.priceChange,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      image: json['image'] ?? '',
      price: (json['current_price'] as num?)?.toDouble() ?? 0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      volume: (json['total_volume'] as num?)?.toDouble() ?? 0,
      priceChange:
      (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      circulatingSupply:
      (json['circulating_supply'] as num?)?.toDouble(),
      totalSupply: (json['total_supply'] as num?)?.toDouble(),
      maxSupply: (json['max_supply'] as num?)?.toDouble(),
    );
  }
}