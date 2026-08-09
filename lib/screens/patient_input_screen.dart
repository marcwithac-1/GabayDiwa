import 'package:flutter/material.dart';
import 'setup_prompt_screen.dart';
import 'package:gabaydiwa/widgets/blinking_mercy_welcome.dart';

class PatientInputScreen extends StatefulWidget {
  final String userName;

  const PatientInputScreen({
    super.key,
    required this.userName,
  });

  @override
  State<PatientInputScreen> createState() => _PatientInputScreenState();
}

class _PatientInputScreenState extends State<PatientInputScreen> {
  final TextEditingController _patientController = TextEditingController();

  @override
  void dispose() {
    _patientController.dispose();
    super.dispose();
  }

  void _submitPatientName() {
    final patientName = _patientController.text.trim();
    if (patientName.isNotEmpty) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              SetupPromptScreen(
            userName: widget.userName,
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
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Stack(
              children: [
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
                  bottom: -320,
                  left: 0,
                  right: 0,
                  top: 0,
                  child: IgnorePointer(
                    child: BlinkingMercy(
                      height: 500,
                      width: double.infinity, // Expands the width edge-to-edge
                      fit: BoxFit.contain,
                      openAsset: 'assets/images/mercy_patient.png',
                      closedAsset: 'assets/images/mercy_patient_blink.png',
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
                          // Dynamic Heading with User Name
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 25,
                                height: 1.35,
                                fontFamily: 'Poppins',
                              ),
                              children: [
                                TextSpan(
                                  text: 'Hi, ${widget.userName}! ',
                                  style: const TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'I need to ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'know\n',
                                  style: TextStyle(
                                    color: skyBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(
                                  text: "who you're taking ",
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'care of.',
                                  style: TextStyle(
                                    color: softPurple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Gradient Border Input Field for Patient Name
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
                                controller: _patientController,
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
                                  hintText: "Enter patient's name...",
                                  hintStyle: TextStyle(
                                    color: softPurple.withValues(alpha: 0.5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  // Wheelchair / Accessibility Icon
                                  prefixIcon: ShaderMask(
                                    shaderCallback: (Rect bounds) {
                                      return const LinearGradient(
                                        colors: [primaryPurple, skyBlue],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ).createShader(bounds);
                                    },
                                    child: const Icon(
                                      Icons.accessible,
                                      size: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                  // Arrow Submit Button inside the field
                                  suffixIcon: IconButton(
                                    icon: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade200,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onPressed: _submitPatientName,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 16,
                                  ),
                                ),
                                onSubmitted: (_) => _submitPatientName(),
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