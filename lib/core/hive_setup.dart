import 'package:hive_flutter/hive_flutter.dart';
import '../models/team.dart';
import '../models/player.dart';
import '../models/auction_result.dart';
import '../models/match.dart';
import '../models/innings.dart';

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TeamAdapter());
    Hive.registerAdapter(PlayerAdapter());
    Hive.registerAdapter(AuctionResultAdapter());
    Hive.registerAdapter(MatchAdapter());
    Hive.registerAdapter(InningsAdapter());

    // Open boxes
    await Hive.openBox<Team>('teams');
    await Hive.openBox<Player>('players');
    await Hive.openBox<AuctionResult>('auction_results');
    await Hive.openBox<Match>('matches');

    // Pre-populate teams if empty
    final teamsBox = Hive.box<Team>('teams');
    if (teamsBox.isEmpty) {
      final defaultTeams = [
        Team(id: '1', name: 'Team Alpha', logo: 'assets/team_alpha.png', remainingPoints: 100000),
        Team(id: '2', name: 'Team Beta', logo: 'assets/team_beta.png', remainingPoints: 100000),
        Team(id: '3', name: 'Team Gamma', logo: 'assets/team_gamma.png', remainingPoints: 100000),
        Team(id: '4', name: 'Team Delta', logo: 'assets/team_delta.png', remainingPoints: 100000),
      ];
      for (var team in defaultTeams) {
        await teamsBox.put(team.id, team);
      }
    }
  }
}
