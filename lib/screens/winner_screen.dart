// lib/screens/winner_screen.dart
import 'package:flutter/material.dart';
import '../models/game_model.dart';
import 'setup_screen.dart';
import 'game_screen.dart';

class WinnerScreen extends StatefulWidget {
  final GameModel game;
  const WinnerScreen({super.key, required this.game});

  @override
  State<WinnerScreen> createState() => _WinnerScreenState();
}

class _WinnerScreenState extends State<WinnerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Player get winner => widget.game.winnerId == widget.game.player1.name
      ? widget.game.player1
      : widget.game.player2;

  Player get loser => widget.game.winnerId == widget.game.player1.name
      ? widget.game.player2
      : widget.game.player1;

  @override
  Widget build(BuildContext context) {
    final w = winner;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1A1A00), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: const Text('🏆', style: TextStyle(fontSize: 80)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'VICTOIRE !',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 6,
                      color: Color(0xFFE8C547),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ScaleTransition(
                    scale: _scale,
                    child: Text(
                      w.name,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildStats(),
                  const SizedBox(height: 48),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8C547).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _statRow('🎯 Fléchettes lancées', '${winner.dartsThrown}', const Color(0xFFE8C547)),
          const Divider(color: Colors.white12, height: 24),
          _statRow('📊 Moyenne / tour', winner.average.toStringAsFixed(1), const Color(0xFF4ECDC4)),
          const Divider(color: Colors.white12, height: 24),
          _statRow('🏅 Score final', '501 → 0', Colors.white70),
        ],
      ),
    );
  }

  Widget _statRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            final p1Name = widget.game.player1.name;
            final p2Name = widget.game.player2.name;
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => GameScreen(
                  game: GameModel(name1: p1Name, name2: p2Name),
                ),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFE8C547), Color(0xFFD4A017)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE8C547).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              'REVANCHE !',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0A0A0F),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SetupScreen()),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
              color: Colors.white.withOpacity(0.05),
            ),
            child: const Text(
              'MENU PRINCIPAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
