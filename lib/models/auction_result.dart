import 'player.dart';
import 'team.dart';

class AuctionResult {
  final String id;
  final Player player;
  final Team winningTeam;
  final int finalPrice;
  final DateTime timestamp;

  AuctionResult({
    required this.id,
    required this.player,
    required this.winningTeam,
    required this.finalPrice,
    required this.timestamp,
  });

  factory AuctionResult.fromJson(Map<String, dynamic> json) {
    return AuctionResult(
      id: json['id'] as String,
      player: Player.fromJson(Map<String, dynamic>.from(json['player'])),
      winningTeam: Team.fromJson(Map<String, dynamic>.from(json['winningTeam'])),
      finalPrice: json['finalPrice'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player': player.toJson(),
      'winningTeam': winningTeam.toJson(),
      'finalPrice': finalPrice,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
