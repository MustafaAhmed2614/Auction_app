import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory AuctionState.fromJson(Map<String, dynamic> json) {
    return AuctionState(
      currentPlayer: json['currentPlayer'] != null ? Player.fromJson(Map<String, dynamic>.from(json['currentPlayer'])) : null,
      currentBid: json['currentBid'] as int? ?? 0,
      leadingTeam: json['leadingTeam'] != null ? Team.fromJson(Map<String, dynamic>.from(json['leadingTeam'])) : null,
      timeRemaining: json['timeRemaining'] as int? ?? 10,
      isAuctionActive: json['isAuctionActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPlayer': currentPlayer?.toJson(),
      'currentBid': currentBid,
      'leadingTeam': leadingTeam?.toJson(),
      'timeRemaining': timeRemaining,
      'isAuctionActive': isAuctionActive,
    };
  }
}

class AuctionNotifier extends Notifier<AuctionState> {
  Timer? _timer;

  @override
  AuctionState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });
    
    _listenToAuctionDoc();
    return AuctionState();
  }

  void _listenToAuctionDoc() {
    FirebaseFirestore.instance.collection('auction').doc('current').snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        state = AuctionState.fromJson(snapshot.data()!);
        
        // Timer only runs on the device that initiated the auction or bids, 
        // to avoid all 4 devices running timers out of sync, we let one device command the timer.
        // For simplicity in family games, we'll let whoever starts it host the timer.
        // In a fully decentralized system, a Cloud Function handles the timer.
      }
    });
  }

  void _syncState(AuctionState newState) {
    FirebaseFirestore.instance.collection('auction').doc('current').set(newState.toJson());
  }

  void startAuctionForPlayer(Player player) {
    _timer?.cancel();
    final newState = AuctionState(
      currentPlayer: player,
      currentBid: player.basePrice,
      timeRemaining: 10,
      isAuctionActive: true,
    );
    _syncState(newState);
    _startTimer();
  }

  void placeBid(Team team, int bidAmount) {
    if (!state.isAuctionActive || state.currentPlayer == null) return;
    
    if (team.remainingPoints < bidAmount) return;
    if (bidAmount <= state.currentBid) return;

    final newState = state.copyWith(currentBid: bidAmount, leadingTeam: team, timeRemaining: 10);
    _syncState(newState);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0) {
        _syncState(state.copyWith(timeRemaining: state.timeRemaining - 1));
      } else {
        _timer?.cancel();
        _syncState(state.copyWith(isAuctionActive: false));
      }
    });
  }

  void resetAuction() {
    _timer?.cancel();
    _syncState(AuctionState());
  }
}

final auctionProvider = NotifierProvider<AuctionNotifier, AuctionState>(() {
  return AuctionNotifier();
});
