// lib/models/game_model.dart

enum ThrowType { single, double, triple }

class Throw {
  final int score;
  final int segment;
  final ThrowType type;
  final bool isBull;
  final bool isBullseye;

  Throw({
    required this.score,
    required this.segment,
    required this.type,
    this.isBull = false,
    this.isBullseye = false,
  });

  String get label {
    if (isBullseye) return 'Bull';
    if (isBull) return '25';
    switch (type) {
      case ThrowType.double:
        return 'D$segment';
      case ThrowType.triple:
        return 'T$segment';
      case ThrowType.single:
        return '$segment';
    }
  }
}

enum FinishMode { doubleOut, singleOut }

class PlayerTurn {
  final List<Throw> throws;
  final int scoreBeforeTurn;
  final FinishMode finishMode;

  PlayerTurn({required this.scoreBeforeTurn, this.finishMode = FinishMode.doubleOut}) : throws = [];

  int get totalScore => throws.fold(0, (sum, t) => sum + t.score);
  int get remainingScore => scoreBeforeTurn - totalScore;

  bool get isBust {
    if (finishMode == FinishMode.singleOut) {
      return remainingScore < 0;
    }
    // doubleOut : bust si négatif ou score == 1 (impossible de finir sur un double)
    return remainingScore < 0 || remainingScore == 1;
  }

  bool get isComplete => throws.length == 3 || isWon;

  bool get isWon {
    if (remainingScore != 0 || throws.isEmpty) return false;
    if (finishMode == FinishMode.singleOut) {
      return true; // n'importe quel tir à 0 est valide
    }
    // doubleOut : doit finir sur un double ou bullseye
    final last = throws.last;
    return last.type == ThrowType.double || last.isBullseye;
  }
}

class Player {
  final String name;
  int score;
  List<PlayerTurn> history;
  int dartsThrown;
  int legsWon;

  Player({required this.name})
      : score = 501,
        history = [],
        dartsThrown = 0,
        legsWon = 0;

  double get average {
    if (dartsThrown == 0) return 0;
    final totalScored = history.fold(0, (sum, t) => sum + t.totalScore);
    return (totalScored / dartsThrown) * 3;
  }

  bool get hasWon => score == 0;

  void reset() {
    score = 501;
    history = [];
    dartsThrown = 0;
  }
}

/// Snapshot d'un tour validé, pour pouvoir l'annuler
class _TurnSnapshot {
  final int playerIndex;
  final int scoreBeforeTurn;
  final int dartsThrownInTurn;
  final PlayerTurn turn;

  _TurnSnapshot({
    required this.playerIndex,
    required this.scoreBeforeTurn,
    required this.dartsThrownInTurn,
    required this.turn,
  });
}

class GameModel {
  final List<Player> players;
  int currentPlayerIndex;
  late PlayerTurn currentTurn;
  bool gameOver;
  String? winnerId;
  final FinishMode finishMode;

  /// Historique des tours validés pour l'annulation
  final List<_TurnSnapshot> _turnHistory = [];

  GameModel({
    required List<String> names,
    this.finishMode = FinishMode.doubleOut,
  })  : players = names.map((n) => Player(name: n)).toList(),
        currentPlayerIndex = 0,
        gameOver = false {
    _startNewTurn();
  }

  Player get currentPlayer => players[currentPlayerIndex];

  void _startNewTurn() {
    currentTurn = PlayerTurn(
      scoreBeforeTurn: currentPlayer.score,
      finishMode: finishMode,
    );
  }

  bool addThrow(Throw t) {
    if (gameOver || currentTurn.isComplete) return false;

    currentTurn.throws.add(t);

    if (currentTurn.isBust) return true;

    // Victoire : isWon tient déjà compte du finishMode
    if (currentTurn.isWon) {
      currentPlayer.score = 0;
      currentPlayer.dartsThrown += currentTurn.throws.length;
      currentPlayer.legsWon++;
      gameOver = true;
      winnerId = currentPlayer.name;
      currentPlayer.history.add(currentTurn);
      return true;
    }

    return true;
  }

