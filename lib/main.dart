import 'package:flutter/material.dart';
import 'screens/intro_screen.dart'; // Import your new file

void main() {
  runApp(const GabayDiwaApp());
}

class GabayDiwaApp extends StatelessWidget {
  const GabayDiwaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GabayDiwa',
      home: const IntroScreen(),
    );
  }
}