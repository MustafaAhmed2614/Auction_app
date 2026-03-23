import 'team.dart';
import 'innings.dart';

class Match {
  final String id;
  final Team team1;
  final Team team2;
  final int matchNumber;
  final int totalOvers;
  final bool isFinal;
  bool isCompleted;
  Innings? firstInnings;
  Innings? secondInnings;
  Team? winner;

  Match({
    required this.id,
    required this.team1,
    required this.team2,
    required this.matchNumber,
    this.totalOvers = 5,
    this.isFinal = false,
    this.isCompleted = false,
    this.firstInnings,
    this.secondInnings,
    this.winner,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      team1: Team.fromJson(Map<String, dynamic>.from(json['team1'])),
      team2: Team.fromJson(Map<String, dynamic>.from(json['team2'])),
      matchNumber: json['matchNumber'] as int,
      totalOvers: json['totalOvers'] as int? ?? 5,
      isFinal: json['isFinal'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      firstInnings: json['firstInnings'] != null ? Innings.fromJson(Map<String, dynamic>.from(json['firstInnings'])) : null,
      secondInnings: json['secondInnings'] != null ? Innings.fromJson(Map<String, dynamic>.from(json['secondInnings'])) : null,
      winner: json['winner'] != null ? Team.fromJson(Map<String, dynamic>.from(json['winner'])) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team1': team1.toJson(),
      'team2': team2.toJson(),
      'matchNumber': matchNumber,
      'totalOvers': totalOvers,
      'isFinal': isFinal,
      'isCompleted': isCompleted,
      'firstInnings': firstInnings?.toJson(),
      'secondInnings': secondInnings?.toJson(),
      'winner': winner?.toJson(),
    };
  }
}
