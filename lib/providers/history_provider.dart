import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/auction_result.dart';
import '../models/player.dart';
import '../models/team.dart';
import '../utils/access_control.dart';

class HistoryNotifier extends Notifier<List<AuctionResult>> {
  @override
  List<AuctionResult> build() {
    _listenToHistory();
    return [];
  }

  void _listenToHistory() {
    FirebaseFirestore.instance.collection('auction_results').snapshots().listen((snapshot) {
      final results = snapshot.docs.map((doc) => AuctionResult.fromJson(doc.data())).toList();
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = results;
    });
  }

  Future<void> addResult(Player player, Team winningTeam, int finalPrice) async {
    if (!await isCurrentUserAdmin()) return;

    final result = AuctionResult(
      id: const Uuid().v4(),
      player: player,
      winningTeam: winningTeam,
      finalPrice: finalPrice,
      timestamp: DateTime.now(),
    );
    await FirebaseFirestore.instance.collection('auction_results').doc(result.id).set(result.toJson());
  }

  Future<void> removeResult(String resultId) async {
    if (!await isCurrentUserAdmin()) return;

    await FirebaseFirestore.instance.collection('auction_results').doc(resultId).delete();
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, List<AuctionResult>>(() {
  return HistoryNotifier();
});
