// lib/widgets/turn_display.dart
import 'package:flutter/material.dart';
import '../models/game_model.dart';

class TurnDisplay extends StatelessWidget {
  final GameModel game;
  const TurnDisplay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final turn = game.currentTurn;
    final player = game.currentPlayer;
    final checkout = game.getCheckoutSuggestion(player.score);
    final isBust = turn.isBust;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141420),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBust
                ? const Color(0xFFFF4757).withOpacity(0.5)
                : Colors.white12,
          ),
        ),
        child: Column(
          children: [
            // Tour en cours : les 3 lancers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) => _DartSlot(
                throwData: i < turn.throws.length ? turn.throws[i] : null,
                isBust: isBust,
                index: i,
              )),
            ),
            if (turn.throws.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBust
                        ? '💥 BUST — score conservé : ${turn.scoreBeforeTurn}'
                        : 'Reste : ${turn.remainingScore}',
                    style: TextStyle(
                      color: isBust ? const Color(0xFFFF4757) : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Total : +${turn.totalScore}',
                    style: const TextStyle(color: Colors.white38, fontSize: 13),
                  ),
                ],
              ),
            ],
            // Suggestion de checkout
            if (checkout.isNotEmpty && !isBust && turn.throws.isEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.tips_and_updates, color: Color(0xFF4ECDC4), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Checkout : ${checkout.join(' → ')}',
                      style: const TextStyle(
                        color: Color(0xFF4ECDC4),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DartSlot extends StatelessWidget {
  final Throw? throwData;
  final bool isBust;
  final int index;

  const _DartSlot({this.throwData, required this.isBust, required this.index});

  @override
  Widget build(BuildContext context) {
    final hasThrow = throwData != null;
    Color bgColor = const Color(0xFF1E1E30);
    Color borderColor = Colors.white12;
    Color textColor = Colors.white;

    if (hasThrow && isBust) {
      bgColor = const Color(0xFFFF4757).withOpacity(0.15);
      borderColor = const Color(0xFFFF4757).withOpacity(0.5);
      textColor = const Color(0xFFFF4757);
    } else if (hasThrow) {
      final t = throwData!;
      if (t.type == ThrowType.triple) {
        bgColor = const Color(0xFFE8C547).withOpacity(0.15);
        borderColor = const Color(0xFFE8C547).withOpacity(0.5);
        textColor = const Color(0xFFE8C547);
      } else if (t.type == ThrowType.double || t.isBullseye) {
        bgColor = const Color(0xFF4ECDC4).withOpacity(0.15);
        borderColor = const Color(0xFF4ECDC4).withOpacity(0.5);
        textColor = const Color(0xFF4ECDC4);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 90,
      height: 72,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!hasThrow)
            const Icon(Icons.adjust, color: Colors.white24, size: 20)
          else ...[
            Text(
              '+${throwData!.score}',
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            Text(
              throwData!.label,
              style: TextStyle(
                color: textColor.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
