import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> isCurrentUserAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return false;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

  final role = userDoc.data()?['role'] as String?;
  return role == 'admin';
}
