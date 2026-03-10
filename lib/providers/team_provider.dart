import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';

class TeamNotifier extends Notifier<List<Team>> {
  @override
  List<Team> build() {
    _listenToTeams();
    return [];
  }

  void _listenToTeams() {
    FirebaseFirestore.instance.collection('teams').snapshots().listen((snapshot) {
      if (snapshot.docs.isEmpty) {
        _initializeDefaultTeams();
        return;
      }
      final teams = snapshot.docs.map((doc) => Team.fromJson(doc.data())).toList();
      state = teams;
    });
  }

  Future<void> _initializeDefaultTeams() async {
    final defaultTeams = [
      Team(id: 'team1', name: 'Team Alpha', logoPath: 'assets/logos/logo1.png'),
      Team(id: 'team2', name: 'Team Braves', logoPath: 'assets/logos/logo2.png'),
      Team(id: 'team3', name: 'Team Challengers', logoPath: 'assets/logos/logo3.png'),
      Team(id: 'team4', name: 'Team Dominators', logoPath: 'assets/logos/logo4.png'),
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (var team in defaultTeams) {
      final docRef = FirebaseFirestore.instance.collection('teams').doc(team.id);
      batch.set(docRef, team.toJson());
    }
    await batch.commit();
  }

  Future<void> updateTeamPoints(String teamId, int previousPoints, int deductedAmount) async {
    final teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(teamRef);
      if (snapshot.exists) {
        final currentRemaining = snapshot.data()?['remainingPoints'] as int? ?? previousPoints;
        transaction.update(teamRef, {'remainingPoints': currentRemaining - deductedAmount});
      }
    });
  }

  Future<void> addTeamPoints(String teamId, int amount) async {
    final teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(teamRef);
      if (snapshot.exists) {
        final currentRemaining = snapshot.data()?['remainingPoints'] as int? ?? 0;
        transaction.update(teamRef, {'remainingPoints': currentRemaining + amount});
      }
    });
  }

  Future<void> resetTeam(String teamId) async {
    final teamRef = FirebaseFirestore.instance.collection('teams').doc(teamId);
    await teamRef.update({'remainingPoints': 100000});
  }

  Future<void> addTeam(String name, int budget, String logoPath) async {
    final newTeam = Team(
      id: 'team_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      logoPath: logoPath,
      remainingPoints: budget,
    );
    await FirebaseFirestore.instance.collection('teams').doc(newTeam.id).set(newTeam.toJson());
  }

  Future<void> deleteTeam(String teamId) async {
    await FirebaseFirestore.instance.collection('teams').doc(teamId).delete();
  }

  Future<void> addPlayerToSquad(String teamId, String playerId) async {
      // Logic managed implicitly via History collection
  }
}

final teamProvider = NotifierProvider<TeamNotifier, List<Team>>(() {
  return TeamNotifier();
});
