import 'package:hive/hive.dart';
import 'player.dart';
import 'team.dart';

part 'auction_result.g.dart';

@HiveType(typeId: 2)
class AuctionResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Player player;

  @HiveField(2)
  final Team winningTeam;

  @HiveField(3)
  final int finalPrice;

  @HiveField(4)
  final DateTime timestamp;

  AuctionResult({
    required this.id,
    required this.player,
    required this.winningTeam,
    required this.finalPrice,
    required this.timestamp,
  });
}
