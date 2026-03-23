import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/auction_provider.dart';

class AuctionRepository {
  final FirebaseFirestore _firestore;

  AuctionRepository({required FirebaseFirestore firestore}) : _firestore = firestore;

  Stream<AuctionState?> watchCurrentAuction() {
    return _firestore.collection('auction').doc('current').snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AuctionState.fromJson(snapshot.data()!);
      }
      return null;
    });
  }

  Future<void> syncState(AuctionState newState) async {
    await _firestore.collection('auction').doc('current').set(newState.toJson());
  }

  Future<T> runTransaction<T>(Future<T> Function(Transaction) updateFunction) {
    return _firestore.runTransaction(updateFunction);
  }

  DocumentReference getAuctionRef() => _firestore.collection('auction').doc('current');
  CollectionReference getPlayerRef() => _firestore.collection('players');
  CollectionReference getTeamRef() => _firestore.collection('teams');
  CollectionReference getHistoryRef() => _firestore.collection('auction_results');
}
