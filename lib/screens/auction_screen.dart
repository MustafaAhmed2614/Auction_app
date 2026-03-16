import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
// import 'package:audioplayers/audioplayers.dart'; // optional audio
import '../providers/auth_provider.dart';
import '../providers/auction_provider.dart';
import '../providers/player_provider.dart';
import '../providers/team_provider.dart';
import '../providers/history_provider.dart';
import '../models/player.dart';
import '../models/team.dart';

class AuctionScreen extends ConsumerStatefulWidget {
  const AuctionScreen({super.key});

  @override
  ConsumerState<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends ConsumerState<AuctionScreen> {
  final _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  // final _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _confettiController.dispose();
    // _audioPlayer.dispose();
    super.dispose();
  }

  /*void _playBidSound() async {
    // await _audioPlayer.play(AssetSource('bid_sound.mp3'));
  }*/

  void _resolveAuction(AuctionState state) {
    if (state.currentPlayer != null && state.leadingTeam != null) {
      // Auction won
      final winningTeam = state.leadingTeam!;
      final price = state.currentBid;
      final player = state.currentPlayer!;

      ref
          .read(teamProvider.notifier)
          .updateTeamPoints(winningTeam.id, winningTeam.remainingPoints, price);
      ref
          .read(teamProvider.notifier)
          .addPlayerToSquad(winningTeam.id, player.id);
      ref.read(playerProvider.notifier).markAsSold(player.id);
      ref.read(historyProvider.notifier).addResult(player, winningTeam, price);

      _confettiController.play();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${player.name} SOLD to ${winningTeam.name} for $price!',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else if (state.currentPlayer != null && state.leadingTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Player UNSOLD!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unsoldPlayers = ref.watch(unsoldPlayersProvider);
    final auctionState = ref.watch(auctionProvider);
    final teams = ref.watch(teamProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final currentUserTeamId = ref.watch(currentUserTeamIdProvider);

    ref.listen<AuctionState>(auctionProvider, (previous, next) {
      if (isAdmin &&
          previous?.isAuctionActive == true &&
          !next.isAuctionActive) {
        _resolveAuction(next);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Auction'),
        backgroundColor: const Color(0xFF1B5E20),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  ref.read(auctionProvider.notifier).resetAuction(),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child:
                auctionState.isAuctionActive ||
                    auctionState.currentPlayer != null
              ? _buildActiveAuction(
                context,
                auctionState,
                teams,
                isAdmin,
                currentUserTeamId,
                )
                : isAdmin
                ? _buildPlayerSelection(context, unsoldPlayers)
                : _buildWaitingForAdmin(),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.red,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForAdmin() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Waiting for admin to start the next auction...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildPlayerSelection(
    BuildContext context,
    List<Player> unsoldPlayers,
  ) {
    if (unsoldPlayers.isEmpty) {
      return const Center(
        child: Text(
          'No more players available!',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select Next Player',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: unsoldPlayers.length,
            itemBuilder: (context, index) {
              final player = unsoldPlayers[index];
              return Card(
                color: Colors.white12,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFD700),
                    child: Icon(Icons.person, color: Colors.black),
                  ),
                  title: Text(
                    '${index + 1}. ${player.name}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${player.category} • Base Price: ${player.basePrice}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                    ),
                    onPressed: () {
                      ref
                          .read(auctionProvider.notifier)
                          .startAuctionForPlayer(player);
                    },
                    child: const Text(
                      'Bring to Auction',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveAuction(
    BuildContext context,
    AuctionState state,
    List<Team> teams,
    bool isAdmin,
    String? currentUserTeamId,
  ) {
    final player = state.currentPlayer!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Player info and Timer
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Text(
                  player.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 16,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  player.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Current Bid',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        Text(
                          '${state.currentBid} (Next +2000)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (state.leadingTeam != null)
                          Text(
                            state.leadingTeam!.name,
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: state.timeRemaining <= 3
                              ? Colors.red
                              : Colors.green,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${state.timeRemaining}',
                          style: TextStyle(
                            color: state.timeRemaining <= 3
                                ? Colors.red
                                : Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (!isAdmin && currentUserTeamId == null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent),
              ),
              child: const Text(
                'Your account has no team assigned yet. Ask admin to set users/{uid}.teamId in Firestore.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          // Bidding interface for 4 teams
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _buildTeamBiddingPanel(
                team,
                state,
                isAdmin,
                currentUserTeamId,
              );
            },
          ),

          if (isAdmin && !state.isAuctionActive && state.currentPlayer != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () =>
                    ref.read(auctionProvider.notifier).resetAuction(),
                child: const Text(
                  'Next Auction',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamBiddingPanel(
    Team team,
    AuctionState state,
    bool isAdmin,
    String? currentUserTeamId,
  ) {
    bool isLeading = state.leadingTeam?.id == team.id;
    final nextBidAmount = state.currentBid + 2000;
    final rawLivePurse =
        team.remainingPoints - (isLeading ? state.currentBid : 0);
    final livePurse = rawLivePurse < 0 ? 0 : rawLivePurse;
    final canControlThisTeam =
        isAdmin ||
        (currentUserTeamId != null && currentUserTeamId == team.id);
    bool canBid =
        state.isAuctionActive &&
        canControlThisTeam &&
        !isLeading &&
        team.remainingPoints >= nextBidAmount;

    return Container(
      decoration: BoxDecoration(
        color: isLeading
            ? const Color(0xFF1B5E20).withValues(alpha: 0.8)
            : Colors.black45,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLeading ? const Color(0xFFFFD700) : Colors.white24,
          width: isLeading ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            team.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (canControlThisTeam && !isAdmin)
            const Text(
              'YOUR TEAM',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          Text(
            'Live Purse: $livePurse pts',
            style: TextStyle(
              color: canBid || isLeading
                  ? Colors.greenAccent
                  : Colors.redAccent,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          if (isLeading)
            const Text(
              'LEADING',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

          if (!isLeading) ...[
            ElevatedButton(
              onPressed: canBid
                  ? () {
                      // _playBidSound();
                      ref
                          .read(auctionProvider.notifier)
                          .placeBid(team, nextBidAmount);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
              ),
              child: const Text('+2000', style: TextStyle(color: Colors.black)),
            ),
          ],
        ],
      ),
    );
  }
}
