// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/setup_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const Dart501App());
}

class Dart501App extends StatelessWidget {
  const Dart501App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fléchettes 501',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE8C547),
          secondary: Color(0xFF4ECDC4),
          surface: Color(0xFF141420),
          error: Color(0xFFFF4757),
        ),
        useMaterial3: true,
      ),
      home: const SetupScreen(),
    );
  }
}
