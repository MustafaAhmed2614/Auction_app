import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/match.dart';
import 'live_scoring_screen.dart';
import '../providers/auth_provider.dart';

class MatchScheduleScreen extends ConsumerWidget {
  const MatchScheduleScreen({super.key});

  void _promptForOversAndGenerate(BuildContext context, WidgetRef ref) {
    final teams = ref.read(teamProvider);
    if (teams.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Need at least 4 teams to generate schedule.')),
      );
      return;
    }

    int selectedOvers = 5;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Generate Schedule', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many overs per innings?', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Overs',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
                onChanged: (val) {
                  selectedOvers = int.tryParse(val) ?? 5;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(matchProvider.notifier).generateSchedule(teams, overs: selectedOvers);
              },
              child: const Text('Generate', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _promptForMatchOversAndStart(BuildContext context, WidgetRef ref, Match match) {
    int selectedOvers = match.totalOvers;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Start Match', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Initialize scoring for Match ${match.matchNumber}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Match Overs',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green)),
                ),
                controller: TextEditingController(text: match.totalOvers.toString()),
                onChanged: (val) {
                  selectedOvers = int.tryParse(val) ?? match.totalOvers;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
              onPressed: () {
                Navigator.pop(ctx);
                
                final updatedMatch = Match(
                  id: match.id,
                  team1: match.team1,
                  team2: match.team2,
                  matchNumber: match.matchNumber,
                  totalOvers: selectedOvers,
                  isFinal: match.isFinal,
                  isCompleted: match.isCompleted,
                  firstInnings: match.firstInnings,
                  secondInnings: match.secondInnings,
                  winner: match.winner,
                );
                
                final allTeams = ref.read(teamProvider);
                ref.read(matchProvider.notifier).updateMatchResult(match.id, updatedMatch, allTeams);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LiveScoringScreen(match: updatedMatch)),
                );
              },
              child: const Text('Start Scoring', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

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
            onPressed: () => _promptForOversAndGenerate(context, ref),
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
                  onPressed: () => _promptForOversAndGenerate(context, ref),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
                  child: const Text('Generate Tournament Schedule', style: TextStyle(color: Colors.black)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return _buildMatchCard(context, ref, match, matches);
                },
              ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, WidgetRef ref, Match match, List<Match> allMatches) {
    final isAdmin = ref.watch(isAdminProvider);

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
          
          if (!match.isCompleted && isAdmin) {
             _promptForMatchOversAndStart(context, ref, match);
          } else {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (_) => LiveScoringScreen(match: match)),
             );
          }
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
