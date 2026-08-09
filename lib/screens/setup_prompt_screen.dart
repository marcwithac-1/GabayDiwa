import 'package:flutter/material.dart';
import 'showcase_welcome_screen.dart';
import 'setup_form_screen.dart';
import 'package:gabaydiwa/widgets/blinking_mercy_welcome.dart';

class SetupPromptScreen extends StatelessWidget {
  final String userName;
  final String patientName;

  const SetupPromptScreen({
    super.key,
    required this.userName,
    required this.patientName,
  });

  void _onNowPressed(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SetupFormScreen(
          userName: userName,
          patientName: patientName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _onLaterPressed(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ShowcaseWelcomeScreen(
          userName: userName,
          patientName: patientName,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);
    const skyBlue = Color(0xFF63A0E8);
    const textColor = Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 450),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: Stack(
            children: [
              // 1. Top Right Wave Graphic (Background)
              Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    'assets/images/top_right_waves.png',
                    width: 390,
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

                // 3. Bottom Peeking Mercy Mascot (Background - MUST BE BEFORE INPUT FIELD)
                Positioned(
                  bottom: -280,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: BlinkingMercy(
                      height: 500,
                      fit: BoxFit.contain,
                      openAsset: 'assets/images/mercy_patient.png',
                      closedAsset: 'assets/images/mercy_patient_blink.png', // Replace with your closed-eyes asset filename if different
                    ),
                  ),
                ),
              // 4. Middle Content (Title + Choice Buttons)
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Heading Question
                        RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 26,
                              height: 1.35,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              TextSpan(
                                text: 'Awesome! ',
                                style: TextStyle(
                                  color: primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'Do you ',
                                style: TextStyle(
                                  color: primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'want\n',
                                style: TextStyle(
                                  color: skyBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: 'to set up ',
                                style: TextStyle(
                                  color: primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'now ',
                                style: TextStyle(
                                  color: primaryPurple,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: 'or ',
                                style: TextStyle(
                                  color: softPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: 'later?',
                                style: TextStyle(
                                  color: skyBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Option Choices: Now! vs Later.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // "Now!" Option
                            InkWell(
                              onTap: () => _onNowPressed(context),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  'Now!',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),

                            // "Later." Option
                            InkWell(
                              onTap: () => _onLaterPressed(context),
                              borderRadius: BorderRadius.circular(12),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 12.0,
                                ),
                                child: Text(
                                  'Later.',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}