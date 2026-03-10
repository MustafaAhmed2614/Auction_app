class Player {
  final String id;
  final String name;
  final String category;
  final int basePrice;
  final String? image;
  bool isSold;

  Player({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    this.image,
    this.isSold = false,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      basePrice: json['basePrice'] as int,
      image: json['image'] as String?,
      isSold: json['isSold'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'basePrice': basePrice,
      'image': image,
      'isSold': isSold,
    };
  }
}
