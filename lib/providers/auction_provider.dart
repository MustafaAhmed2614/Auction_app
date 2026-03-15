import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/player.dart';
import '../models/team.dart';

class AuctionState {
  final Player? currentPlayer;
  final int currentBid;
  final Team? leadingTeam;
  final int timeRemaining;
  final bool isAuctionActive;
  final bool isResolved;

  AuctionState({
    this.currentPlayer,
    this.currentBid = 0,
    this.leadingTeam,
    this.timeRemaining = 30,
    this.isAuctionActive = false,
    this.isResolved = false,
  });

  AuctionState copyWith({
    Player? currentPlayer,
    int? currentBid,
    Team? leadingTeam,
    int? timeRemaining,
    bool? isAuctionActive,
    bool? isResolved,
  }) {
    return AuctionState(
      currentPlayer: currentPlayer ?? this.currentPlayer,
      currentBid: currentBid ?? this.currentBid,
      leadingTeam: leadingTeam ?? this.leadingTeam,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isAuctionActive: isAuctionActive ?? this.isAuctionActive,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  factory AuctionState.fromJson(Map<String, dynamic> json) {
    return AuctionState(
      currentPlayer: json['currentPlayer'] != null
          ? Player.fromJson(Map<String, dynamic>.from(json['currentPlayer']))
          : null,
      currentBid: json['currentBid'] as int? ?? 0,
      leadingTeam: json['leadingTeam'] != null
          ? Team.fromJson(Map<String, dynamic>.from(json['leadingTeam']))
          : null,
      timeRemaining: json['timeRemaining'] as int? ?? 30,
      isAuctionActive: json['isAuctionActive'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPlayer': currentPlayer?.toJson(),
      'currentBid': currentBid,
      'leadingTeam': leadingTeam?.toJson(),
      'timeRemaining': timeRemaining,
      'isAuctionActive': isAuctionActive,
      'isResolved': isResolved,
    };
  }
}

class AuctionResolveResult {
  final bool handled;
  final bool sold;
  final String? playerName;
  final String? teamName;
  final int finalPrice;

  const AuctionResolveResult({
    required this.handled,
    required this.sold,
    this.playerName,
    this.teamName,
    this.finalPrice = 0,
  });
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
    FirebaseFirestore.instance.collection('auction').doc('current').snapshots().listen((
      snapshot,
    ) {
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
    FirebaseFirestore.instance
        .collection('auction')
        .doc('current')
        .set(newState.toJson());
  }

  void startAuctionForPlayer(Player player) {
    _timer?.cancel();
    final newState = AuctionState(
      currentPlayer: player,
      currentBid: player.basePrice,
      timeRemaining: 30,
      isAuctionActive: true,
      isResolved: false,
    );
    _syncState(newState);
    _startTimer();
  }

  void placeBid(Team team, int bidAmount) {
    if (!state.isAuctionActive || state.currentPlayer == null) return;

    if (team.remainingPoints < bidAmount) return;
    if (bidAmount <= state.currentBid) return;

    final newState = state.copyWith(
      currentBid: bidAmount,
      leadingTeam: team,
      timeRemaining: 30,
    );
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

  Future<AuctionResolveResult> resolveAuctionResultIfNeeded() async {
    final firestore = FirebaseFirestore.instance;
    final auctionRef = firestore.collection('auction').doc('current');
    final playerRef = firestore.collection('players');
    final teamRef = firestore.collection('teams');
    final historyRef = firestore.collection('auction_results');

    return firestore.runTransaction((transaction) async {
      final auctionSnap = await transaction.get(auctionRef);
      if (!auctionSnap.exists || auctionSnap.data() == null) {
        return const AuctionResolveResult(handled: false, sold: false);
      }

      final currentState = AuctionState.fromJson(auctionSnap.data()!);
      if (currentState.isAuctionActive ||
          currentState.isResolved ||
          currentState.currentPlayer == null) {
        return const AuctionResolveResult(handled: false, sold: false);
      }

      final player = currentState.currentPlayer!;

      if (currentState.leadingTeam == null) {
        transaction.update(auctionRef, {'isResolved': true});
        return AuctionResolveResult(
          handled: true,
          sold: false,
          playerName: player.name,
        );
      }

      final leader = currentState.leadingTeam!;
      final currentBid = currentState.currentBid;

      final winningTeamDoc = teamRef.doc(leader.id);
      final soldPlayerDoc = playerRef.doc(player.id);
      final winningTeamSnap = await transaction.get(winningTeamDoc);

      if (!winningTeamSnap.exists || winningTeamSnap.data() == null) {
        transaction.update(auctionRef, {'isResolved': true});
        return const AuctionResolveResult(handled: false, sold: false);
      }

      final winningTeamData = winningTeamSnap.data()!;
      final currentRemaining =
          winningTeamData['remainingPoints'] as int? ?? leader.remainingPoints;
      final updatedRemaining = currentRemaining - currentBid;

      if (updatedRemaining < 0) {
        transaction.update(auctionRef, {'isResolved': true});
        return AuctionResolveResult(
          handled: true,
          sold: false,
          playerName: player.name,
        );
      }

      transaction.update(winningTeamDoc, {'remainingPoints': updatedRemaining});
      transaction.update(soldPlayerDoc, {'isSold': true});

      final historyId = const Uuid().v4();
      transaction.set(historyRef.doc(historyId), {
        'id': historyId,
        'player': {...player.toJson(), 'isSold': true},
        'winningTeam': {
          ...leader.toJson(),
          'remainingPoints': updatedRemaining,
        },
        'finalPrice': currentBid,
        'timestamp': DateTime.now().toIso8601String(),
      });

      transaction.update(auctionRef, {'isResolved': true});
      return AuctionResolveResult(
        handled: true,
        sold: true,
        playerName: player.name,
        teamName: leader.name,
        finalPrice: currentBid,
      );
    });
  }
}

final auctionProvider = NotifierProvider<AuctionNotifier, AuctionState>(() {
  return AuctionNotifier();
});
