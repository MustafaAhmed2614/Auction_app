import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../utils/access_control.dart';

class PlayerNotifier extends Notifier<List<Player>> {
  @override
  List<Player> build() {
    _listenToPlayers();
    return [];
  }

  void _listenToPlayers() {
     FirebaseFirestore.instance.collection('players').snapshots().listen((snapshot) {
      final players = snapshot.docs.map((doc) => Player.fromJson(doc.data())).toList();
      state = players;
    });
  }

  Future<void> addPlayer(String name, String category, int basePrice, String? image) async {
    if (!await isCurrentUserAdmin()) return;

    final newPlayer = Player(
      id: const Uuid().v4(),
      name: name,
      category: category,
      basePrice: basePrice,
      image: image,
    );
    await FirebaseFirestore.instance.collection('players').doc(newPlayer.id).set(newPlayer.toJson());
  }

  Future<void> markAsSold(String id) async {
    if (!await isCurrentUserAdmin()) return;

    await FirebaseFirestore.instance.collection('players').doc(id).update({'isSold': true});
  }

  Future<void> markAsUnsold(String id) async {
    if (!await isCurrentUserAdmin()) return;

    await FirebaseFirestore.instance.collection('players').doc(id).update({'isSold': false});
  }

  Future<void> deletePlayer(String id) async {
    if (!await isCurrentUserAdmin()) return;

    await FirebaseFirestore.instance.collection('players').doc(id).delete();
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, List<Player>>(() {
  return PlayerNotifier();
});

final unsoldPlayersProvider = Provider<List<Player>>((ref) {
  final players = ref.watch(playerProvider);
  return players.where((p) => !p.isSold).toList();
});
