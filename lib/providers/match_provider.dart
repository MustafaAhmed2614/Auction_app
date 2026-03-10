import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../utils/standings_calculator.dart';

class MatchNotifier extends Notifier<List<Match>> {
  @override
  List<Match> build() {
    _listenToMatches();
    return [];
  }

  void _listenToMatches() {
    FirebaseFirestore.instance.collection('matches').snapshots().listen((snapshot) {
      final matches = snapshot.docs.map((doc) => Match.fromJson(doc.data())).toList();
      matches.sort((a, b) => a.matchNumber.compareTo(b.matchNumber));
      state = matches;
    });
  }

  Future<void> generateSchedule(List<Team> teams) async {
    if (teams.length < 4) return; // Expecting exactly 4 teams

    final matchCollection = FirebaseFirestore.instance.collection('matches');
    
    // Clear existing schedule if any
    final existingMatches = await matchCollection.get();
    for (var doc in existingMatches.docs) {
      await doc.reference.delete();
    }

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
         await matchCollection.doc(m.id).set(m.toJson());
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
    await matchCollection.doc(finalMatch.id).set(finalMatch.toJson());
  }

  Future<void> updateMatchResult(String matchId, Match updatedMatch, List<Team> allTeams) async {
     await FirebaseFirestore.instance.collection('matches').doc(matchId).update(updatedMatch.toJson());
     await _evaluateFinalMatch(allTeams);
  }

  Future<void> _evaluateFinalMatch(List<Team> allTeams) async {
    // Fetch latest matches to ensure we have the most up-to-date state
    final snapshot = await FirebaseFirestore.instance.collection('matches').get();
    final allMatches = snapshot.docs.map((doc) => Match.fromJson(doc.data())).toList();

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
          await FirebaseFirestore.instance.collection('matches').doc(finalMatch.id).update({
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
