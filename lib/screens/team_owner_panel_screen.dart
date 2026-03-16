import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player.dart';
import '../providers/player_provider.dart';
import '../providers/team_owner_provider.dart';

class TeamOwnerPanelScreen extends ConsumerStatefulWidget {
  const TeamOwnerPanelScreen({super.key});

  @override
  ConsumerState<TeamOwnerPanelScreen> createState() =>
      _TeamOwnerPanelScreenState();
}

class _TeamOwnerPanelScreenState extends ConsumerState<TeamOwnerPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myTeam = ref.watch(myTeamProvider);
    final teamSpent = ref.watch(myTeamSpentProvider);
    final squad = ref.watch(myTeamSquadProvider);
    final slotsLeft = ref.watch(myTeamSlotsLeftProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(myTeam == null ? 'Team Owner Panel' : '${myTeam.name} Panel'),
        backgroundColor: const Color(0xFF1B5E20),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Watchlist'),
            Tab(text: 'Planner'),
            Tab(text: 'Notes'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: myTeam == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No team is assigned to your account yet. Ask admin to set users/{uid}.teamId.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatTile(title: 'Purse', value: '${myTeam.remainingPoints}'),
                        _StatTile(title: 'Spent', value: '$teamSpent'),
                        _StatTile(title: 'Squad', value: '${squad.length}/$squadTargetSize'),
                        _StatTile(title: 'Left', value: '$slotsLeft'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _OverviewTab(squad: squad),
                        const _WatchlistTab(),
                        const _PlannerTab(),
                        const _NotesTab(),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;

  const _StatTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  final List<Player> squad;

  const _OverviewTab({required this.squad});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistPlayers = ref.watch(myWatchlistPlayersProvider);
    final unsoldPlayers = ref.watch(unsoldPlayersProvider);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          'My Squad',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...squad.map(
          (p) => ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(p.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              p.category,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
        if (squad.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No players bought yet.', style: TextStyle(color: Colors.white70)),
          ),
        const SizedBox(height: 16),
        const Text(
          'Watchlist Targets',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...watchlistPlayers.map(
          (p) => ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(p.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${p.category} - Base ${p.basePrice}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
        if (watchlistPlayers.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('No watchlist players yet.', style: TextStyle(color: Colors.white70)),
          ),
        const SizedBox(height: 16),
        const Text(
          'Available Market',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...unsoldPlayers.take(12).map(
          (p) => ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            title: Text(p.name, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              '${p.category} - Base ${p.basePrice}',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatchlistTab extends ConsumerWidget {
  const _WatchlistTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(myTeamProvider);
    final players = ref.watch(unsoldPlayersProvider);
    final watchlistSet = ref
        .watch(myTeamWatchlistProvider)
        .maybeWhen(
          data: (items) => items.map((e) => e.playerId).toSet(),
          orElse: () => <String>{},
        );

    if (team == null) return const SizedBox.shrink();

    if (players.isEmpty) {
      return const Center(
        child: Text(
          'No unsold players available for watchlist.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final selected = watchlistSet.contains(player.id);
        return SwitchListTile(
          value: selected,
          onChanged: (value) async {
            await ref.read(teamOwnerActionsProvider).toggleWatchlist(
              teamId: team.id,
              playerId: player.id,
              shouldWatch: value,
            );
          },
          title: Text(player.name, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            '${player.category} - Base ${player.basePrice}',
            style: const TextStyle(color: Colors.white70),
          ),
          activeThumbColor: const Color(0xFFFFD700),
        );
      },
    );
  }
}

class _PlannerTab extends ConsumerStatefulWidget {
  const _PlannerTab();

  @override
  ConsumerState<_PlannerTab> createState() => _PlannerTabState();
}

class _PlannerTabState extends ConsumerState<_PlannerTab> {
  late TextEditingController _plat;
  late TextEditingController _gold;
  late TextEditingController _silver;
  late TextEditingController _emerging;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _plat = TextEditingController();
    _gold = TextEditingController();
    _silver = TextEditingController();
    _emerging = TextEditingController();
  }

  @override
  void dispose() {
    _plat.dispose();
    _gold.dispose();
    _silver.dispose();
    _emerging.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(myTeamProvider);
    final teamPurse = team?.remainingPoints ?? 0;
    final plan = ref.watch(myTeamBudgetPlanProvider).maybeWhen(
          data: (value) => value,
          orElse: () => TeamBudgetPlan.fromJson(null),
        );

    if (!_initialized) {
      _plat.text = plan.platinum.toString();
      _gold.text = plan.gold.toString();
      _silver.text = plan.silver.toString();
      _emerging.text = plan.emerging.toString();
      _initialized = true;
    }

    if (team == null) return const SizedBox.shrink();

    final totalPlan =
      (int.tryParse(_plat.text.trim()) ?? 0) +
      (int.tryParse(_gold.text.trim()) ?? 0) +
      (int.tryParse(_silver.text.trim()) ?? 0) +
      (int.tryParse(_emerging.text.trim()) ?? 0);

    final overflow = totalPlan - teamPurse;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _budgetField('Platinum', _plat),
        _budgetField('Gold', _gold),
        _budgetField('Silver', _silver),
        _budgetField('Emerging', _emerging),
        const SizedBox(height: 12),
        Text(
          'Planned Total: $totalPlan | Purse: $teamPurse',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (overflow > 0)
          Text(
            'Warning: plan exceeds purse by $overflow',
            style: const TextStyle(color: Colors.redAccent),
          )
        else
          const Text(
            'Budget plan is within purse.',
            style: TextStyle(color: Colors.greenAccent),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final plan = TeamBudgetPlan(
              platinum: int.tryParse(_plat.text.trim()) ?? 0,
              gold: int.tryParse(_gold.text.trim()) ?? 0,
              silver: int.tryParse(_silver.text.trim()) ?? 0,
              emerging: int.tryParse(_emerging.text.trim()) ?? 0,
            );
            await ref
                .read(teamOwnerActionsProvider)
                .saveBudgetPlan(teamId: team.id, plan: plan);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Budget plan saved.')),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
          ),
          child: const Text('Save Plan'),
        ),
      ],
    );
  }

  Widget _budgetField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: '$label Budget',
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white30),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFD700)),
          ),
        ),
      ),
    );
  }
}

