import 'package:flutter/material.dart';
import 'main_dashboard_screen.dart';

class ShowcaseWelcomeScreen extends StatelessWidget {
  final String userName;
  final String patientName;
  final String? patientGender;
  final String? age;
  final String? condition;
  final String? status;
  final String? height;
  final String? weight;
  final String? comorbidities;
  final String? healthReportPath;
  final String? healthReportName;
  final String? mriScanPath;
  final String? mriScanName;
  final List<String> familyMembers;

  const ShowcaseWelcomeScreen({
    super.key,
    required this.userName,
    required this.patientName,
    this.patientGender,
    this.age,
    this.condition,
    this.status,
    this.height,
    this.weight,
    this.comorbidities,
    this.healthReportPath,
    this.healthReportName,
    this.mriScanPath,
    this.mriScanName,
    this.familyMembers = const [],
  });

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);
    const skyBlue = Color(0xFF63A0E8);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  MainDashboardScreen(
                patientName: patientName,
                patientGender: patientGender,
                age: age,
                condition: condition,
                status: status,
                height: height,
                weight: weight,
                comorbidities: comorbidities,
                healthReportPath: healthReportPath,
                healthReportName: healthReportName,
                mriScanPath: mriScanPath,
                mriScanName: mriScanName,
                familyMembers: familyMembers,
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
            (route) => false,
          );
        },
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
                    width: 220,
                    fit: BoxFit.contain,
                    alignment: Alignment.topRight,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 24,
                  child: Image.asset(
                    'assets/images/logo_icon.png',
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.blur_circular_rounded,
                        size: 48,
                        color: primaryPurple,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Image.asset(
                      'assets/images/mercy_mascot.png',
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.pets,
                            size: 80, color: softPurple);
                      },
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                  text: 'Got it. ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Welcome ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'to\n',
                                  style: TextStyle(
                                    color: softPurple,
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
                                  text: 'Diwa!\n',
                                  style: TextStyle(
                                    color: skyBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Let me ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'show you ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: 'around.',
                                  style: TextStyle(
                                    color: skyBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
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