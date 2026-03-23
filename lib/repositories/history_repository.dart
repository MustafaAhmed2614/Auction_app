import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/auction_result.dart';

class HistoryRepository {
  final FirebaseFirestore _firestore;

  HistoryRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<List<AuctionResult>> watchHistory() {
    return _firestore.collection('auction_results').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AuctionResult.fromJson(doc.data())).toList();
    });
  }

  Future<void> addResult(AuctionResult result) async {
    await _firestore.collection('auction_results').doc(result.id).set(result.toJson());
  }

  Future<void> removeResult(String resultId) async {
    await _firestore.collection('auction_results').doc(resultId).delete();
  }
}
