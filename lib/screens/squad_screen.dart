import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../models/team.dart';

import '../providers/player_provider.dart';
import '../providers/team_provider.dart';

class SquadScreen extends ConsumerWidget {
  final Team team;

  const SquadScreen({super.key, required this.team});

  void _resetTeam(BuildContext context, WidgetRef ref, List<dynamic> boughtPlayers) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Team?'),
        content: const Text('Are you sure you want to remove all players and reset the budget to 100,000 pts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              for (var result in boughtPlayers) {
                ref.read(playerProvider.notifier).markAsUnsold(result.player.id);
                ref.read(historyProvider.notifier).removeResult(result.id);
              }
              ref.read(teamProvider.notifier).resetTeam(team.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Team reset successfully')));
            },
            child: const Text('RESET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _removePlayer(BuildContext context, WidgetRef ref, dynamic result) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Player?'),
        content: Text('Remove ${result.player.name} and refund ${result.finalPrice} pts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              ref.read(teamProvider.notifier).addTeamPoints(team.id, result.finalPrice);
              ref.read(playerProvider.notifier).markAsUnsold(result.player.id);
              ref.read(historyProvider.notifier).removeResult(result.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player removed')));
            },
            child: const Text('REMOVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final teams = ref.watch(teamProvider);
    final currentTeam = teams.firstWhere((t) => t.id == team.id, orElse: () => team);
    
    // Find players bought by this team
    final boughtPlayers = history.where((h) => h.winningTeam.id == currentTeam.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentTeam.name} Squad'),
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reset Team',
            onPressed: () => _resetTeam(context, ref, boughtPlayers),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
             Container(
               padding: const EdgeInsets.all(24),
               color: Colors.black26,
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text('Remaining Budget', style: TextStyle(color: Colors.white70, fontSize: 16)),
                       Text('${currentTeam.remainingPoints} pts', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 28, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       const Text('Squad Size', style: TextStyle(color: Colors.white70, fontSize: 16)),
                       Text('${boughtPlayers.length} players', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                     ],
                   ),
                 ],
               ),
             ),
             Expanded(
               child: boughtPlayers.isEmpty
                  ? const Center(child: Text('No players purchased yet.', style: TextStyle(color: Colors.white, fontSize: 18)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: boughtPlayers.length,
                      itemBuilder: (context, index) {
                        final result = boughtPlayers[index];
                        return Card(
                          color: Colors.white12,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white24,
                              child: Text(result.player.name[0], style: const TextStyle(color: Colors.white)),
                            ),
                            title: Text('${index + 1}. ${result.player.name}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: Text(result.player.category, style: const TextStyle(color: Colors.white70)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('${result.finalPrice} pts', style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () => _removePlayer(context, ref, result),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
             ),
          ],
        ),
      ),
    );
  }
}
