import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const AppActorExampleApp());
}

class AppActorExampleApp extends StatelessWidget {
  const AppActorExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppActor Flutter Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6366F1),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
