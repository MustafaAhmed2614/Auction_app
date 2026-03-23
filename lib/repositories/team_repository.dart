import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/team.dart';

class TeamRepository {
  final FirebaseFirestore _firestore;

  TeamRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<List<Team>> watchTeams() {
    return _firestore.collection('teams').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Team.fromJson(doc.data())).toList();
    });
  }

  Future<void> initializeDefaultTeams(List<Team> defaultTeams) async {
    final batch = _firestore.batch();
    for (var team in defaultTeams) {
      final docRef = _firestore.collection('teams').doc(team.id);
      batch.set(docRef, team.toJson());
    }
    await batch.commit();
  }

  Future<void> addTeam(Team team) async {
    await _firestore.collection('teams').doc(team.id).set(team.toJson());
  }

  Future<void> updateTeamPoints(String teamId, int previousPoints, int deductedAmount) async {
    final teamRef = _firestore.collection('teams').doc(teamId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(teamRef);
      if (snapshot.exists) {
        final currentRemaining = snapshot.data()?['remainingPoints'] as int? ?? previousPoints;
        transaction.update(teamRef, {'remainingPoints': currentRemaining - deductedAmount});
      }
    });
  }

  Future<void> addTeamPoints(String teamId, int amount) async {
    final teamRef = _firestore.collection('teams').doc(teamId);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(teamRef);
      if (snapshot.exists) {
        final currentRemaining = snapshot.data()?['remainingPoints'] as int? ?? 0;
        transaction.update(teamRef, {'remainingPoints': currentRemaining + amount});
      }
    });
  }

  Future<void> resetTeamPoints(String teamId) async {
    await _firestore.collection('teams').doc(teamId).update({'remainingPoints': 100000});
  }

  Future<void> deleteTeam(String teamId) async {
    await _firestore.collection('teams').doc(teamId).delete();
  }
}
