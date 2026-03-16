import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/player_provider.dart';

class PlayerManagementScreen extends ConsumerStatefulWidget {
  const PlayerManagementScreen({super.key});

  @override
  ConsumerState<PlayerManagementScreen> createState() => _PlayerManagementScreenState();
}

class _PlayerManagementScreenState extends ConsumerState<PlayerManagementScreen> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Silver';
  int _basePrice = 5000;

  final Map<String, int> _categoryPrices = {
    'Platinum': 10000,
    'Gold': 7000,
    'Silver': 5000,
    'Emerging': 2000,
  };

  void _addPlayer() {
    if (_nameController.text.trim().isEmpty) return;
    ref.read(playerProvider.notifier).addPlayer(
          _nameController.text.trim(),
          _selectedCategory,
          _basePrice,
          null, // photo placeholder
        );
    _nameController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Player added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playerProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Manage Players' : 'Players List'),
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
            if (isAdmin) _buildAddPlayerForm(),
            if (!isAdmin)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Only admin can add or delete players.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: players.length,
                itemBuilder: (context, index) {
                  final player = players[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getCategoryColor(player.category),
                      child: Text(player.name[0], style: const TextStyle(color: Colors.white)),
                    ),
                    title: Row(
                      children: [
                        Text('${index + 1}. ${player.name}', style: const TextStyle(color: Colors.white)),
                        const SizedBox(width: 8),
                        if (player.isSold)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(4)),
                            child: const Text('SOLD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(4)),
                            child: const Text('AVAILABLE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                      ],
                    ),
                    subtitle: Text('${player.category} • Base: ${player.basePrice}', style: const TextStyle(color: Colors.white70)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: isAdmin
                          ? () {
                              ref
                                  .read(playerProvider.notifier)
                                  .deletePlayer(player.id);
                            }
                          : null,
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

  Widget _buildAddPlayerForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black26,
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Player Name',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFFFD700))),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: const Color(0xFF1B5E20),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                  ),
                  items: _categoryPrices.keys.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                        _basePrice = _categoryPrices[value]!;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _addPlayer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: const Text('Add Player'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Platinum': return Colors.deepPurple;
      case 'Gold': return const Color(0xFFFFD700);
      case 'Silver': return Colors.grey;
      case 'Emerging': return Colors.greenAccent;
      default: return Colors.blue;
    }
  }
}
