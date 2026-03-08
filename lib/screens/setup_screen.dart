// lib/screens/setup_screen.dart
import 'package:flutter/material.dart';
import '../models/game_model.dart';
import 'game_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen>
    with SingleTickerProviderStateMixin {
  final _p1Controller = TextEditingController(text: 'Joueur 1');
  final _p2Controller = TextEditingController(text: 'Joueur 2');
  final _p3Controller = TextEditingController(text: 'Joueur 3');
  int _playerCount = 2;
  FinishMode _finishMode = FinishMode.doubleOut;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _p1Controller.dispose();
    _p2Controller.dispose();
    _p3Controller.dispose();
    super.dispose();
  }

  void _startGame() {
    final names = [
      _p1Controller.text.trim().isEmpty ? 'Joueur 1' : _p1Controller.text.trim(),
      _p2Controller.text.trim().isEmpty ? 'Joueur 2' : _p2Controller.text.trim(),
      if (_playerCount == 3)
        _p3Controller.text.trim().isEmpty ? 'Joueur 3' : _p3Controller.text.trim(),
    ];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => GameScreen(
          game: GameModel(names: names, finishMode: _finishMode),
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.3),
            radius: 1.2,
            colors: [Color(0xFF1A1A2E), Color(0xFF0A0A0F)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildPlayerCountSelector(),
                    const SizedBox(height: 12),
                    _buildFinishModeSelector(),
                    const SizedBox(height: 32),
                    _buildPlayerField(_p1Controller, 'Joueur 1', Icons.person,
                        const Color(0xFFE8C547)),
                    const SizedBox(height: 16),
                    _buildVsDivider(),
                    const SizedBox(height: 16),
                    _buildPlayerField(_p2Controller, 'Joueur 2',
                        Icons.person_outline, const Color(0xFF4ECDC4)),
                    if (_playerCount == 3) ...[
                      const SizedBox(height: 16),
                      _buildVsDivider(),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        opacity: _playerCount == 3 ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: _buildPlayerField(
                            _p3Controller,
                            'Joueur 3',
                            Icons.person_2_outlined,
                            const Color(0xFFFF6B9D)),
                      ),
                    ],
                    const SizedBox(height: 48),
                    _buildStartButton(),
                    const SizedBox(height: 24),
                    _buildRulesNote(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCountSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _countBtn(2),
          _countBtn(3),
        ],
      ),
    );
  }

  Widget _countBtn(int count) {
    final isSelected = _playerCount == count;
    const color = Color(0xFFE8C547);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _playerCount = count),
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
            '$count joueurs',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? color : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'MODE DE FIN',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141420),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _finishBtn('Double Out', FinishMode.doubleOut, const Color(0xFF4ECDC4),
                  'Finir sur un double'),
              _finishBtn('Single Out', FinishMode.singleOut, const Color(0xFFFF6B9D),
                  'N\'importe quel tir'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _finishBtn(String label, FinishMode mode, Color color, String sub) {
    final isSelected = _finishMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _finishMode = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.6) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? color : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1,
                ),
              ),
              Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? color.withOpacity(0.6) : Colors.white24,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE8C547), width: 2),
            gradient: const RadialGradient(
              colors: [Color(0xFF2A2A1A), Color(0xFF141410)],
            ),
          ),
          child: const Center(
            child: Text('🎯', style: TextStyle(fontSize: 44)),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'FLÉCHETTES',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Color(0xFFE8C547),
            letterSpacing: 8,
          ),
        ),
        const Text(
          '501',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 0.9,
            letterSpacing: -4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Règles Officielles',
            style: TextStyle(
                color: Colors.white54, fontSize: 13, letterSpacing: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerField(TextEditingController ctrl, String hint,
      IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        color: color.withOpacity(0.05),
      ),
      child: TextField(
        controller: ctrl,
        style: TextStyle(
            color: color, fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: color.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: color.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildVsDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white12, thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('VS',
              style: TextStyle(
                  color: Colors.white38,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4)),
        ),
        Expanded(child: Divider(color: Colors.white12, thickness: 1)),
      ],
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startGame,
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
          'COMMENCER LA PARTIE',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF0A0A0F),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildRulesNote() {
    return const Text(
      'Double requis pour terminer • Bust = tour annulé',
      textAlign: TextAlign.center,
      style:
          TextStyle(color: Colors.white30, fontSize: 12, letterSpacing: 1),
    );
  }
}
