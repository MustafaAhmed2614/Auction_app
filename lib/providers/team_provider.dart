import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team.dart';
import '../utils/access_control.dart';
import '../repositories/team_repository.dart';
import '../repositories/firebase_providers.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return TeamRepository(firestore: ref.watch(firestoreProvider));
});

class TeamNotifier extends Notifier<List<Team>> {
  @override
  List<Team> build() {
    _listenToTeams();
    return [];
  }

  void _listenToTeams() {
    ref.watch(teamRepositoryProvider).watchTeams().listen((teams) {
      if (teams.isEmpty) {
        state = [];
        return;
      }
      state = teams;
    }, onError: (e) {
      // Ignore permission errors on logout
    });
  }

  Future<void> updateTeamName(String teamId, String newName) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(teamRepositoryProvider).updateTeamName(teamId, newName);
  }

  Future<void> setTeamBudget(String teamId, int newBudget) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(teamRepositoryProvider).setTeamBudget(teamId, newBudget);
  }

  Future<void> updateTeamPoints(String teamId, int previousPoints, int deductedAmount) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(teamRepositoryProvider).updateTeamPoints(teamId, previousPoints, deductedAmount);
  }

  Future<void> addTeamPoints(String teamId, int amount) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(teamRepositoryProvider).addTeamPoints(teamId, amount);
  }

  Future<void> resetTeam(String teamId) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(teamRepositoryProvider).resetTeamPoints(teamId);
  }

  Future<void> addTeam(String name, int budget, String logoPath) async {
    if (!await isCurrentUserAdmin()) return;
    final newTeam = Team(
      id: 'team_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      logoPath: logoPath,
      remainingPoints: budget,
    );
    await ref.read(teamRepositoryProvider).addTeam(newTeam);
  }

  Future<void> deleteTeam(String teamId) async {
    if (!await isCurrentUserAdmin()) return;
    await ref.read(teamRepositoryProvider).deleteTeam(teamId);
  }

  Future<void> addPlayerToSquad(String teamId, String playerId) async {
    if (!await isCurrentUserAdmin()) return;
    // Logic managed implicitly via History collection
  }
}

final teamProvider = NotifierProvider<TeamNotifier, List<Team>>(() {
  return TeamNotifier();
});