class _NotesTab extends ConsumerStatefulWidget {
  const _NotesTab();

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  String? _selectedPlayerId;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final team = ref.watch(myTeamProvider);
    final players = ref.watch(playerProvider);
    final notes = ref.watch(myTeamPlayerNotesProvider).maybeWhen(
          data: (value) => value,
          orElse: () => <String, String>{},
        );

    if (team == null) return const SizedBox.shrink();

    Player? selectedPlayer;
    if (_selectedPlayerId != null) {
      for (final player in players) {
        if (player.id == _selectedPlayerId) {
          selectedPlayer = player;
          break;
        }
      }
    }

    if (selectedPlayer != null) {
      _noteController.text = notes[selectedPlayer.id] ?? '';
      _noteController.selection = TextSelection.collapsed(
        offset: _noteController.text.length,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          initialValue: _selectedPlayerId,
          dropdownColor: const Color(0xFF1B5E20),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Select Player',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
          ),
          items: players
              .map(
                (p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedPlayerId = value;
            });
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          minLines: 4,
          maxLines: 6,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Private Notes',
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white30),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFFFD700)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _selectedPlayerId == null
              ? null
              : () async {
                  await ref.read(teamOwnerActionsProvider).savePlayerNote(
                        teamId: team.id,
                        playerId: _selectedPlayerId!,
                        note: _noteController.text,
                      );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note saved.')),
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
          ),
          child: const Text('Save Note'),
        ),
      ],
    );
  }
}
