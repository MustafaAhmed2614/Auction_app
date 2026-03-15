import 'team.dart';

class Innings {
  final Team battingTeam;
  int runs;
  int wickets;
  int ballsBowled;
  bool isCompleted;

  Innings({
    required this.battingTeam,
    this.runs = 0,
    this.wickets = 0,
    this.ballsBowled = 0,
    this.isCompleted = false,
  });

  // Cricket notation (e.g. 4.3 overs means 4 overs and 3 balls).
  double get overs => (ballsBowled ~/ 6) + ((ballsBowled % 6) / 10.0);

  // True decimal overs for run-rate calculations.
  double get decimalOvers => ballsBowled / 6.0;

  factory Innings.fromJson(Map<String, dynamic> json) {
    return Innings(
      battingTeam: Team.fromJson(
        Map<String, dynamic>.from(json['battingTeam']),
      ),
      runs: json['runs'] as int? ?? 0,
      wickets: json['wickets'] as int? ?? 0,
      ballsBowled: json['ballsBowled'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battingTeam': battingTeam.toJson(),
      'runs': runs,
      'wickets': wickets,
      'ballsBowled': ballsBowled,
      'isCompleted': isCompleted,
    };
  }
}
