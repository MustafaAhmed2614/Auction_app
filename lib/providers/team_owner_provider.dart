import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auction_result.dart';
import '../models/player.dart';
import '../models/team.dart';
import 'auth_provider.dart';
import 'history_provider.dart';
import 'player_provider.dart';
import 'team_provider.dart';

const int squadTargetSize = 11;

class TeamOwnerWatchlistItem {
  final String playerId;
  final DateTime createdAt;

  TeamOwnerWatchlistItem({required this.playerId, required this.createdAt});
}

class TeamBudgetPlan {
  final int platinum;
  final int gold;
  final int silver;
  final int emerging;

  const TeamBudgetPlan({
    required this.platinum,
    required this.gold,
    required this.silver,
    required this.emerging,
  });

  int get total => platinum + gold + silver + emerging;

  factory TeamBudgetPlan.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const TeamBudgetPlan(
        platinum: 30000,
        gold: 28000,
        silver: 25000,
        emerging: 17000,
      );
    }

    return TeamBudgetPlan(
      platinum: (json['platinum'] as int?) ?? 30000,
      gold: (json['gold'] as int?) ?? 28000,
      silver: (json['silver'] as int?) ?? 25000,
      emerging: (json['emerging'] as int?) ?? 17000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platinum': platinum,
      'gold': gold,
      'silver': silver,
      'emerging': emerging,
    };
  }
}

final myTeamProvider = Provider<Team?>((ref) {
  final myTeamId = ref.watch(currentUserTeamIdProvider);
  final teams = ref.watch(teamProvider);
  if (myTeamId == null) return null;

  try {
    return teams.firstWhere((team) => team.id == myTeamId);
  } catch (_) {
    return null;
  }
});

final myTeamResultsProvider = Provider<List<AuctionResult>>((ref) {
  final teamId = ref.watch(currentUserTeamIdProvider);
  if (teamId == null) return const [];

  final allResults = ref.watch(historyProvider);
  return allResults.where((item) => item.winningTeam.id == teamId).toList();
});

final myTeamSquadProvider = Provider<List<Player>>((ref) {
  final results = ref.watch(myTeamResultsProvider);
  return results.map((r) => r.player).toList();
});

final myTeamSpentProvider = Provider<int>((ref) {
  final results = ref.watch(myTeamResultsProvider);
  return results.fold(0, (total, result) => total + result.finalPrice);
});

final myTeamSlotsLeftProvider = Provider<int>((ref) {
  final squadSize = ref.watch(myTeamSquadProvider).length;
  final remaining = squadTargetSize - squadSize;
  return remaining < 0 ? 0 : remaining;
});

final myTeamWatchlistProvider = StreamProvider<List<TeamOwnerWatchlistItem>>((
  ref,
) {
  final teamId = ref.watch(currentUserTeamIdProvider);
  if (teamId == null) return Stream.value(const []);

  return FirebaseFirestore.instance
      .collection('team_watchlists')
      .doc(teamId)
      .collection('items')
      .snapshots()
      .map((snapshot) {
        final items = snapshot.docs.map((doc) {
          final data = doc.data();
          final timestamp = data['createdAt'];
          final createdAt = timestamp is Timestamp
              ? timestamp.toDate()
              : DateTime.fromMillisecondsSinceEpoch(0);
          return TeamOwnerWatchlistItem(playerId: doc.id, createdAt: createdAt);
        }).toList();
        items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        return items;
      });
});

final myTeamBudgetPlanProvider = StreamProvider<TeamBudgetPlan>((ref) {
  final teamId = ref.watch(currentUserTeamIdProvider);
  if (teamId == null) {
    return Stream.value(TeamBudgetPlan.fromJson(null));
  }

  return FirebaseFirestore.instance
      .collection('team_budget_plans')
      .doc(teamId)
      .snapshots()
      .map((snapshot) => TeamBudgetPlan.fromJson(snapshot.data()));
});

final myTeamPlayerNotesProvider = StreamProvider<Map<String, String>>((ref) {
  final teamId = ref.watch(currentUserTeamIdProvider);
  if (teamId == null) return Stream.value(const {});

  return FirebaseFirestore.instance
      .collection('team_notes')
      .doc(teamId)
      .collection('players')
      .snapshots()
      .map((snapshot) {
        final map = <String, String>{};
        for (final doc in snapshot.docs) {
          final text = doc.data()['text'];
          if (text is String && text.trim().isNotEmpty) {
            map[doc.id] = text;
          }
        }
        return map;
      });
});

class TeamOwnerActions {
  Future<void> toggleWatchlist({
    required String teamId,
    required String playerId,
    required bool shouldWatch,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('team_watchlists')
        .doc(teamId)
        .collection('items')
        .doc(playerId);

    if (shouldWatch) {
      await docRef.set({'createdAt': FieldValue.serverTimestamp()});
    } else {
      await docRef.delete();
    }
  }

  Future<void> saveBudgetPlan({
    required String teamId,
    required TeamBudgetPlan plan,
  }) async {
    await FirebaseFirestore.instance
        .collection('team_budget_plans')
        .doc(teamId)
        .set(plan.toJson(), SetOptions(merge: true));
  }

  Future<void> savePlayerNote({
    required String teamId,
    required String playerId,
    required String note,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('team_notes')
        .doc(teamId)
        .collection('players')
        .doc(playerId);

    if (note.trim().isEmpty) {
      await docRef.delete();
      return;
    }

    await docRef.set({'text': note.trim()}, SetOptions(merge: true));
  }
}

final teamOwnerActionsProvider = Provider<TeamOwnerActions>((ref) {
  return TeamOwnerActions();
});

final myWatchlistPlayersProvider = Provider<List<Player>>((ref) {
  final watchlistIds = ref
      .watch(myTeamWatchlistProvider)
      .maybeWhen(
        data: (items) => items.map((e) => e.playerId).toSet(),
        orElse: () => <String>{},
      );
  final players = ref.watch(playerProvider);
  return players
      .where((p) => watchlistIds.contains(p.id) && !p.isSold)
      .toList();
});
