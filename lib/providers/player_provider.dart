import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../utils/access_control.dart';
import '../repositories/player_repository.dart';
import '../repositories/firebase_providers.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(firestore: ref.watch(firestoreProvider));
});

class PlayerNotifier extends Notifier<List<Player>> {
  @override
  List<Player> build() {
    _listenToPlayers();
    return [];
  }

  void _listenToPlayers() {
    ref.watch(playerRepositoryProvider).watchPlayers().listen((players) {
      state = players;
    }, onError: (e) {
      // Ignore permission errors on logout
    });
  }

  Future<void> addPlayer(
    String name,
    String category,
    int basePrice,
    String? image,
  ) async {
    if (!await isCurrentUserAdmin()) return;

    final newPlayer = Player(
      id: const Uuid().v4(),
      name: name,
      category: category,
      basePrice: basePrice,
      image: image,
    );
    await ref.read(playerRepositoryProvider).addPlayer(newPlayer);
  }

  Future<void> markAsSold(String id) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(playerRepositoryProvider).updatePlayerField(id, {'isSold': true});
  }

  Future<void> markAsUnsold(String id) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(playerRepositoryProvider).updatePlayerField(id, {'isSold': false});
  }

  Future<void> deletePlayer(String id) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(playerRepositoryProvider).deletePlayer(id);
  }
}

final playerProvider = NotifierProvider<PlayerNotifier, List<Player>>(() {
  return PlayerNotifier();
});

final unsoldPlayersProvider = Provider<List<Player>>((ref) {
  final players = ref.watch(playerProvider);
  return players.where((p) => !p.isSold).toList();
});
