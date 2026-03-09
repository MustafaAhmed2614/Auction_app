import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';

class PlayerNotifier extends Notifier<List<Player>> {
  @override
  List<Player> build() {
    final box = Hive.box<Player>('players');
    return box.values.toList();
  }

  Future<void> addPlayer(String name, String category, int basePrice, String? image) async {
    final box = Hive.box<Player>('players');
    final newPlayer = Player(
      id: const Uuid().v4(),
      name: name,
      category: category,
      basePrice: basePrice,
      image: image,
    );
    await box.put(newPlayer.id, newPlayer);
    state = box.values.toList();
  }

  Future<void> markAsSold(String id) async {
    final box = Hive.box<Player>('players');
    final player = box.get(id);
    if (player != null) {
      player.isSold = true;
      await player.save();
      state = box.values.toList();
    }
  }

  Future<void> markAsUnsold(String id) async {
    final box = Hive.box<Player>('players');
    final player = box.get(id);
    if (player != null) {
      player.isSold = false;
      await player.save();
      state = box.values.toList();
    }
  }

  Future<void> deletePlayer(String id) async {
    final box = Hive.box<Player>('players');
    await box.delete(id);
    state = box.values.toList();
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, List<Player>>(() {
  return PlayerNotifier();
});

final unsoldPlayersProvider = Provider<List<Player>>((ref) {
  final players = ref.watch(playerProvider);
  return players.where((p) => !p.isSold).toList();
});
