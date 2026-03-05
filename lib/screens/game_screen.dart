// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../widgets/score_header.dart';
import '../widgets/dart_keyboard.dart';
import '../widgets/turn_display.dart';
import 'winner_screen.dart';
import 'setup_screen.dart';

class GameScreen extends StatefulWidget {
  final GameModel game;
  const GameScreen({super.key, required this.game});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _bustController;
  late AnimationController _switchController;
  bool _showBust = false;
  String _bustMessage = '';

  @override
  void initState() {
    super.initState();
    _bustController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _bustController.dispose();
    _switchController.dispose();
    super.dispose();
  }

  void _onThrow(Throw t) {
    setState(() {
      widget.game.addThrow(t);
    });

    if (widget.game.gameOver) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => WinnerScreen(game: widget.game),
              transitionsBuilder: (_, anim, __, child) =>
                  FadeTransition(opacity: anim, child: child),
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      });
      return;
    }

    // Auto-validate after 3 throws
    if (widget.game.currentTurn.throws.length == 3) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _validateTurn();
      });
    }
  }

  void _validateTurn() {
    final isBust = widget.game.currentTurn.isBust;
    final turnScore = widget.game.currentTurn.totalScore;

    setState(() {
      if (isBust) {
        _bustMessage = 'BUST ! Tour annulé';
        _showBust = true;
      }
      widget.game.validateTurn();
    });

    if (isBust) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showBust = false);
      });
    }
  }

  void _undo() {
    setState(() {
      widget.game.undoLastThrow();
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            )),
            const SizedBox(height: 24),
            _menuTile(Icons.refresh, 'Nouvelle partie', Colors.white, () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            }),
            const SizedBox(height: 12),
            _menuTile(Icons.close, 'Quitter', Colors.red, () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SetupScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: color.withOpacity(0.05),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final canValidate = game.currentTurn.throws.isNotEmpty &&
        !game.currentTurn.isComplete &&
        !game.gameOver;
    final canUndo = game.currentTurn.throws.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1E), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header avec scores
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        const Text('🎯', style: TextStyle(fontSize: 20)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white54),
                          onPressed: _showMenu,
                        ),
                      ],
                    ),
                  ),
                  ScoreHeader(game: game),
                  const SizedBox(height: 8),
                  // Affichage du tour en cours
                  TurnDisplay(game: game),
                  const Spacer(),
                  // Clavier de saisie
                  DartKeyboard(
                    game: game,
                    onThrow: _onThrow,
                    onValidate: canValidate ? _validateTurn : null,
                    onUndo: canUndo ? _undo : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              // Overlay BUST
              if (_showBust)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _showBust ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4757),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF4757).withOpacity(0.5),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('💥', style: TextStyle(fontSize: 48)),
                                const SizedBox(height: 8),
                                const Text(
                                  'BUST !',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const Text(
                                  'Tour annulé',
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
