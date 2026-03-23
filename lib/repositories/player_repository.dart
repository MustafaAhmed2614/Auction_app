import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player.dart';

class PlayerRepository {
  final FirebaseFirestore _firestore;

  PlayerRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<List<Player>> watchPlayers() {
    return _firestore.collection('players').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Player.fromJson(doc.data())).toList();
    });
  }

  Future<void> addPlayer(Player player) async {
    await _firestore.collection('players').doc(player.id).set(player.toJson());
  }

  Future<void> updatePlayerField(String id, Map<String, dynamic> data) async {
    await _firestore.collection('players').doc(id).update(data);
  }

  Future<void> deletePlayer(String id) async {
    await _firestore.collection('players').doc(id).delete();
  }
}
