import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/points_table_provider.dart';

class PointsTableScreen extends ConsumerWidget {
  const PointsTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final standings = ref.watch(pointsTableProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BPL Points Table'),
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
        child: Column(
          children: [
            Container(
              color: Colors.black45,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('M', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('W', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('L', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  Expanded(flex: 1, child: Text('Pt', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text('NRR', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: standings.length,
                itemBuilder: (context, index) {
                  final stat = standings[index];
                  final isTopTwo = index < 2; // Finalists
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isTopTwo ? Colors.green.withValues(alpha: 0.2) : Colors.transparent,
                      border: const Border(bottom: BorderSide(color: Colors.white12)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3, 
                          child: Row(
                            children: [
                              Text('${index + 1}. ', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                              Expanded(child: Text(stat.team.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis))),
                            ]
                          )
                        ),
                        Expanded(flex: 1, child: Text('${stat.matchesPlayed}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))),
                        Expanded(flex: 1, child: Text('${stat.won}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.greenAccent))),
                        Expanded(flex: 1, child: Text('${stat.lost}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent))),
                        Expanded(flex: 1, child: Text('${stat.points}', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16))),
                        Expanded(flex: 2, child: Text(stat.nrr.toStringAsFixed(3), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
               padding: const EdgeInsets.all(16),
               color: Colors.black26,
               child: const Text('Top 2 teams qualify for the Final.', style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic)),
            )
          ],
        ),
      ),
    );
  }
}
