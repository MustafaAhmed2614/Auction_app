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

final currentUserProvider = Provider<User?>((ref) {
  return ref
      .watch(authStateChangesProvider)
      .maybeWhen(data: (user) => user, orElse: () => null);
});

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) => snapshot.data());
});

final userRoleProvider = Provider<AppUserRole>((ref) {
  final profile = ref
      .watch(userProfileProvider)
      .maybeWhen(data: (data) => data, orElse: () => null);
  final role = profile?['role'] as String?;
  return roleFromString(role);
});

final currentUserTeamIdProvider = Provider<String?>((ref) {
  final profile = ref
      .watch(userProfileProvider)
      .maybeWhen(data: (data) => data, orElse: () => null);
  final teamId = profile?['teamId'];
  if (teamId is String && teamId.trim().isNotEmpty) {
    return teamId;
  }
  return null;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == AppUserRole.admin;
});

