import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/auction_result.dart';
import '../models/player.dart';
import '../models/team.dart';

class HistoryNotifier extends Notifier<List<AuctionResult>> {
  @override
  List<AuctionResult> build() {
    final box = Hive.box<AuctionResult>('auction_results');
    return box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addResult(Player player, Team winningTeam, int finalPrice) async {
    final box = Hive.box<AuctionResult>('auction_results');
    final result = AuctionResult(
      id: const Uuid().v4(),
      player: player,
      winningTeam: winningTeam,
      finalPrice: finalPrice,
      timestamp: DateTime.now(),
    );
    await box.put(result.id, result);
    state = box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> removeResult(String resultId) async {
    final box = Hive.box<AuctionResult>('auction_results');
    await box.delete(resultId);
    state = box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<AuctionResult>>(() {
  return HistoryNotifier();
});
