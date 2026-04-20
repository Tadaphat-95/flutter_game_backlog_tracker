import 'package:flutter/material.dart';
import 'package:flutter_game_backlog_tracker/views/show_all_game_ui.dart';

class SplashScreenUi extends StatefulWidget {
  const SplashScreenUi({super.key});

  @override
  State<SplashScreenUi> createState() => _SplashScreenUiState();
}

class _SplashScreenUiState extends State<SplashScreenUi> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ShowAllGameUi(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon เกม
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: const Icon(
                Icons.sports_esports_rounded,
                size: 70,
                color: Color(0xFFF5C14A),
              ),
            ),
            const SizedBox(height: 24),
            // ชื่อแอป
            const Text(
              'Game Backlog',
              style: TextStyle(
                color: Color(0xFFF5C14A),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const Text(
              'Tracker',
              style: TextStyle(
                color: Color(0xFFF0F0F0),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'จัดการ Backlog ของคุณ',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            // Loading
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFF5C14A),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}