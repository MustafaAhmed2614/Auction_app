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

  Future<void> resetApplication() async {
    final firestore = FirebaseFirestore.instance;
    final futures = <Future>[];

    // Reset players
    final playersSnap = await firestore.collection('players').get();
    for (var doc in playersSnap.docs) {
      futures.add(doc.reference.update({
        'isSold': false,
        'teamId': FieldValue.delete(),
        'boughtFor': FieldValue.delete(),
      }));
    }

    // Reset users
    final usersSnap = await firestore.collection('users').get();
    for (var doc in usersSnap.docs) {
      futures.add(doc.reference.update({
        'teamId': FieldValue.delete(),
      }));
    }

    // Delete teams
    final teamsSnap = await firestore.collection('teams').get();
    for (var doc in teamsSnap.docs) {
      futures.add(doc.reference.delete());
    }

    // Delete matches
    final matchesSnap = await firestore.collection('matches').get();
    for (var doc in matchesSnap.docs) {
      futures.add(doc.reference.delete());
    }

    // Delete history
    final historySnap = await firestore.collection('auction_history').get();
    for (var doc in historySnap.docs) {
      futures.add(doc.reference.delete());
    }

    // Delete auction state
    futures.add(firestore.collection('auction').doc('current').delete());

    await Future.wait(futures);
  }
}

final adminUserActionsProvider = Provider<AdminUserActions>((ref) {
  return AdminUserActions();
});
