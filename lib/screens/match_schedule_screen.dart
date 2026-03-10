import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/match.dart';
import 'live_scoring_screen.dart';

class MatchScheduleScreen extends ConsumerWidget {
  const MatchScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BPL Schedule'),
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Generate Schedule',
            onPressed: () {
              final teams = ref.read(teamProvider);
              ref.read(matchProvider.notifier).generateSchedule(teams);
            },
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
        child: matches.isEmpty
            ? Center(
                child: ElevatedButton(
                  onPressed: () {
                    final teams = ref.read(teamProvider);
                    ref.read(matchProvider.notifier).generateSchedule(teams);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                  child: const Text('Generate Tournament Schedule', style: TextStyle(color: Colors.black)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return _buildMatchCard(context, match, matches);
                },
              ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Match match, List<Match> allMatches) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: match.isCompleted ? Colors.green : Colors.white24, width: 1),
      ),
      child: InkWell(
        onTap: () {
          if (match.isFinal) {
            final groupMatches = allMatches.where((m) => !m.isFinal);
            if (!groupMatches.every((m) => m.isCompleted)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Finish all group matches before playing the Final!')),
              );
              return;
            }
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LiveScoringScreen(match: match)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                match.isFinal ? '🏆 BPL FINAL 🏆' : 'Match ${match.matchNumber}',
                style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                         Text(match.team1.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                         if (match.isCompleted && match.firstInnings != null)
                           Text('${match.firstInnings!.runs}/${match.firstInnings!.wickets}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('VS', style: TextStyle(color: Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                         Text(match.team2.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                         if (match.isCompleted && match.secondInnings != null)
                           Text('${match.secondInnings!.runs}/${match.secondInnings!.wickets}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              if (match.isCompleted && match.winner != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                  child: Text('${match.winner!.name} Won', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
