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
        _initializeDefaultTeams();
        return;
      }
      state = teams;
    }, onError: (e) {
      // Ignore permission errors on logout
    });
  }

  Future<void> _initializeDefaultTeams() async {
    final defaultTeams = [
      Team(id: 'team1', name: 'Team Alpha', logoPath: 'assets/logos/logo1.png'),
      Team(id: 'team2', name: 'Team Braves', logoPath: 'assets/logos/logo2.png'),
      Team(id: 'team3', name: 'Team Challengers', logoPath: 'assets/logos/logo3.png'),
      Team(id: 'team4', name: 'Team Dominators', logoPath: 'assets/logos/logo4.png'),
    ];
    await ref.read(teamRepositoryProvider).initializeDefaultTeams(defaultTeams);
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
