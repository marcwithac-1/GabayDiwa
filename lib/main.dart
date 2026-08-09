import 'package:flutter/material.dart';
import 'screens/intro_screen.dart'; // Import your new file
import 'package:flutter/gestures.dart';

void main() {
  runApp(const GabayDiwaApp());
}

// Custom ScrollBehavior allowing mouse drag across Web & Desktop
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse, // Enables mouse click-and-drag
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
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