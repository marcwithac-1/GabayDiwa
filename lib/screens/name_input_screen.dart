import 'package:flutter/material.dart';
import 'patient_input_screen.dart';
import 'package:gabaydiwa/widgets/blinking_mercy_welcome.dart';

class NameInputScreen extends StatefulWidget {
  const NameInputScreen({super.key});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitName() {
  final name = _nameController.text.trim();
  if (name.isNotEmpty) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PatientInputScreen(userName: name),
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
}

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);
    const skyBlue = Color(0xFF63A0E8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GestureDetector(
        // Dismiss keyboard when tapping anywhere outside the input field
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
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
                  bottom: 0,
                  left: 80,
                  right: 0,
                  child: IgnorePointer(
                    child: BlinkingMercy(
                      height: 480,
                      fit: BoxFit.contain,
                      openAsset: 'assets/images/mercy_name.png',
                      closedAsset: 'assets/images/mercy_name_blink.png', // Replace with your closed-eyes asset filename if different
                    ),
                  ),
                ),

                // 4. Middle Content (Interactive Layer)
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Styled Heading
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
                                  text: 'First, I need to ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'know\n',
                                  style: TextStyle(
                                    color: skyBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: 'your ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'name.',
                                  style: TextStyle(
                                    color: softPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Gradient Border Input Field
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  primaryPurple,
                                  softPurple,
                                  skyBlue,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: TextField(
                                controller: _nameController,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(
                                  color: primaryPurple,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                cursorColor: primaryPurple,
                                decoration: InputDecoration(
                                  hintText: 'Enter your name...',
                                  hintStyle: TextStyle(
                                    // Updated to .withValues(alpha: 0.5)
                                    color: softPurple.withValues(alpha: 0.5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  prefixIcon: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [primaryPurple, skyBlue],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ).createShader(bounds);
                                    },
                                    child: const Icon(
                                      Icons.person,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                ),
                                onSubmitted: (_) => _submitName(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}