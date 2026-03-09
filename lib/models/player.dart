import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 1)
class Player extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final int basePrice;

  @HiveField(4)
  final String? image;

  @HiveField(5)
  bool isSold;

  Player({
    required this.id,
    required this.name,
    required this.category,
    required this.basePrice,
    this.image,
    this.isSold = false,
  });
}