  void validateTurn() {
    if (gameOver) return;

    // Sauvegarder le snapshot avant validation
    _turnHistory.add(_TurnSnapshot(
      playerIndex: currentPlayerIndex,
      scoreBeforeTurn: currentTurn.scoreBeforeTurn,
      dartsThrownInTurn: currentTurn.throws.length,
      turn: currentTurn,
    ));

    if (currentTurn.isBust) {
      currentPlayer.dartsThrown += currentTurn.throws.length;
      currentPlayer.history.add(currentTurn);
    } else {
      currentPlayer.score = currentTurn.remainingScore;
      currentPlayer.dartsThrown += currentTurn.throws.length;
      currentPlayer.history.add(currentTurn);
    }

    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    _startNewTurn();
  }

  /// Annuler le dernier lancer du tour en cours
  bool undoLastThrow() {
    if (currentTurn.throws.isEmpty) return false;
    currentTurn.throws.removeLast();
    return true;
  }

  /// Annuler le tour entier du joueur précédent
  bool undoLastTurn() {
    if (_turnHistory.isEmpty) return false;

    final snapshot = _turnHistory.removeLast();
    final prevPlayer = players[snapshot.playerIndex];

    // Restaurer le score et les statistiques du joueur précédent
    prevPlayer.score = snapshot.scoreBeforeTurn;
    prevPlayer.dartsThrown -= snapshot.dartsThrownInTurn;
    if (prevPlayer.history.isNotEmpty) prevPlayer.history.removeLast();

    // Revenir au joueur précédent
    currentPlayerIndex = snapshot.playerIndex;
    currentTurn = PlayerTurn(scoreBeforeTurn: currentPlayer.score);

    return true;
  }

  bool get canUndoLastTurn => _turnHistory.isNotEmpty;

  void resetGame() {
    for (final p in players) {
      p.reset();
    }
    currentPlayerIndex = 0;
    gameOver = false;
    winnerId = null;
    _turnHistory.clear();
    _startNewTurn();
  }

