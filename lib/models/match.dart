import 'package:hive/hive.dart';
import 'team.dart';
import 'innings.dart';

part 'match.g.dart';

@HiveType(typeId: 4)
class Match extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Team team1;

  @HiveField(2)
  final Team team2;

  @HiveField(3)
  final int matchNumber;

  @HiveField(4)
  final bool isFinal;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  Innings? firstInnings;

  @HiveField(7)
  Innings? secondInnings;

  @HiveField(8)
  Team? winner;

  Match({
    required this.id,
    required this.team1,
    required this.team2,
    required this.matchNumber,
    this.isFinal = false,
    this.isCompleted = false,
    this.firstInnings,
    this.secondInnings,
    this.winner,
  });
}
