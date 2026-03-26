import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_user_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/team_provider.dart';

class AdminUserManagementScreen extends ConsumerWidget {
  const AdminUserManagementScreen({super.key});

  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Factory Reset Application?'),
        content: const Text(
          'WARNING: This will delete ALL teams, matches, '
          'and auction history. All players and users will be unassigned. '
          'This action CANNOT be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resetting Application...')),
              );
              try {
                await ref.read(adminUserActionsProvider).resetApplication();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application Reset Successful')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error resetting application: $e')),
                  );
                }
              }
            },
            child: const Text('RESET', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final teams = ref.watch(teamProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Access Management'),
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            tooltip: 'Factory Reset App',
            onPressed: () => _showResetConfirmationDialog(context, ref),
          ),
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
        child: usersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
          ),
          data: (users) {
            if (users.isEmpty) {
              return const Center(
                child: Text('No user profiles yet.', style: TextStyle(color: Colors.white)),
              );
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  color: Colors.black26,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.email.isEmpty ? user.uid : user.email,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UID: ${user.uid}${currentUser?.uid == user.uid ? ' (You)' : ''}',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: user.role,
                                dropdownColor: const Color(0xFF1B5E20),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white30),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'user', child: Text('user')),
                                  DropdownMenuItem(value: 'admin', child: Text('admin')),
                                ],
                                onChanged: (role) async {
                                  if (role == null) return;
                                  await ref
                                      .read(adminUserActionsProvider)
                                      .updateUserRoleAndTeam(
                                        uid: user.uid,
                                        role: role,
                                        teamId: role == 'admin' ? null : user.teamId,
                                      );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String?>(
                                initialValue: user.teamId,
                                dropdownColor: const Color(0xFF1B5E20),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Team',
                                  labelStyle: TextStyle(color: Colors.white70),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white30),
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Unassigned'),
                                  ),
                                  ...teams.map(
                                    (t) => DropdownMenuItem<String?>(
                                      value: t.id,
                                      child: Text(t.name),
                                    ),
                                  ),
                                ],
                                onChanged: user.role == 'admin'
                                    ? null
                                    : (teamId) async {
                                        await ref
                                            .read(adminUserActionsProvider)
                                            .updateUserRoleAndTeam(
                                              uid: user.uid,
                                              role: user.role,
                                              teamId: teamId,
                                            );
                                      },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}