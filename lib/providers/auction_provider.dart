import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/player.dart';
import '../models/team.dart';

class AuctionState {
  final Player? currentPlayer;
  final int currentBid;
  final Team? leadingTeam;
  final int timeRemaining;
  final bool isAuctionActive;

  AuctionState({
    this.currentPlayer,
    this.currentBid = 0,
    this.leadingTeam,
    this.timeRemaining = 10,
    this.isAuctionActive = false,
  });

  AuctionState copyWith({
    Player? currentPlayer,
    int? currentBid,
    Team? leadingTeam,
    int? timeRemaining,
    bool? isAuctionActive,
  }) {
    return AuctionState(
      currentPlayer: currentPlayer ?? this.currentPlayer,
      currentBid: currentBid ?? this.currentBid,
      leadingTeam: leadingTeam ?? this.leadingTeam,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isAuctionActive: isAuctionActive ?? this.isAuctionActive,
    );
  }
}

class AuctionNotifier extends Notifier<AuctionState> {
  Timer? _timer;

  @override
  AuctionState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    return AuctionState();
  }

  void startAuctionForPlayer(Player player) {
    _timer?.cancel();
    state = AuctionState(
      currentPlayer: player,
      currentBid: player.basePrice,
      timeRemaining: 10,
      isAuctionActive: true,
    );
    _startTimer();
  }

  void placeBid(Team team, int bidAmount) {
    if (!state.isAuctionActive || state.currentPlayer == null) return;
    
    // Validate team has enough points
    if (team.remainingPoints < bidAmount) return; // Cannot bid more than remaining points
    if (bidAmount <= state.currentBid) return; // Bid must be higher

    // Reset timer on new valid bid
    state = state.copyWith(currentBid: bidAmount, leadingTeam: team, timeRemaining: 10);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(isAuctionActive: false);
      }
    });
  }

  void resetAuction() {
    _timer?.cancel();
    state = AuctionState();
  }
}

final auctionProvider = NotifierProvider<AuctionNotifier, AuctionState>(() {
  return AuctionNotifier();
});
