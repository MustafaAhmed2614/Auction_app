import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/standings_calculator.dart';
import 'match_provider.dart';
import 'team_provider.dart';

final pointsTableProvider = Provider<List<TeamStats>>((ref) {
  final matches = ref.watch(matchProvider);
  final teams = ref.watch(teamProvider);
  return calculateStandings(matches, teams);
});
