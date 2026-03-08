// lib/widgets/score_header.dart
import 'package:flutter/material.dart';
import '../models/game_model.dart';

// Couleurs par joueur
const List<Color> kPlayerColors = [
  Color(0xFFE8C547),
  Color(0xFF4ECDC4),
  Color(0xFFFF6B9D),
];

class ScoreHeader extends StatelessWidget {
  final GameModel game;
  const ScoreHeader({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final players = game.players;

    if (players.length == 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: _PlayerScore(
                player: players[0],
                isActive: game.currentPlayerIndex == 0,
                color: kPlayerColors[0],
                align: TextAlign.left,
              ),
            ),
            _CenterDivider(),
            Expanded(
              child: _PlayerScore(
                player: players[1],
                isActive: game.currentPlayerIndex == 1,
                color: kPlayerColors[1],
                align: TextAlign.right,
              ),
            ),
          ],
        ),
      );
    }

    // 3 joueurs : affichage vertical compact
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: List.generate(players.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 4,
                right: i == players.length - 1 ? 0 : 4,
              ),
              child: _PlayerScore(
                player: players[i],
                isActive: game.currentPlayerIndex == i,
                color: kPlayerColors[i],
                align: TextAlign.center,
              ),
            ),
          );
        }),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
            : align == TextAlign.right
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: align == TextAlign.left
                ? MainAxisAlignment.start
                : align == TextAlign.right
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
            children: [
              if (isActive && align != TextAlign.right)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(right: 5),
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
              Flexible(
                child: Text(
                  player.name,
                  style: TextStyle(
                    color: isActive ? color : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: align,
                ),
              ),
              if (isActive && align == TextAlign.right)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(left: 5),
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${player.score}',
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: isActive ? Colors.white : Colors.white38,
              height: 1,
              letterSpacing: -2,
            ),
            textAlign: align,
          ),
          const SizedBox(height: 2),
          Text(
            '⌀ ${player.average.toStringAsFixed(1)}',
            style: TextStyle(
              color: isActive ? color.withOpacity(0.7) : Colors.white24,
              fontSize: 11,
            ),
            textAlign: align,
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
      child: const Text(
        'VS',
        style: TextStyle(
          color: Colors.white24,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
