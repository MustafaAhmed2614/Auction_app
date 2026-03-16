import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppUserRole { admin, user }

AppUserRole roleFromString(String? value) {
  switch (value) {
    case 'admin':
      return AppUserRole.admin;
    default:
      return AppUserRole.user;
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final userRoleProvider = StreamProvider<AppUserRole>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) {
      return Stream.value(AppUserRole.user);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
      final role = snapshot.data()?['role'] as String?;
      return roleFromString(role);
    });
  });
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider).maybeWhen(
        data: (role) => role == AppUserRole.admin,
        orElse: () => false,
      );
});

Future<void> promoteCurrentUserToAdminForDev() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({'role': 'admin'}, SetOptions(merge: true));
}
