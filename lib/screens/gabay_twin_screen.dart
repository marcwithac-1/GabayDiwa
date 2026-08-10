import 'package:flutter/material.dart';

class GabayTwinScreen extends StatefulWidget {
  final String patientName;
  final String patientGender;
  final Map<String, Set<String>> loggedSymptomsByDate;
  final VoidCallback onGenerateReportPressed;

  const GabayTwinScreen({
    super.key,
    required this.patientName,
    required this.patientGender,
    required this.loggedSymptomsByDate,
    required this.onGenerateReportPressed,
  });

  @override
  State<GabayTwinScreen> createState() => _GabayTwinScreenState();
}

class _GabayTwinScreenState extends State<GabayTwinScreen> {
  String get _patientDisplayTitle {
    final g = widget.patientGender.trim().toLowerCase();
    if (g == 'male') return 'Lolo';
    if (g == 'female') return 'Lola';
    if (widget.patientName.trim().isNotEmpty) return widget.patientName;
    return 'Lolo/Lola';
  }

  Map<String, int> _calculateDomainCounts() {
    Map<String, int> counts = {
      'Memory': 0,
      'Language': 0,
      'Mood': 0,
      'Attention': 0,
      'Skills': 0,
    };

    widget.loggedSymptomsByDate.forEach((_, symptoms) {
      for (var item in symptoms) {
        if (!item.toLowerCase().contains('none')) {
          final l = item.toLowerCase();
          if (l.contains('name') || l.contains('item') || l.contains('task') || l.contains('forgot')) {
            counts['Memory'] = counts['Memory']! + 1;
          } else if (l.contains('word') || l.contains('naming') || l.contains('talk')) {
            counts['Language'] = counts['Language']! + 1;
          } else if (l.contains('mood') || l.contains('anger') || l.contains('sad') || l.contains('anxiety')) {
            counts['Mood'] = counts['Mood']! + 1;
          } else if (l.contains('attention') || l.contains('pacing') || l.contains('restless')) {
            counts['Attention'] = counts['Attention']! + 1;
          } else if (l.contains('routine') || l.contains('decision') || l.contains('money')) {
            counts['Skills'] = counts['Skills']! + 1;
          }
        }
      }
    });

    return counts;
  }

  String _getDomainRiskLabel(int count) {
    if (count >= 3) return 'High risk';
    if (count >= 1) return 'Moderate Risk';
    return 'Low risk';
  }

  Color _getDomainRiskColor(int count) {
    if (count >= 3) return const Color(0xFFC084FC); // Purple High
    if (count >= 1) return const Color(0xFFBAE6FD); // Blue Moderate
    return const Color(0xFFF3EEFF); // Soft Lavender Low
  }

  Map<String, Map<int, double>> _calculateProgressionMapData() {
    if (widget.loggedSymptomsByDate.isEmpty) return {};

    final now = DateTime.now();
    Map<String, Map<int, double>> domainScoresByMonthIndex = {
      'Mood': {},
      'Attention': {},
      'Skills': {},
      'Memory': {},
      'Language': {},
    };

    widget.loggedSymptomsByDate.forEach((dateKey, symptoms) {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final monthDiff = (year - now.year) * 12 + (month - now.month);

        int monthSlot = -1;
        if (monthDiff <= 0) {
          monthSlot = 0;
        } else if (monthDiff <= 2) {
          monthSlot = 1;
        } else if (monthDiff <= 4) {
          monthSlot = 2;
        } else if (monthDiff >= 5) {
          monthSlot = 3;
        }

        if (monthSlot != -1) {
          int mood = 0, attention = 0, skills = 0, memory = 0, language = 0;
          for (var s in symptoms) {
            final l = s.toLowerCase();
            if (l.contains('none')) continue;
            if (l.contains('mood') || l.contains('anger') || l.contains('sad')) mood += 25;
            if (l.contains('attention') || l.contains('pacing')) attention += 25;
            if (l.contains('routine') || l.contains('decision')) skills += 25;
            if (l.contains('name') || l.contains('item')) memory += 25;
            if (l.contains('word') || l.contains('talk')) language += 25;
          }

          domainScoresByMonthIndex['Mood']![monthSlot] = (50 + mood).clamp(0, 100).toDouble();
          domainScoresByMonthIndex['Attention']![monthSlot] = (50 + attention).clamp(0, 100).toDouble();
          domainScoresByMonthIndex['Skills']![monthSlot] = (50 + skills).clamp(0, 100).toDouble();
          domainScoresByMonthIndex['Memory']![monthSlot] = (50 + memory).clamp(0, 100).toDouble();
          domainScoresByMonthIndex['Language']![monthSlot] = (50 + language).clamp(0, 100).toDouble();
        }
      }
    });

