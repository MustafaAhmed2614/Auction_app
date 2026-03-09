import 'package:hive/hive.dart';
import 'player.dart';

part 'team.g.dart';

@HiveType(typeId: 0)
class Team extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String logo;

  @HiveField(3)
  int remainingPoints;

  @HiveField(4)
  HiveList<Player>? squadPlayers;

  Team({
    required this.id,
    required this.name,
    required this.logo,
    required this.remainingPoints,
  });
}
