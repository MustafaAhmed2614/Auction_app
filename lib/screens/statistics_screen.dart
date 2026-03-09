import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/team_provider.dart';
import '../providers/history_provider.dart';
import '../providers/player_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamProvider);
    final history = ref.watch(historyProvider);
    final allPlayers = ref.watch(playerProvider);

    final mostExpensive = history.isEmpty ? null : history.reduce((curr, next) => curr.finalPrice > next.finalPrice ? curr : next);
    final totalSpent = history.isEmpty ? 0 : history.map((e) => e.finalPrice).reduce((a, b) => a + b);
    final playersSold = history.length;
    final playersUnsold = allPlayers.length - playersSold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BPL Statistics'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStatCard('Most Expensive Player', mostExpensive != null ? '${mostExpensive.player.name} (${mostExpensive.finalPrice} pts)' : 'N/A', Icons.monetization_on, Colors.amber),
            _buildStatCard('Total Points Spent', '$totalSpent pts', Icons.account_balance_wallet, Colors.greenAccent),
            _buildStatCard('Players Sold vs Unsold', '$playersSold Sold / $playersUnsold Unsold', Icons.people, Colors.blueAccent),
            
            const SizedBox(height: 24),
            const Text('Remaining Budgets', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            ...teams.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(t.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                   Text('${t.remainingPoints} pts', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(icon, size: 48, color: iconColor),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
