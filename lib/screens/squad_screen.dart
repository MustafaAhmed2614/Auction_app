import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import '../providers/auth_provider.dart';
import '../models/team.dart';
import '../models/auction_result.dart';

import '../providers/player_provider.dart';
import '../providers/team_provider.dart';

class SquadScreen extends ConsumerWidget {
  final Team team;

  const SquadScreen({super.key, required this.team});

  Future<void> _resetTeam(
    BuildContext context,
    WidgetRef ref,
    List<AuctionResult> boughtPlayers,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Team?'),
        content: const Text('Are you sure you want to remove all players and reset the budget to 100,000 pts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final isAdmin = ref.read(isAdminProvider);
              if (!isAdmin) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Only admin can reset teams.')),
                );
                return;
              }

              try {
                int playerUpdateFailures = 0;
                int historyDeleteFailures = 0;

                for (final result in boughtPlayers) {
                  try {
                    await ref
                        .read(playerProvider.notifier)
                        .markAsUnsold(result.player.id);
                  } catch (_) {
                    playerUpdateFailures++;
                  }

                  try {
                    await ref
                        .read(historyProvider.notifier)
                        .removeResult(result.id);
                  } catch (_) {
                    historyDeleteFailures++;
                  }
                }

                await ref.read(teamProvider.notifier).resetTeam(team.id);
                if (!context.mounted || !ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      playerUpdateFailures == 0 && historyDeleteFailures == 0
                          ? 'Team reset successfully'
                          : 'Team reset done with partial issues (player: $playerUpdateFailures, history: $historyDeleteFailures)',
                    ),
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to reset team: $e')),
                );
              }
            },
            child: const Text('RESET', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _removePlayer(
    BuildContext context,
    WidgetRef ref,
    AuctionResult result,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Player?'),
        content: Text('Remove ${result.player.name} and refund ${result.finalPrice} pts?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () async {
              final isAdmin = ref.read(isAdminProvider);
              if (!isAdmin) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Only admin can remove players.')),
                );
                return;
              }

              try {
                await ref.read(teamProvider.notifier).addTeamPoints(team.id, result.finalPrice);
                try {
                  await ref
                      .read(playerProvider.notifier)
                      .markAsUnsold(result.player.id);
                } catch (_) {
                  // Keep processing so history can still be cleaned up.
                }
                await ref.read(historyProvider.notifier).removeResult(result.id);
                if (!context.mounted || !ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Player removed')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to remove player: $e')),
                );
              }
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
    final isAdmin = ref.watch(isAdminProvider);
    final currentTeam = teams.firstWhere((t) => t.id == team.id, orElse: () => team);
    
    // Find players bought by this team
    final boughtPlayers = history.where((h) => h.winningTeam.id == currentTeam.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentTeam.name} Squad'),
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          if (isAdmin)
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
                                if (isAdmin) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                                    onPressed: () => _removePlayer(context, ref, result),
                                  ),
                                ]
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
