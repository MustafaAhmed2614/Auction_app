import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';
import '../models/team.dart';
import 'squad_screen.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BPL Teams'),
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
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: teams.length,
          itemBuilder: (context, index) {
            final team = teams[index];
            if (!isAdmin) {
              return _buildTeamCard(context, team);
            }
            return Dismissible(
              key: Key(team.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.read(teamProvider.notifier).deleteTeam(team.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${team.name} deleted')),
                );
              },
              child: _buildTeamCard(context, team),
            );
          },
        ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showAddTeamDialog(context, ref),
              backgroundColor: const Color(0xFFFFD700),
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }

  void _showAddTeamDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController(text: '100000');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Team'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Team Name'),
                autofocus: true,
              ),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(labelText: 'Starting Budget'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final budget = int.tryParse(budgetController.text) ?? 100000;
                if (name.isNotEmpty) {
                  ref.read(teamProvider.notifier).addTeam(name, budget, 'assets/logos/logo1.png');
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700)),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeamCard(BuildContext context, Team team) {
    return Card(
      color: Colors.white12,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white24, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SquadScreen(team: team)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFFD700), width: 2),
                ),
                child: const Icon(Icons.shield, color: Color(0xFF1B5E20), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Budget: ${team.remainingPoints} pts',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFD700),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
