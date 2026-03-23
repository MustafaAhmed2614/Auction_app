import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AuthRepository({required FirebaseFirestore firestore, required FirebaseAuth auth})
      : _firestore = firestore,
        _auth = auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Stream<Map<String, dynamic>?> userProfileStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) => snapshot.data());
  }

  Future<void> signOut() => _auth.signOut();
}
