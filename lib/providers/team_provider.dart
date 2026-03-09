import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/team.dart';

class TeamNotifier extends Notifier<List<Team>> {
  @override
  List<Team> build() {
    final box = Hive.box<Team>('teams');
    return box.values.toList();
  }

  Future<void> updateTeamPoints(String teamId, int previousPoints, int deductedAmount) async {
    final box = Hive.box<Team>('teams');
    final team = box.get(teamId);
    if (team != null) {
      team.remainingPoints -= deductedAmount;
      await team.save();
      state = box.values.toList();
    }
  }

  Future<void> addTeamPoints(String teamId, int amount) async {
    final box = Hive.box<Team>('teams');
    final team = box.get(teamId);
    if (team != null) {
      team.remainingPoints += amount;
      await team.save();
      state = box.values.toList();
    }
  }

  Future<void> resetTeam(String teamId) async {
    final box = Hive.box<Team>('teams');
    final team = box.get(teamId);
    if (team != null) {
      team.remainingPoints = 100000; // Default budget
      await team.save();
      state = box.values.toList();
    }
  }

  Future<void> addPlayerToSquad(String teamId, String playerId) async {
      // In Hive, HiveList is used for relationships, but for simplicity we can just rely on the Player's winningTeam field
      // Or we can add it to the squad if initialized.
      // Since it's a bit complex with HiveList, we'll fetch team squad by querying players box instead when needed,
      // or we just update the team's remaining points here.
      state = Hive.box<Team>('teams').values.toList();
  }
}

final teamProvider = NotifierProvider<TeamNotifier, List<Team>>(() {
  return TeamNotifier();
});
