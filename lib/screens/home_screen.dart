import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'auction_screen.dart';
import 'teams_screen.dart';
import 'history_screen.dart';
import 'statistics_screen.dart';
import 'match_schedule_screen.dart';
import 'points_table_screen.dart';
import 'player_management_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B5E20),
        title: Text(isAdmin ? 'Admin Panel' : 'Viewer Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(firebaseAuthProvider).signOut();
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF0D47A1),
            ], // Green to Dark Blue
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo placeholder
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 3,
                      ), // Gold border
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sports_cricket,
                        size: 80,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Auction',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                  const Text(
                    'Auction Mobile Application',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'SEASON 3',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  _buildMenuButton(
                    context,
                    title: isAdmin ? 'Start Auction' : 'Live Auction',
                    icon: Icons.gavel,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AuctionScreen()),
                    ),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: 'View Teams',
                    icon: Icons.groups,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TeamsScreen()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuButton(
                    context,
                    title: isAdmin ? 'Manage Players' : 'Players List',
                    icon: Icons.list_alt,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PlayerManagementScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'TOURNAMENT',
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 2,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSmallButton(
                        context,
                        title: 'Schedule',
                        icon: Icons.calendar_month,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MatchScheduleScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildSmallButton(
                        context,
                        title: 'Standings',
                        icon: Icons.format_list_numbered,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PointsTableScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'AUCTION HISTORY',
                    style: TextStyle(
                      color: Colors.white54,
                      letterSpacing: 2,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSmallButton(
                        context,
                        title: 'History',
                        icon: Icons.history,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuctionHistoryScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildSmallButton(
                        context,
                        title: 'Stats',
                        icon: Icons.bar_chart,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatisticsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white30),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFFFFD700) : Colors.white12,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPrimary ? Colors.transparent : Colors.white30,
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isPrimary ? Colors.black87 : Colors.white),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPrimary ? Colors.black87 : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
