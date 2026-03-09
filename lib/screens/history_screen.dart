import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';

class AuctionHistoryScreen extends ConsumerWidget {
  const AuctionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Auction History'),
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
        child: history.isEmpty
            ? const Center(child: Text('No auction history yet.', style: TextStyle(color: Colors.white, fontSize: 18)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final result = history[index];
                  return Card(
                    color: Colors.white12,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFFFD700),
                        child: Text(result.player.name[0], style: const TextStyle(color: Colors.black)),
                      ),
                      title: Text('${result.player.name} (${result.player.category})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text('Sold to: ${result.winningTeam.name}\nTime: ${result.timestamp.hour}:${result.timestamp.minute.toString().padLeft(2, '0')}', style: const TextStyle(color: Colors.white70)),
                      trailing: Text('${result.finalPrice} pts', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
