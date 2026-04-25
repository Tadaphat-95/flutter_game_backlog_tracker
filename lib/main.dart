import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_game_backlog_tracker/services/notification_service.dart';
import 'package:flutter_game_backlog_tracker/views/splash_screen_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // เริ่มต้น Supabase
  await Supabase.initialize(
    url: 'https://fpjxnwpkuotcjlyapshw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZwanhud3BrdW90Y2pseWFwc2h3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2NjUwODgsImV4cCI6MjA5MjI0MTA4OH0.MnjomYpBgULYvLBFEypg1jhnVfa_vNadIkNCm9ogbQA',
  );

  // เริ่มต้น Notification
  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Backlog Tracker',
      debugShowCheckedModeBanner: false,
      // ✅ Dark Theme
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFF5C14A),
          secondary: const Color(0xFFF5C14A),
          surface: const Color(0xFF1A1A1A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F0F),
          foregroundColor: Color(0xFFF0F0F0),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF5C14A),
            foregroundColor: const Color(0xFF0F0F0F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF5C14A)),
          ),
          hintStyle: const TextStyle(color: Color(0xFF555555)),
          labelStyle: const TextStyle(color: Color(0xFF888888)),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          elevation: 0,
        ),
      ),
      home: const SplashScreenUi(),
    );
  }
}
