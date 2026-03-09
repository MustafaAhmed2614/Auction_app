import 'package:hive/hive.dart';
import 'team.dart';

part 'innings.g.dart';

@HiveType(typeId: 3)
class Innings extends HiveObject {
  @HiveField(0)
  final Team battingTeam;

  @HiveField(1)
  int runs;

  @HiveField(2)
  int wickets;

  @HiveField(3)
  int ballsBowled;

  @HiveField(4)
  bool isCompleted;

  Innings({
    required this.battingTeam,
    this.runs = 0,
    this.wickets = 0,
    this.ballsBowled = 0,
    this.isCompleted = false,
  });

  double get overs => (ballsBowled ~/ 6) + ((ballsBowled % 6) / 10.0);
}
