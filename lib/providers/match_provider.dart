import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../utils/standings_calculator.dart';
import '../repositories/match_repository.dart';
import '../repositories/firebase_providers.dart';

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepository(firestore: ref.watch(firestoreProvider));
});

class MatchNotifier extends Notifier<List<Match>> {
  @override
  List<Match> build() {
    _listenToMatches();
    return [];
  }

  void _listenToMatches() {
    ref.watch(matchRepositoryProvider).watchMatches().listen((matches) {
      matches.sort((a, b) => a.matchNumber.compareTo(b.matchNumber));
      state = matches;
    }, onError: (e) {
      // Ignore permission errors on logout
    });
  }

  Future<void> generateSchedule(List<Team> teams, {int overs = 5}) async {
    if (teams.length < 4) return; // Expecting exactly 4 teams

    final repo = ref.read(matchRepositoryProvider);
    await repo.clearExistingMatches();

    // Generate Round Robin (6 matches)
    int matchNum = 1;
    for (int i = 0; i < teams.length; i++) {
       for (int j = i + 1; j < teams.length; j++) {
         final m = Match(
           id: const Uuid().v4(),
           team1: teams[i],
           team2: teams[j],
           matchNumber: matchNum++,
           totalOvers: overs,
         );
         await repo.addMatch(m);
       }
    }

    final finalMatch = Match(
      id: const Uuid().v4(),
      team1: teams[0], // Placeholder, will be updated based on points table
      team2: teams[1], // Placeholder
      matchNumber: matchNum,
      totalOvers: overs,
      isFinal: true,
    );
    await repo.addMatch(finalMatch);
  }

  Future<void> updateMatchResult(String matchId, Match updatedMatch, List<Team> allTeams) async {
     await ref.read(matchRepositoryProvider).updateMatchResult(matchId, updatedMatch);
     await _evaluateFinalMatch(allTeams);
  }

  Future<void> _evaluateFinalMatch(List<Team> allTeams) async {
    // Fetch latest matches to ensure we have the most up-to-date state
    final allMatches = await ref.read(matchRepositoryProvider).getLatestMatches();

    final groupMatches = allMatches.where((m) => !m.isFinal).toList();
    if (groupMatches.isEmpty) return;

    // Check if every group match is completed
    if (groupMatches.every((m) => m.isCompleted)) {
      final finalMatch = allMatches.firstWhere((m) => m.isFinal);
      final standings = calculateStandings(allMatches, allTeams);

      if (standings.length >= 2) {
        final top1 = standings[0].team;
        final top2 = standings[1].team;

        if (finalMatch.team1.id != top1.id || finalMatch.team2.id != top2.id) {
          await ref.read(matchRepositoryProvider).updateMatchTeams(finalMatch.id, {
            'team1': top1.toJson(),
            'team2': top2.toJson(),
          });
        }
      }
    }
  }
}

final matchProvider = NotifierProvider<MatchNotifier, List<Match>>(() {
  return MatchNotifier();
});
