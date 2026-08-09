import 'dart:async';
import 'package:flutter/material.dart';
import 'name_input_screen.dart'; // Make sure the import path matches your project structure
import 'package:gabaydiwa/widgets/blinking_mercy_welcome.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // 1. Automatically navigate after 2 seconds
    _navigationTimer = Timer(const Duration(seconds: 5), () {
      _navigateToNameInput();
    });
  }

  @override
  void dispose() {
    // Clean up timer when screen is destroyed
    _navigationTimer?.cancel();
    super.dispose();
  }

  // Safe navigation function that prevents triggering navigation twice
  void _navigateToNameInput() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    // Cancel timer if it was triggered by user tap
    _navigationTimer?.cancel();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const NameInputScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);
    const skyBlue = Color(0xFF63A0E8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // GestureDetector wraps the entire screen to register user taps
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _navigateToNameInput, // Trigger navigation instantly on tap
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: [
                // 1. Top Decorative Waves Header
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/top_right_waves1.png',
                    width: 460,
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),

                // 2. Top Left Small Logo (Background)
                Positioned(
                  top: 30,
                  left: 24,
                  child: Image.asset(
                    'assets/images/logo_icon.png',
                    width: 58,
                    height: 58,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.blur_circular_rounded,
                        size: 58,
                        color: primaryPurple,
                      );
                    },
                  ),
                ),

                // 2. Centered Welcome Text
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.3,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          TextSpan(
                            text: 'Kamusta? ',
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: "I'm ",
                            style: TextStyle(
                              color: softPurple,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: 'Mercy.\n',
                            style: TextStyle(
                              color: softPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'Welcome to ',
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: 'Gabay',
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Diwa!',
                            style: TextStyle(
                              color: skyBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. Bottom Peeking Mascot (Mercy)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 320,
                  child: IgnorePointer(
                    child: BlinkingMercy(
                      height: 320,
                      width: double.infinity, // Forces the child SizedBox to span edge-to-edge
                      fit: BoxFit.fitWidth,
                      openAsset: 'assets/images/mercy_mascot.png',
                      closedAsset: 'assets/images/mercy_mascot_blink.png',
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}