  List<String> getCheckoutSuggestion(int score) {
    final Map<int, List<String>> checkouts = {
      170: ['T20', 'T20', 'Bull'],
      167: ['T20', 'T19', 'Bull'],
      164: ['T20', 'T18', 'Bull'],
      161: ['T20', 'T17', 'Bull'],
      160: ['T20', 'T20', 'D20'],
      158: ['T20', 'T20', 'D19'],
      157: ['T20', 'T19', 'D20'],
      156: ['T20', 'T20', 'D18'],
      155: ['T20', 'T19', 'D19'],
      154: ['T20', 'T18', 'D20'],
      153: ['T20', 'T19', 'D18'],
      152: ['T20', 'T20', 'D16'],
      151: ['T20', 'T17', 'D20'],
      150: ['T20', 'T18', 'D18'],
      149: ['T20', 'T19', 'D16'],
      148: ['T20', 'T16', 'D20'],
      147: ['T20', 'T17', 'D18'],
      146: ['T20', 'T18', 'D16'],
      145: ['T20', 'T15', 'D20'],
      144: ['T20', 'T20', 'D12'],
      143: ['T20', 'T17', 'D16'],
      142: ['T20', 'T14', 'D20'],
      141: ['T20', 'T15', 'D18'],
      140: ['T20', 'T20', 'D10'],
      139: ['T20', 'T13', 'D20'],
      138: ['T20', 'T14', 'D18'],
      137: ['T20', 'T15', 'D16'],
      136: ['T20', 'T20', 'D8'],
      135: ['T20', 'T15', 'D15'],
      134: ['T20', 'T14', 'D16'],
      133: ['T20', 'T19', 'D8'],
      132: ['T20', 'T16', 'D12'],
      131: ['T20', 'T13', 'D16'],
      130: ['T20', 'T18', 'D8'],
      129: ['T19', 'T16', 'D12'],
      128: ['T18', 'T14', 'D20'],
      127: ['T20', 'T17', 'D8'],
      126: ['T19', 'T19', 'D6'],
      125: ['T20', 'T15', 'D10'],
      124: ['T20', 'T16', 'D8'],
      123: ['T19', 'T16', 'D9'],
      122: ['T18', 'T18', 'D7'],
      121: ['T20', 'T11', 'D14'],
      120: ['T20', 'S20', 'D20'],
      119: ['T19', 'T12', 'D13'],
      118: ['T20', 'S18', 'D20'],
      117: ['T20', 'S17', 'D20'],
      116: ['T20', 'S16', 'D20'],
      115: ['T20', 'S15', 'D20'],
      114: ['T20', 'S14', 'D20'],
      113: ['T20', 'S13', 'D20'],
      112: ['T20', 'S12', 'D20'],
      111: ['T20', 'S11', 'D20'],
      110: ['T20', 'S10', 'D20'],
      109: ['T20', 'S9', 'D20'],
      108: ['T20', 'S8', 'D20'],
      107: ['T19', 'S10', 'D20'],
      106: ['T20', 'S6', 'D20'],
      105: ['T20', 'S5', 'D20'],
      104: ['T20', 'S4', 'D20'],
      103: ['T20', 'S3', 'D20'],
      102: ['T20', 'S2', 'D20'],
      101: ['T17', 'S10', 'D20'],
      100: ['T20', 'D20'],
      99: ['T19', 'S10', 'D16'],
      98: ['T20', 'D19'],
      97: ['T19', 'D20'],
      96: ['T20', 'D18'],
      95: ['T19', 'D19'],
      94: ['T18', 'D20'],
      93: ['T19', 'D18'],
      92: ['T20', 'D16'],
      91: ['T17', 'D20'],
      90: ['T18', 'D18'],
      89: ['T19', 'D16'],
      88: ['T20', 'D14'],
      87: ['T17', 'D18'],
      86: ['T18', 'D16'],
      85: ['T15', 'D20'],
      84: ['T20', 'D12'],
      83: ['T17', 'D16'],
      82: ['T14', 'D20'],
      81: ['T15', 'D18'],
      80: ['T20', 'D10'],
      79: ['T13', 'D20'],
      78: ['T14', 'D18'],
      77: ['T15', 'D16'],
      76: ['T20', 'D8'],
      75: ['T15', 'D15'],
      74: ['T14', 'D16'],
      73: ['T19', 'D8'],
      72: ['T16', 'D12'],
      71: ['T13', 'D16'],
      70: ['T18', 'D8'],
      69: ['T19', 'D6'],
      68: ['T20', 'D4'],
      67: ['T17', 'D8'],
      66: ['T10', 'D18'],
      65: ['T15', 'D10'],
      64: ['T16', 'D8'],
      63: ['T13', 'D12'],
      62: ['T10', 'D16'],
      61: ['T15', 'D8'],
      60: ['S20', 'D20'],
      59: ['S19', 'D20'],
      58: ['S18', 'D20'],
      57: ['S17', 'D20'],
      56: ['T16', 'D4'],
      55: ['S15', 'D20'],
      54: ['S14', 'D20'],
      53: ['S13', 'D20'],
      52: ['S12', 'D20'],
      51: ['S11', 'D20'],
      50: ['Bull'],
      49: ['S9', 'D20'],
      48: ['S8', 'D20'],
      47: ['S7', 'D20'],
      46: ['S6', 'D20'],
      45: ['S5', 'D20'],
      44: ['S4', 'D20'],
      43: ['S3', 'D20'],
      42: ['S10', 'D16'],
      41: ['S1', 'D20'],
      40: ['D20'],
      39: ['S7', 'D16'],
      38: ['D19'],
      37: ['S5', 'D16'],
      36: ['D18'],
      35: ['S3', 'D16'],
      34: ['D17'],
      33: ['S1', 'D16'],
      32: ['D16'],
      31: ['S7', 'D12'],
      30: ['D15'],
      29: ['S1', 'D14'],
      28: ['D14'],
      27: ['S3', 'D12'],
      26: ['D13'],
      25: ['S9', 'D8'],
      24: ['D12'],
      23: ['S7', 'D8'],
      22: ['D11'],
      21: ['S5', 'D8'],
      20: ['D10'],
      18: ['D9'],
      16: ['D8'],
      14: ['D7'],
      12: ['D6'],
      10: ['D5'],
      8: ['D4'],
      6: ['D3'],
      4: ['D2'],
      2: ['D1'],
    };
    return checkouts[score] ?? [];
  }
}