    return domainScoresByMonthIndex;
  }

  Map<int, double> _calculateWeeklyImpairmentScores() {
    if (widget.loggedSymptomsByDate.isEmpty) return {};

    Map<int, double> weekScores = {};
    widget.loggedSymptomsByDate.forEach((dateKey, symptoms) {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[2]);
        int weekSlot = -1;
        if (day >= 1 && day <= 7) {
          weekSlot = 0;
        } else if (day >= 8 && day <= 14) {
          weekSlot = 1;
        } else if (day >= 15 && day <= 21) {
          weekSlot = 2;
        } else if (day >= 22) {
          weekSlot = 3;
        }

        if (weekSlot != -1) {
          final badSymptoms = symptoms.where((s) => !s.toLowerCase().contains('none')).length;
          double score = (25.0 + (badSymptoms * 12)).clamp(10.0, 95.0);
          weekScores[weekSlot] = score;
        }
      }
    });

    return weekScores;
  }

  List<String> _getLoggedRiskFactors() {
    Set<String> riskFactors = {};
    widget.loggedSymptomsByDate.forEach((_, symptoms) {
      for (var item in symptoms) {
        if (item.startsWith('Risk Factors-') && !item.toLowerCase().contains('none')) {
          riskFactors.add(item.split('-').last);
        }
      }
    });
    return riskFactors.toList();
  }

  List<Map<String, dynamic>> _generateActivityLogs() {
    List<Map<String, dynamic>> logs = [];
    widget.loggedSymptomsByDate.forEach((dateKey, symptoms) {
      final validEvents = symptoms
          .where((s) => !s.toLowerCase().contains('none'))
          .map((s) => s.split('-').last)
          .toList();

      if (validEvents.isNotEmpty) {
        logs.add({
          'date': dateKey,
          'events': validEvents,
        });
      }
    });
    return logs;
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6B21A8);
    const softBgColor = Color(0xFFF9F8FE);
    const darkText = Color(0xFF1E1E1E);

    final title = _patientDisplayTitle;
    final domainCounts = _calculateDomainCounts();
    final activityLogs = _generateActivityLogs();
    final hasLogs = activityLogs.isNotEmpty;

    final totalBadLogs = domainCounts.values.fold(0, (sum, val) => sum + val);

    String mostAffected = 'Mood';
    String mostStable = 'Memory';
    if (hasLogs) {
      final sortedDomains = domainCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostAffected = sortedDomains.first.key;
      mostStable = sortedDomains.last.key;
    }

    final progressionMapData = _calculateProgressionMapData();
    final impairmentWeeklyScores = _calculateWeeklyImpairmentScores();
    final riskFactors = _getLoggedRiskFactors();

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
                  // LOGO HEADER
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

                  // TITLE HEADER
                  Center(
                    child: Text(
                      "$title's GabayTwin",
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: darkText,
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
                            Icons.psychology_outlined,
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
                            'Log daily symptoms on the dashboard to automatically generate cognitive risk levels, progression maps, and AI insights.',
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
                    // --- 3D BRAIN GRAPHIC WITH FLOATING DOMAIN CHIPS ---
                    SizedBox(
                      height: 380, // 1. INCREASE THIS TO ALLOW MORE VERTICAL SPACE FOR THE BRAIN
                      width: double.infinity,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Central Brain Graphic
                          Image.asset(
                            'assets/images/brain_chip.png',
                            height: 1200, // 2. SET A REALISTIC LARGER HEIGHT (e.g., 280 - 320)
                            width: 1200,  // 2. MATCH THE WIDTH TO FIT ACCURATELY
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.psychology_rounded,
                              size: 240,
                              color: Colors.grey.shade300,
                            ),
                          ),

                          // Top Left: Memory
                          Positioned(
                            left: 0,
                            top: 0,
                            child: _buildRiskChip(
                              domain: 'MEMORY',
                              riskLabel: _getDomainRiskLabel(domainCounts['Memory']!),
                              bgColor: _getDomainRiskColor(domainCounts['Memory']!),
                            ),
                          ),

                          // Top Right: Language
                          Positioned(
                            right: 0,
                            top: 0,
                            child: _buildRiskChip(
                              domain: 'LANGUAGE',
                              riskLabel: _getDomainRiskLabel(domainCounts['Language']!),
                              bgColor: _getDomainRiskColor(domainCounts['Language']!),
                            ),
                          ),

                          // Middle Left: Skills
                          Positioned(
                            left: 0,
                            top: 140, // 3. ADJUSTED POSITIONS FOR THE LARGER GRAPHIC
                            child: _buildRiskChip(
                              domain: 'SKILLS',
                              riskLabel: _getDomainRiskLabel(domainCounts['Skills']!),
                              bgColor: _getDomainRiskColor(domainCounts['Skills']!),
                            ),
                          ),

                          // Middle Right: Mood
                          Positioned(
                            right: 0,
                            top: 130, // 3. ADJUSTED POSITIONS FOR THE LARGER GRAPHIC
                            child: _buildRiskChip(
                              domain: 'MOOD',
                              riskLabel: _getDomainRiskLabel(domainCounts['Mood']!),
                              bgColor: _getDomainRiskColor(domainCounts['Mood']!),
                            ),
                          ),

                          // Bottom Center: Attention
                          Positioned(
                            bottom: 0,
                            child: _buildRiskChip(
                              domain: 'ATTENTION',
                              riskLabel: _getDomainRiskLabel(domainCounts['Attention']!),
                              bgColor: _getDomainRiskColor(domainCounts['Attention']!),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- CURRENT COGNITIVE HEALTH BANNER ---
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Current Cognitive Health:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            totalBadLogs > 5
                                ? 'HIGH RISK of progression'
                                : (totalBadLogs > 1
                                    ? 'MODERATE RISK of progression'
                                    : 'LOW RISK of progression'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: totalBadLogs > 5
                                  ? const Color(0xFFC084FC)
                                  : (totalBadLogs > 1
                                      ? const Color(0xFF38BDF8)
                                      : const Color(0xFF34D399)),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Progression stability decreased by ${(totalBadLogs * 3).clamp(1, 45)}% in the last 7 days.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- PROGRESSION MAP CARD ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Progression Map',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 6,
                            children: const [
                              _LegendDot(color: Color(0xFF818CF8), label: 'Mood'),
                              _LegendDot(color: Color(0xFF38BDF8), label: 'Attention'),
                              _LegendDot(color: Color(0xFF60A5FA), label: 'Skills'),
                              _LegendDot(color: Color(0xFFA78BFA), label: 'Memory'),
                              _LegendDot(color: Color(0xFFC084FC), label: 'Language'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _StrictProgressionChartPainter(
                                domainScoresByMonthIndex: progressionMapData,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // HIGHLIGHTS TEXT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: darkText,
                                fontFamily: 'Poppins',
                              ),
                              children: [
                                TextSpan(text: "• $title's "),
                                TextSpan(
                                  text: '${mostAffected.toUpperCase()} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: 'is predicted to be '),
                                const TextSpan(
                                  text: 'most affected.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryPurple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: darkText,
                                fontFamily: 'Poppins',
                              ),
                              children: [
                                TextSpan(text: "• $title's "),
                                TextSpan(
                                  text: '${mostStable.toUpperCase()} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const TextSpan(text: 'is predicted to be '),
                                const TextSpan(
                                  text: 'stable.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- COGNITIVE IMPAIRMENT CARD ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Cognitive Impairment',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: _StrictImpairmentChartPainter(
                                weekScores: impairmentWeeklyScores,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        "$title's cognitive health shows\n${totalBadLogs > 5 ? 'MODERATE IMPAIRMENT' : 'MILD IMPAIRMENT'} with a ${totalBadLogs > 5 ? 'MODERATE RATE' : 'SLOW RATE'} of decline.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- TOP RISK DRIVERS & AI INSIGHTS ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Top Risk Drivers
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Top Risk Drivers',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildRiskLevelBlock(
                                  label: 'High:',
                                  color: const Color(0xFFEF4444),
                                  items: riskFactors.isNotEmpty
                                      ? riskFactors.take(2).toList()
                                      : ['Sleep quality decline', 'Social Isolation'],
                                ),
                                const SizedBox(height: 10),
                                _buildRiskLevelBlock(
                                  label: 'Medium:',
                                  color: const Color(0xFFFACC15),
                                  items: riskFactors.length > 2
                                      ? riskFactors.skip(2).take(2).toList()
                                      : ['Medication Skips', 'Blood pressure change'],
                                ),
                                const SizedBox(height: 10),
                                _buildRiskLevelBlock(
                                  label: 'Low:',
                                  color: const Color(0xFF38BDF8),
                                  items: ['Low physical activity', 'Irregular meals'],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Right: AI Insights
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'AI Insights',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _buildAiInsightBlock(
                                  priority: 'High Priority:',
                                  color: primaryPurple,
                                  suggestions: [
                                    'Improve nighttime sleep routine',
                                    'Encourage daily social interaction'
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildAiInsightBlock(
                                  priority: 'Medium Priority:',
                                  color: const Color(0xFF818CF8),
                                  suggestions: [
                                    'Set up medication reminders',
                                    'Monitor blood pressure with regular check-ins'
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _buildAiInsightBlock(
                                  priority: 'Low Priority:',
                                  color: const Color(0xFF38BDF8),
                                  suggestions: [
                                    'Add light physical activity',
                                    'Maintain a balanced meal schedule'
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // GENERATE REPORT BUTTON
                    Center(
                      child: ElevatedButton(
                        onPressed: widget.onGenerateReportPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Generate Report',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskChip({
    required String domain,
    required String riskLabel,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border_rounded, size: 12, color: Colors.black87),
              const SizedBox(width: 4),
              Text(
                domain,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            riskLabel,
            style: const TextStyle(
              fontSize: 9,
              color: Colors.black54,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLevelBlock({
    required String label,
    required Color color,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ...items.map((it) => Text(
              '→ $it',
              style: const TextStyle(fontSize: 9, color: Colors.black87),
            )),
      ],
    );
  }

  Widget _buildAiInsightBlock({
    required String priority,
    required Color color,
    required List<String> suggestions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(
              priority,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 2),
        ...suggestions.map((s) => Text(
              '→ $s',
              style: const TextStyle(fontSize: 9, color: Colors.black87),
            )),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

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
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StrictProgressionChartPainter extends CustomPainter {
  final Map<String, Map<int, double>> domainScoresByMonthIndex;

  _StrictProgressionChartPainter({required this.domainScoresByMonthIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final double leftMargin = 28.0;
    final double rightMargin = 20.0;
    final double bottomMargin = 22.0;

    final double chartW = size.width - leftMargin - rightMargin;
    final double chartH = size.height - bottomMargin;

    final paintGrid = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: Colors.grey.shade800,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    final yLabels = ['100', '80', '60', '40', '20', '0'];
    for (int i = 0; i < yLabels.length; i++) {
      double y = chartH * (i / (yLabels.length - 1));
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - rightMargin, y), paintGrid);

      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 6, y - (tp.height / 2)));
    }

    final xLabels = ['Month 0', 'Month 2', 'Month 4', 'Month 6'];
    for (int i = 0; i < xLabels.length; i++) {
      double x = leftMargin + (chartW * (i / (xLabels.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - (tp.width / 2), chartH + 6));
    }

    if (domainScoresByMonthIndex.isEmpty) return;

    final domainColors = {
      'Mood': const Color(0xFF818CF8),
      'Attention': const Color(0xFF38BDF8),
      'Skills': const Color(0xFF60A5FA),
      'Memory': const Color(0xFFA78BFA),
      'Language': const Color(0xFFC084FC),
    };

    domainScoresByMonthIndex.forEach((domain, monthScores) {
      if (monthScores.isEmpty || !domainColors.containsKey(domain)) return;

      final color = domainColors[domain]!;
      final paintLine = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final paintPoint = Paint()..color = color;

      final sortedMonthKeys = monthScores.keys.toList()..sort();
      final path = Path();

      for (int i = 0; i < sortedMonthKeys.length; i++) {
        int monthSlot = sortedMonthKeys[i];
        double score = monthScores[monthSlot]!;

        double x = leftMargin + (chartW * (monthSlot / 3.0));
        double y = chartH * (1.0 - (score / 100.0));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
        canvas.drawCircle(Offset(x, y), 3.5, paintPoint);
      }

      if (sortedMonthKeys.length > 1) {
        canvas.drawPath(path, paintLine);
      }
    });
  }

  @override
  bool shouldRepaint(covariant _StrictProgressionChartPainter oldDelegate) =>
      oldDelegate.domainScoresByMonthIndex != domainScoresByMonthIndex;
}

class _StrictImpairmentChartPainter extends CustomPainter {
  final Map<int, double> weekScores;

  _StrictImpairmentChartPainter({required this.weekScores});

  @override
  void paint(Canvas canvas, Size size) {
    final double leftMargin = 28.0;
    final double rightMargin = 20.0;
    final double bottomMargin = 22.0;

    final double chartW = size.width - leftMargin - rightMargin;
    final double chartH = size.height - bottomMargin;

    final labelStyle = TextStyle(
      color: Colors.grey.shade800,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    final zoneTextStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );

    final yLabels = ['100', '80', '60', '40', '20', '0'];
    for (int i = 0; i < yLabels.length; i++) {
      double y = chartH * (i / (yLabels.length - 1));
      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(leftMargin - tp.width - 6, y - (tp.height / 2)));
    }

    final xLabels = ['Week 0', 'Week 2', 'Week 4', 'Week 6'];
    for (int i = 0; i < xLabels.length; i++) {
      double x = leftMargin + (chartW * (i / (xLabels.length - 1)));
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - (tp.width / 2), chartH + 6));
    }

    double zoneH = chartH / 3;

    canvas.drawRect(
      Rect.fromLTWH(leftMargin, 0, chartW, zoneH),
      Paint()..color = const Color(0xFFFFF0F2),
    );
    final tpHigh = TextPainter(
      text: TextSpan(text: 'High impairment', style: zoneTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpHigh.paint(canvas, Offset(leftMargin + 10, zoneH * 0.4));

    canvas.drawRect(
      Rect.fromLTWH(leftMargin, zoneH, chartW, zoneH),
      Paint()..color = const Color(0xFFFEFCE8),
    );
    final tpMod = TextPainter(
      text: TextSpan(text: 'Moderate impairment', style: zoneTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpMod.paint(canvas, Offset(leftMargin + 10, zoneH + (zoneH * 0.4)));

    canvas.drawRect(
      Rect.fromLTWH(leftMargin, zoneH * 2, chartW, zoneH),
      Paint()..color = const Color(0xFFF0FDF4),
    );
    final tpLow = TextPainter(
      text: TextSpan(text: 'Low impairment', style: zoneTextStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    tpLow.paint(canvas, Offset(leftMargin + 10, (zoneH * 2) + (zoneH * 0.4)));

    final paintGrid = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1.0;
    for (int i = 0; i <= 5; i++) {
      double y = chartH * (i / 5);
      canvas.drawLine(Offset(leftMargin, y), Offset(size.width - rightMargin, y), paintGrid);
    }

    if (weekScores.isEmpty) return;

    final paintLine = Paint()
      ..color = const Color(0xFF7C3AED)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final paintPoint = Paint()..color = const Color(0xFF7C3AED);

    final sortedWeekSlots = weekScores.keys.toList()..sort();
    final path = Path();

    for (int i = 0; i < sortedWeekSlots.length; i++) {
      int weekSlot = sortedWeekSlots[i];
      double score = weekScores[weekSlot]!;

      double x = leftMargin + (chartW * (weekSlot / 3.0));
      double y = chartH * (1.0 - (score / 100.0));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4.0, paintPoint);
    }

    if (sortedWeekSlots.length > 1) {
      canvas.drawPath(path, paintLine);
    }
  }

  @override
  bool shouldRepaint(covariant _StrictImpairmentChartPainter oldDelegate) =>
      oldDelegate.weekScores != weekScores;
}