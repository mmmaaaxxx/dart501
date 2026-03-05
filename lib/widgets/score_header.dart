// lib/widgets/score_header.dart
import 'package:flutter/material.dart';
import '../models/game_model.dart';

class ScoreHeader extends StatelessWidget {
  final GameModel game;
  const ScoreHeader({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final p1Active = game.currentPlayerIndex == 0;
    final p2Active = game.currentPlayerIndex == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _PlayerScore(
            player: game.player1,
            isActive: p1Active,
            color: const Color(0xFFE8C547),
            align: TextAlign.left,
          )),
          _CenterDivider(),
          Expanded(child: _PlayerScore(
            player: game.player2,
            isActive: p2Active,
            color: const Color(0xFF4ECDC4),
            align: TextAlign.right,
          )),
        ],
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  final Player player;
  final bool isActive;
  final Color color;
  final TextAlign align;

  const _PlayerScore({
    required this.player,
    required this.isActive,
    required this.color,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isActive ? color.withOpacity(0.08) : Colors.transparent,
        border: Border.all(
          color: isActive ? color.withOpacity(0.4) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: align == TextAlign.left
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: align == TextAlign.left
                ? MainAxisAlignment.start
                : MainAxisAlignment.end,
            children: [
              if (isActive && align == TextAlign.left)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              Flexible(
                child: Text(
                  player.name,
                  style: TextStyle(
                    color: isActive ? color : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive && align == TextAlign.right)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${player.score}',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : Colors.white38,
              height: 1,
              letterSpacing: -2,
            ),
            textAlign: align,
          ),
          const SizedBox(height: 4),
          Text(
            '⌀ ${player.average.toStringAsFixed(1)}',
            style: TextStyle(
              color: isActive ? color.withOpacity(0.7) : Colors.white24,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: const Column(
        children: [
          Text('VS', style: TextStyle(
            color: Colors.white24,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          )),
        ],
      ),
    );
  }
}
