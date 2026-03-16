import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user_profile.dart';

final allUsersProvider = StreamProvider<List<AppUserProfile>>((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots().map((snap) {
    final users = snap.docs
        .map((doc) => AppUserProfile.fromJson(doc.id, doc.data()))
        .toList();
    users.sort((a, b) => a.email.compareTo(b.email));
    return users;
  });
});

class AdminUserActions {
  Future<void> updateUserRoleAndTeam({
    required String uid,
    required String role,
    String? teamId,
  }) async {
    final payload = <String, dynamic>{'role': role};
    if (teamId == null || teamId.trim().isEmpty) {
      payload['teamId'] = FieldValue.delete();
    } else {
      payload['teamId'] = teamId;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(payload, SetOptions(merge: true));
  }
}

final adminUserActionsProvider = Provider<AdminUserActions>((ref) {
  return AdminUserActions();
});
