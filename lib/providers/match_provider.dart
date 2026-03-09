import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/match.dart';
import '../models/team.dart';

class MatchNotifier extends Notifier<List<Match>> {
  @override
  List<Match> build() {
    final box = Hive.box<Match>('matches');
    return box.values.toList()..sort((a, b) => a.matchNumber.compareTo(b.matchNumber));
  }

  Future<void> generateSchedule() async {
    final teamsBox = Hive.box<Team>('teams');
    final teams = teamsBox.values.toList();
    if (teams.length < 4) return; // Expecting exactly 4 teams

    final matchBox = Hive.box<Match>('matches');
    
    // Clear existing schedule if any
    await matchBox.clear();

    // Generate Round Robin (6 matches)
    int matchNum = 1;
    for (int i = 0; i < teams.length; i++) {
       for (int j = i + 1; j < teams.length; j++) {
         final m = Match(
           id: const Uuid().v4(),
           team1: teams[i],
           team2: teams[j],
           matchNumber: matchNum++,
         );
         await matchBox.put(m.id, m);
       }
    }

    // Add Placeholder for Final (Match 7)
    final finalMatch = Match(
      id: const Uuid().v4(),
      team1: teams[0], // Placeholder, will be updated based on points table
      team2: teams[1], // Placeholder
      matchNumber: matchNum,
      isFinal: true,
    );
    await matchBox.put(finalMatch.id, finalMatch);

    state = matchBox.values.toList()..sort((a, b) => a.matchNumber.compareTo(b.matchNumber));
  }

  Future<void> updateMatchResult(String matchId, Match updatedMatch) async {
     final box = Hive.box<Match>('matches');
     await box.put(matchId, updatedMatch);
     state = box.values.toList()..sort((a, b) => a.matchNumber.compareTo(b.matchNumber));
  }
}

final matchProvider = NotifierProvider<MatchNotifier, List<Match>>(() {
  return MatchNotifier();
});
