import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/auction_result.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../utils/access_control.dart';
import '../repositories/history_repository.dart';
import '../repositories/firebase_providers.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(firestore: ref.watch(firestoreProvider));
});

class HistoryNotifier extends Notifier<List<AuctionResult>> {
  @override
  List<AuctionResult> build() {
    _listenToHistory();
    return [];
  }

  void _listenToHistory() {
    ref.watch(historyRepositoryProvider).watchHistory().listen(
      (results) {
        results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        state = results;
      },
      onError: (e) {
        // Ignore permission errors on logout
      },
    );
  }

  Future<void> addResult(
    Player player,
    Team winningTeam,
    int finalPrice,
  ) async {
    if (!await isCurrentUserAdmin()) return;

    final result = AuctionResult(
      id: const Uuid().v4(),
      player: player,
      winningTeam: winningTeam,
      finalPrice: finalPrice,
      timestamp: DateTime.now(),
    );
    await ref.read(historyRepositoryProvider).addResult(result);
  }

  Future<void> removeResult(String resultId) async {
    if (!await isCurrentUserAdmin()) return;

    await ref.read(historyRepositoryProvider).removeResult(resultId);
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<AuctionResult>>(
  () {
    return HistoryNotifier();
  },
);
