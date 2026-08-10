import 'dart:math' as math;
import 'package:flutter/material.dart';

class GabayBoardScreen extends StatefulWidget {
  final String patientName;
  final String patientGender;
  final Map<String, Set<String>> loggedSymptomsByDate;
  final VoidCallback onSeeFullReportPressed;

  const GabayBoardScreen({
    super.key,
    required this.patientName,
    required this.patientGender,
    required this.loggedSymptomsByDate,
    required this.onSeeFullReportPressed,
  });

  @override
  State<GabayBoardScreen> createState() => _GabayBoardScreenState();
}

class _GabayBoardScreenState extends State<GabayBoardScreen> {
  // Helper to strictly override display title to Lolo/Lola based on gender
  String get _patientDisplayTitle {
    final g = widget.patientGender.trim().toLowerCase();
    if (g == 'male') {
      return 'Lolo';
    } else if (g == 'female') {
      return 'Lola';
    }
    if (widget.patientName.trim().isNotEmpty) {
      return widget.patientName;
    }
    return 'Lolo/Lola';
  }

  String _getFormattedDateRange() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[now.month - 1]} ${now.day} - Current";
  }

  Map<String, int> _getDomainCounts() {
    Map<String, int> counts = {
      'Cognitive': 0,
      'Mood': 0,
      'Sleep': 0,
      'ADL': 0,
      'Memory': 0,
      'Safety': 0,
    };

    widget.loggedSymptomsByDate.forEach((_, symptoms) {
      for (var item in symptoms) {
        if (!item.toLowerCase().contains('none')) {
          final l = item.toLowerCase();
          if (l.contains('cognitive') || l.contains('decision') || l.contains('money')) {
            counts['Cognitive'] = counts['Cognitive']! + 1;
          }
          if (l.contains('mood') || l.contains('anger') || l.contains('sad') || l.contains('anxiety')) {
            counts['Mood'] = counts['Mood']! + 1;
          }
          if (l.contains('sleep') || l.contains('sleeping')) {
            counts['Sleep'] = counts['Sleep']! + 1;
          }
          if (l.contains('daily') || l.contains('meal') || l.contains('bath') || l.contains('grooming')) {
            counts['ADL'] = counts['ADL']! + 1;
          }
          if (l.contains('name') || l.contains('item') || l.contains('forgot') || l.contains('task')) {
            counts['Memory'] = counts['Memory']! + 1;
          }
          if (l.contains('risk') || l.contains('dizzy') || l.contains('fall') || l.contains('wander') || l.contains('balance')) {
            counts['Safety'] = counts['Safety']! + 1;
          }
        }
      }
    });

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6B21A8);
    const softBgColor = Color(0xFFF9F8FE);
    const darkText = Color(0xFF1E1E1E);

    final counts = _getDomainCounts();
    final totalBadLogs = counts.values.fold(0, (sum, val) => sum + val);
    final hasLogs = totalBadLogs > 0;

    final stabilityScore = (100 - (totalBadLogs * 6)).clamp(40, 100);
    final performanceScore = (100 - (counts['Cognitive']! * 8) - (counts['Memory']! * 5)).clamp(30, 100);
    
    final moodState = counts['Mood']! > 2
        ? 'Irritability Spikes'
        : (counts['Mood']! > 0 ? 'Mild Agitation' : 'Stable Mood');

    final sleepState = counts['Sleep']! > 1
        ? 'Decline in Night Rest'
        : (counts['Sleep']! > 0 ? 'Mild Rest Disruption' : 'Restful Rest');

    final int adlAssisted = (counts['ADL']! * 15).clamp(0, 70);
    final int adlIndependent = 100 - adlAssisted;

    final title = _patientDisplayTitle;

    return Scaffold(
      backgroundColor: softBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo_icon.png',
                    width: 44,
                    height: 44,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.blur_circular_rounded,
                      size: 44,
                      color: primaryPurple,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      "$title's GabayBoard",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _getFormattedDateRange(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (!hasLogs) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 36,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.grid_view_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No activity logs available yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Log daily symptoms on the dashboard to populate live cognitive activity, performance metrics, and safety alerts here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                              fontFamily: 'Poppins',
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // --- 3D BRAIN OVERLAY WITH COGNITIVE ACTIVITY CARD ---
                    Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Background Brain Graphic Replacement
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Center(
                            child: Image.asset(
                              'assets/images/brain_board.png',
                              height: 250,
                              width: 250,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.psychology_rounded,
                                size: 220,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: 210,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.psychology_outlined,
                                        size: 18, color: darkText),
                                    SizedBox(width: 6),
                                    Text(
                                      'Cognitive Activity',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: darkText,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Cognitive Stability',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$stabilityScore%',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: darkText,
                                      ),
                                    ),
                                    Text(
                                      stabilityScore > 75 ? 'Normal' : 'Decline',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: stabilityScore > 75
                                            ? Colors.grey
                                            : Colors.red.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Stress Level',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    Text(
                                      counts['Mood']! > 1 ? 'Elevated' : 'Normal',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: counts['Mood']! > 1
                                            ? Colors.amber.shade800
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 24,
                                  width: double.infinity,
                                  child: CustomPaint(painter: _ECGWavePainter()),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.82,
                      children: [
                        _buildMetricCard(
                          icon: Icons.psychology_rounded,
                          title: 'Cognitive Performance',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 80,
                                    width: double.infinity,
                                    child: CustomPaint(
                                        painter: _ExactBubbleChartPainter()),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '$performanceScore/100',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                  Text(
                                    performanceScore > 75 ? 'Normal' : 'Requires Care',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: performanceScore > 75
                                          ? darkText
                                          : Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        _buildMetricCard(
                          icon: Icons.sentiment_satisfied_alt_rounded,
                          title: 'Mood and Emotions',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 65,
                                    width: double.infinity,
                                    child: CustomPaint(
                                        painter: _WaveformRibbonPainter()),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    moodState,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                  Text(
                                    counts['Mood']! > 0
                                        ? '${counts['Mood']} Irritability Spike(s)'
                                        : 'Stable baseline',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        _buildMetricCard(
                          icon: Icons.bedtime_outlined,
                          title: 'Sleep and Circadian Rhythm',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 65,
                                    width: double.infinity,
                                    child: CustomPaint(
                                        painter: _ExactStackedBarChartPainter()),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      _TinyDot(color: Color(0xFF81D4FA), label: 'Agitated'),
                                      SizedBox(width: 8),
                                      _TinyDot(color: Color(0xFF9FA8DA), label: 'Deep Sleep'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    sleepState,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        _buildMetricCard(
                          icon: Icons.fitness_center_rounded,
                          title: 'Daily Living Activities',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 70,
                                    width: 70,
                                    child: CustomPaint(
                                      painter: _ExactDonutChartPainter(
                                        independentPct: adlIndependent.toDouble(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '$adlIndependent% Independent\n$adlAssisted% Assisted',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                ),
                              ),
                            ],
                          ),
                        ),

                        _buildMetricCard(
                          icon: Icons.lightbulb_outline_rounded,
                          title: 'Memory and Learning',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: CustomPaint(
                                        painter: _ExactSmoothCurvePainter()),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    counts['Memory']! > 1 ? 'Deficit Observed' : 'Stable',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                  const Text(
                                    'Chronic Memory Deficit',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        _buildMetricCard(
                          icon: Icons.favorite_border_rounded,
                          title: 'Safety & Health',
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: SizedBox(
                                    height: 50,
                                    width: double.infinity,
                                    child: CustomPaint(
                                        painter: _ExactPeakLinePainter()),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    counts['Safety']! > 0 ? 'Safety Alert:' : 'Normal Status',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: counts['Safety']! > 0
                                          ? Colors.red.shade700
                                          : darkText,
                                    ),
                                  ),
                                  Text(
                                    counts['Safety']! > 0
                                        ? '${counts['Safety']} Incident(s) Logged'
                                        : 'No active hazards',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  Center(
                    child: TextButton(
                      onPressed: widget.onSeeFullReportPressed,
                      child: Text(
                        "See $title's Full Report →",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE8FF).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1E1E1E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _TinyDot extends StatelessWidget {
  final Color color;
  final String label;

  const _TinyDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ECGWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B21A8)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(size.width * 0.15, size.height * 0.5)
      ..lineTo(size.width * 0.25, size.height * 0.1)
      ..lineTo(size.width * 0.35, size.height * 0.9)
      ..lineTo(size.width * 0.45, size.height * 0.5)
      ..lineTo(size.width * 0.55, size.height * 0.1)
      ..lineTo(size.width * 0.65, size.height * 0.9)
      ..lineTo(size.width * 0.75, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExactBubbleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final pLarge = Paint()..color = const Color(0xFFA78BFA);
    canvas.drawCircle(Offset(cx + 2, cy - 2), 24, pLarge);

    final pLightBlue = Paint()..color = const Color(0xFFC7EBF9);
    canvas.drawCircle(Offset(cx - 28, cy + 8), 16, pLightBlue);

    final pSoftBlue = Paint()..color = const Color(0xFF81D4FA);
    canvas.drawCircle(Offset(cx - 16, cy - 16), 11, pSoftBlue);

    final pLav = Paint()..color = const Color(0xFFC4B5FD);
    canvas.drawCircle(Offset(cx - 36, cy - 12), 12, pLav);

    final pDeepPurple = Paint()..color = const Color(0xFF7E22CE);
    canvas.drawCircle(Offset(cx + 28, cy - 18), 10, pDeepPurple);

    final pSmallSky = Paint()..color = const Color(0xFF81D4FA);
    canvas.drawCircle(Offset(cx + 20, cy + 22), 9, pSmallSky);

    final pTinyLight = Paint()..color = const Color(0xFFE0F2FE);
    canvas.drawCircle(Offset(cx + 30, cy + 26), 6, pTinyLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaveformRibbonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h / 2;

    final paint1 = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = const Color(0xFF7C3AED).withValues(alpha: 0.5)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final paint3 = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.4)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path1 = Path()..moveTo(0, cy);
    for (double x = 0; x <= w; x += 2) {
      double y = cy + math.sin(x * 0.1) * (18 * math.sin(x / w * math.pi));
      path1.lineTo(x, y);
    }
    canvas.drawPath(path1, paint1);

    final path2 = Path()..moveTo(0, cy);
    for (double x = 0; x <= w; x += 2) {
      double y = cy - math.sin(x * 0.12 + 0.5) * (20 * math.sin(x / w * math.pi));
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint2);

    final path3 = Path()..moveTo(0, cy);
    for (double x = 0; x <= w; x += 2) {
      double y = cy + math.cos(x * 0.15) * (12 * math.sin(x / w * math.pi));
      path3.lineTo(x, y);
    }
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExactStackedBarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pDeep = Paint()..color = const Color(0xFF9FA8DA);
    final pTop = Paint()..color = const Color(0xFF81D4FA);

    const int barCount = 6;
    final double spacing = 4.0;
    final double totalSpacing = spacing * (barCount - 1);
    final double barWidth = (size.width - totalSpacing) / barCount;

    final List<double> deepHeights = [0.70, 0.65, 0.68, 0.55, 0.62, 0.65];
    final List<double> topHeights = [0.15, 0.20, 0.12, 0.18, 0.15, 0.16];

    for (int i = 0; i < barCount; i++) {
      double x = i * (barWidth + spacing);
      double totalH = size.height;

      double dH = totalH * deepHeights[i];
      double tH = totalH * topHeights[i];

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, totalH - dH, barWidth, dH),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
        pDeep,
      );

      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, totalH - dH - tH - 2, barWidth, tH),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2),
        ),
        pTop,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExactDonutChartPainter extends CustomPainter {
  final double independentPct;

  _ExactDonutChartPainter({required this.independentPct});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    final pPurple = Paint()
      ..color = const Color(0xFFA78BFA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    final pBlue = Paint()
      ..color = const Color(0xFF81D4FA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;

    double sweepAngle = (independentPct / 100.0) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      pPurple,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + sweepAngle,
      (2 * math.pi) - sweepAngle,
      false,
      pBlue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExactSmoothCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA78BFA)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.7)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.85,
        size.width * 0.75,
        size.height * 0.25,
        size.width,
        size.height * 0.65,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExactPeakLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF81D4FA)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..lineTo(size.width * 0.68, size.height * 0.15)
      ..lineTo(size.width, size.height * 0.65);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}