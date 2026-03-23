import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_provider.dart';
import '../providers/team_provider.dart';
import '../models/match.dart';
import '../models/innings.dart';

class LiveScoringScreen extends ConsumerStatefulWidget {
  final Match match;

  const LiveScoringScreen({super.key, required this.match});

  @override
  ConsumerState<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends ConsumerState<LiveScoringScreen> {
  late Innings currentInnings;
  bool isFirstInnings = true;
  final List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _initInnings();
  }

  void _initInnings() {
    if (widget.match.firstInnings == null) {
      widget.match.firstInnings = Innings(battingTeam: widget.match.team1);
    }
    if (widget.match.secondInnings == null) {
      widget.match.secondInnings = Innings(battingTeam: widget.match.team2);
    }

    if (!widget.match.firstInnings!.isCompleted) {
      currentInnings = widget.match.firstInnings!;
      isFirstInnings = true;
    } else {
      currentInnings = widget.match.secondInnings!;
      isFirstInnings = false;
    }
  }

  void _saveHistory() {
    // We deep copy the match state using JSON serialization
    // We need to import dart:convert at the top of the file as well!
    _history.add(jsonEncode(widget.match.toJson()));
  }

  void _undo() {
    if (_history.isEmpty) return;
    
    setState(() {
      final previousStateJson = jsonDecode(_history.removeLast());
      final previousMatch = Match.fromJson(previousStateJson);
      
      widget.match.firstInnings = previousMatch.firstInnings;
      widget.match.secondInnings = previousMatch.secondInnings;
      widget.match.isCompleted = previousMatch.isCompleted;
      widget.match.winner = previousMatch.winner;
      
      _initInnings();
    });
    
    ref.read(matchProvider.notifier).updateMatchResult(
      widget.match.id, 
      widget.match, 
      ref.read(teamProvider)
    );
  }

  void _addRuns(int runs) {
    if (currentInnings.isCompleted || widget.match.isCompleted) return;
    
    _saveHistory();
    setState(() {
      currentInnings.runs += runs;
      currentInnings.ballsBowled++;
      _checkInningsStatus();
    });
    ref.read(matchProvider.notifier).updateMatchResult(widget.match.id, widget.match, ref.read(teamProvider));
  }

  void _addExtra(int runs) {
     if (currentInnings.isCompleted || widget.match.isCompleted) return;
     
     _saveHistory();
     setState(() {
       currentInnings.runs += runs; // Wide/No-ball doesn't count as a legal ball
     });
     ref.read(matchProvider.notifier).updateMatchResult(widget.match.id, widget.match, ref.read(teamProvider));
  }

  void _addWicket() {
    if (currentInnings.isCompleted || widget.match.isCompleted) return;
    
    _saveHistory();
    setState(() {
      currentInnings.wickets++;
      currentInnings.ballsBowled++;
      _checkInningsStatus();
    });
    ref.read(matchProvider.notifier).updateMatchResult(widget.match.id, widget.match, ref.read(teamProvider));
  }

  void _checkInningsStatus() {
    // 5 overs = 30 balls, max 10 wickets
    if (currentInnings.ballsBowled >= 30 || currentInnings.wickets >= 10) {
      currentInnings.isCompleted = true;
      
      if (isFirstInnings) {
        // Switch to second innings automatically
        isFirstInnings = false;
        currentInnings = widget.match.secondInnings!;
      } else {
        // Match over
        widget.match.isCompleted = true;
        _determineWinner();
      }
    } else if (!isFirstInnings) {
       // Second innings chase target check
       if (currentInnings.runs > widget.match.firstInnings!.runs) {
         currentInnings.isCompleted = true;
         widget.match.isCompleted = true;
         _determineWinner();
       }
    }
  }

  void _determineWinner() {
    int score1 = widget.match.firstInnings!.runs;
    int score2 = widget.match.secondInnings!.runs;

    if (score1 > score2) {
      widget.match.winner = widget.match.firstInnings!.battingTeam;
    } else if (score2 > score1) {
      widget.match.winner = widget.match.secondInnings!.battingTeam;
    } else {
      widget.match.winner = null; // Tie
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Scoring - Match ${widget.match.matchNumber}'),
        backgroundColor: const Color(0xFF1B5E20),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        _buildScorecardHeader(),
                        const SizedBox(height: 16),
                      ],
                    ),
                    if (!widget.match.isCompleted) _buildScoringControls(),
                    if (widget.match.isCompleted)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          widget.match.winner != null ? '${widget.match.winner!.name} Won!' : 'Match Tied!',
                          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScorecardHeader() {
     final target = isFirstInnings ? null : widget.match.firstInnings!.runs + 1;

     return Container(
       padding: const EdgeInsets.all(24),
       color: Colors.black45,
       child: Column(
         children: [
            Text(
              '${currentInnings.battingTeam.name} Batting',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${currentInnings.runs}/${currentInnings.wickets}',
                  style: const TextStyle(color: Color(0xFFFFD700), fontSize: 64, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    '(${currentInnings.overs} Ov)',
                    style: const TextStyle(color: Colors.white70, fontSize: 24),
                  ),
                ),
              ],
            ),
            if (target != null && !widget.match.isCompleted) ...[
              const SizedBox(height: 8),
              Text(
                'Target: $target | Need ${target - currentInnings.runs} from ${30 - currentInnings.ballsBowled} balls',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ]
         ],
       ),
     );
  }

  Widget _buildScoringControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreBtn('0', () => _addRuns(0), color: Colors.grey),
              _scoreBtn('1', () => _addRuns(1)),
              _scoreBtn('2', () => _addRuns(2)),
              _scoreBtn('3', () => _addRuns(3)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreBtn('4', () => _addRuns(4), color: Colors.blueAccent),
              _scoreBtn('6', () => _addRuns(6), color: Colors.deepPurpleAccent),
              _scoreBtn('W', _addWicket, color: Colors.redAccent),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _scoreBtn('Wide', () => _addExtra(1), width: 90, color: Colors.orange),
              _scoreBtn('No Ball', () => _addExtra(1), width: 90, color: Colors.orange),
              if (_history.isNotEmpty)
                _scoreBtn('Undo', _undo, width: 90, color: Colors.blueGrey),
            ],
          )
        ],
      ),
    );
  }

  Widget _scoreBtn(String label, VoidCallback onTap, {Color color = Colors.white24, double width = 60}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: width == 60 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: width != 60 ? BorderRadius.circular(16) : null,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
