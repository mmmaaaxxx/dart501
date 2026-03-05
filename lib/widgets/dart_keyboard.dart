// lib/widgets/dart_keyboard.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_model.dart';

class DartKeyboard extends StatefulWidget {
  final GameModel game;
  final Function(Throw) onThrow;
  final VoidCallback? onValidate;
  final VoidCallback? onUndo;

  const DartKeyboard({
    super.key,
    required this.game,
    required this.onThrow,
    this.onValidate,
    this.onUndo,
  });

  @override
  State<DartKeyboard> createState() => _DartKeyboardState();
}

class _DartKeyboardState extends State<DartKeyboard> {
  ThrowType _selectedType = ThrowType.single;

  bool get _canThrow =>
      widget.game.currentTurn.throws.length < 3 &&
      !widget.game.currentTurn.isBust &&
      !widget.game.gameOver;

  void _throw(int segment) {
    if (!_canThrow) return;
    HapticFeedback.lightImpact();
    int score;
    bool isBull = false;
    bool isBullseye = false;

    if (segment == 25) {
      // Bull (outer bull = 25)
      score = 25;
      isBull = true;
      widget.onThrow(Throw(
        score: score,
        segment: segment,
        type: ThrowType.single,
        isBull: true,
      ));
      return;
    }
    if (segment == 50) {
      // Bullseye (inner bull = 50, compte comme double)
      score = 50;
      isBullseye = true;
      widget.onThrow(Throw(
        score: score,
        segment: segment,
        type: ThrowType.double,
        isBullseye: true,
      ));
      return;
    }

    switch (_selectedType) {
      case ThrowType.single:
        score = segment;
      case ThrowType.double:
        score = segment * 2;
      case ThrowType.triple:
        score = segment * 3;
    }

    // Vérifier que le score ne dépasse pas le score restant actuel
    final remaining = widget.game.currentTurn.remainingScore;
    if (score > remaining) {
      // C'est un bust potentiel, on l'enregistre quand même
    }

    widget.onThrow(Throw(
      score: score,
      segment: segment,
      type: _selectedType,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sélecteur Single / Double / Triple
          _buildTypeSelector(),
          const SizedBox(height: 12),
          // Grille des segments 1-20
          _buildSegmentGrid(),
          const SizedBox(height: 12),
          // Bull, Bullseye, Undo, Validate
          _buildBottomRow(),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _typeBtn('Simple', ThrowType.single, Colors.white70),
          _typeBtn('Double', ThrowType.double, const Color(0xFF4ECDC4)),
          _typeBtn('Triple', ThrowType.triple, const Color(0xFFE8C547)),
        ],
      ),
    );
  }

  Widget _typeBtn(String label, ThrowType type, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedType = type);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.6) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentGrid() {
    // Disposition en 4 colonnes × 5 rangées = 20 segments
    const segments = [
      1, 2, 3, 4, 5,
      6, 7, 8, 9, 10,
      11, 12, 13, 14, 15,
      16, 17, 18, 19, 20,
    ];

    Color btnColor() {
      switch (_selectedType) {
        case ThrowType.single:
          return Colors.white70;
        case ThrowType.double:
          return const Color(0xFF4ECDC4);
        case ThrowType.triple:
          return const Color(0xFFE8C547);
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.2,
      ),
      itemCount: segments.length,
      itemBuilder: (_, i) => _SegmentButton(
        segment: segments[i],
        color: btnColor(),
        type: _selectedType,
        onTap: _canThrow ? () => _throw(segments[i]) : null,
      ),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        // Bull (25)
        Expanded(
          child: _ActionButton(
            label: 'BULL',
            sublabel: '25',
            color: Colors.orange,
            onTap: _canThrow ? () => _throw(25) : null,
          ),
        ),
        const SizedBox(width: 8),
        // Bullseye (50)
        Expanded(
          child: _ActionButton(
            label: 'BULL',
            sublabel: '50 ★',
            color: Colors.red,
            onTap: _canThrow ? () => _throw(50) : null,
          ),
        ),
        const SizedBox(width: 8),
        // Miss / 0
        Expanded(
          child: _ActionButton(
            label: 'MISS',
            sublabel: '0',
            color: Colors.white38,
            onTap: _canThrow ? () {
              HapticFeedback.lightImpact();
              widget.onThrow(Throw(score: 0, segment: 0, type: ThrowType.single));
            } : null,
          ),
        ),
        const SizedBox(width: 8),
        // Undo
        Expanded(
          child: _ActionButton(
            label: '↩',
            sublabel: 'Annuler',
            color: Colors.white54,
            onTap: widget.onUndo,
          ),
        ),
        const SizedBox(width: 8),
        // Valider (si < 3 lancers)
        Expanded(
          child: _ActionButton(
            label: '✓',
            sublabel: 'Valider',
            color: const Color(0xFFE8C547),
            onTap: widget.onValidate,
            isHighlighted: widget.onValidate != null,
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final int segment;
  final Color color;
  final ThrowType type;
  final VoidCallback? onTap;

  const _SegmentButton({
    required this.segment,
    required this.color,
    required this.type,
    this.onTap,
  });

  String get prefix {
    switch (type) {
      case ThrowType.double: return 'D';
      case ThrowType.triple: return 'T';
      case ThrowType.single: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFF0F0F1A)
              : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled ? Colors.white12 : color.withOpacity(0.35),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$segment',
              style: TextStyle(
                color: isDisabled ? Colors.white24 : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            if (prefix.isNotEmpty)
              Text(
                '$prefix$segment',
                style: TextStyle(
                  color: isDisabled ? Colors.white12 : color.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback? onTap;
  final bool isHighlighted;

  const _ActionButton({
    required this.label,
    required this.sublabel,
    required this.color,
    this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isHighlighted && !isDisabled
              ? color.withOpacity(0.15)
              : isDisabled
                  ? const Color(0xFF0F0F1A)
                  : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled ? Colors.white12 : color.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDisabled ? Colors.white24 : color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                color: isDisabled ? Colors.white12 : color.withOpacity(0.6),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
