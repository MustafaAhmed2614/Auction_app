import '../models/match.dart';
import '../models/team.dart';

class TeamStats {
  final Team team;
  int matchesPlayed = 0;
  int won = 0;
  int lost = 0;
  int tied = 0;
  int get points => (won * 2) + (tied * 1);
  double nrr = 0.0;
  
  // NRR Calculation components
  int totalRunsScored = 0;
  double totalOversFaced = 0.0;
  int totalRunsConceded = 0;
  double totalOversBowled = 0.0;

  TeamStats(this.team);
}

List<TeamStats> calculateStandings(List<Match> matches, List<Team> teams) {
  Map<String, TeamStats> statsMap = {};
  for (var team in teams) {
    statsMap[team.id] = TeamStats(team);
  }

  // Only consider non-final completed matches
  final groupMatches = matches.where((m) => m.isCompleted && !m.isFinal);

  for (var match in groupMatches) {
    if (match.firstInnings == null || match.secondInnings == null) continue;

    final inn1 = match.firstInnings!;
    final inn2 = match.secondInnings!;
    
    // Assign stats targets
    final t1Stat = statsMap[inn1.battingTeam.id]!;
    final t2Stat = statsMap[inn2.battingTeam.id]!;

    t1Stat.matchesPlayed++;
    t2Stat.matchesPlayed++;

    // Calculate result
    if (inn1.runs > inn2.runs) {
      t1Stat.won++;
      t2Stat.lost++;
    } else if (inn2.runs > inn1.runs) {
      t2Stat.won++;
      t1Stat.lost++;
    } else {
      t1Stat.tied++;
      t2Stat.tied++;
    }

    // Accumulate NRR components
    double inn1Faced = inn1.wickets == 10 ? 5.0 : inn1.overs; 
    double inn2Faced = inn2.wickets == 10 ? 5.0 : inn2.overs;

    t1Stat.totalRunsScored += inn1.runs;
    t1Stat.totalOversFaced += inn1Faced;
    t1Stat.totalRunsConceded += inn2.runs;
    t1Stat.totalOversBowled += inn2Faced;

    t2Stat.totalRunsScored += inn2.runs;
    t2Stat.totalOversFaced += inn2Faced;
    t2Stat.totalRunsConceded += inn1.runs;
    t2Stat.totalOversBowled += inn1Faced;
  }

  // Calculate final NRR
  for (var stat in statsMap.values) {
    double runRateFor = stat.totalOversFaced > 0 ? stat.totalRunsScored / stat.totalOversFaced : 0.0;
    double runRateAgainst = stat.totalOversBowled > 0 ? stat.totalRunsConceded / stat.totalOversBowled : 0.0;
    stat.nrr = runRateFor - runRateAgainst;
  }

  final sortedStats = statsMap.values.toList();
  // Sort by Points, then by NRR
  sortedStats.sort((a, b) {
    int pointCompare = b.points.compareTo(a.points);
    if (pointCompare != 0) return pointCompare;
    return b.nrr.compareTo(a.nrr);
  });

  return sortedStats;
}
