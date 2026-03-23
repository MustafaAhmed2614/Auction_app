import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/match.dart';

class MatchRepository {
  final FirebaseFirestore _firestore;

  MatchRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<List<Match>> watchMatches() {
    return _firestore.collection('matches').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Match.fromJson(doc.data())).toList();
    });
  }

  Future<void> clearExistingMatches() async {
    final matches = await _firestore.collection('matches').get();
    for (var doc in matches.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> addMatch(Match match) async {
    await _firestore.collection('matches').doc(match.id).set(match.toJson());
  }

  Future<void> updateMatchResult(String matchId, Match match) async {
    await _firestore.collection('matches').doc(matchId).update(match.toJson());
  }

  Future<List<Match>> getLatestMatches() async {
    final snapshot = await _firestore.collection('matches').get();
    return snapshot.docs.map((doc) => Match.fromJson(doc.data())).toList();
  }

  Future<void> updateMatchTeams(String matchId, Map<String, dynamic> teamsData) async {
    await _firestore.collection('matches').doc(matchId).update(teamsData);
  }
}
