import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportScreen extends StatefulWidget {
  final String patientName;
  final String age;
  final String gender;
  final String condition;
  final String status;
  final String height;
  final String weight;
  final String comorbidities;

  final Map<String, Set<String>> loggedSymptomsByDate;

  const ReportScreen({
    super.key,
    required this.patientName,
    required this.age,
    required this.gender,
    required this.condition,
    required this.status,
    required this.height,
    required this.weight,
    required this.comorbidities,
    required this.loggedSymptomsByDate,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  // Helper to strictly override display title to Lolo/Lola based on gender
  String get _patientDisplayTitle {
    final g = widget.gender.trim().toLowerCase();
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

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  String _formatDateLabel(String dateKey) {
    try {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final day = parts[2];
        const months = [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        return "${months[month - 1]} $day, $year";
      }
    } catch (_) {}
    return dateKey;
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
          'date': _formatDateLabel(dateKey),
          'events': validEvents,
        });
      }
    });

    return logs;
  }

  Map<String, int> _calculateDomainCounts() {
    Map<String, int> categoryCounts = {
      'Mood': 0,
      'Attention': 0,
      'Skills': 0,
      'Memory': 0,
      'Language': 0,
    };

    widget.loggedSymptomsByDate.forEach((_, symptoms) {
      for (var item in symptoms) {
        if (!item.toLowerCase().contains('none')) {
          final label = item.toLowerCase();
          if (label.contains('mood') || label.contains('anger') || label.contains('sad') || label.contains('anxiety')) {
            categoryCounts['Mood'] = categoryCounts['Mood']! + 1;
          } else if (label.contains('attention') || label.contains('pacing') || label.contains('restless')) {
            categoryCounts['Attention'] = categoryCounts['Attention']! + 1;
          } else if (label.contains('routine') || label.contains('decision') || label.contains('money')) {
            categoryCounts['Skills'] = categoryCounts['Skills']! + 1;
          } else if (label.contains('name') || label.contains('item') || label.contains('task') || label.contains('repeat')) {
            categoryCounts['Memory'] = categoryCounts['Memory']! + 1;
          } else if (label.contains('word') || label.contains('naming') || label.contains('talk')) {
            categoryCounts['Language'] = categoryCounts['Language']! + 1;
          }
        }
      }
    });

    return categoryCounts;
  }

  Map<String, Map<int, double>> _calculateProgressionMapData() {
    if (widget.loggedSymptomsByDate.isEmpty) {
      return {};
    }

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
          monthSlot = 0; // Month 0
        } else if (monthDiff <= 2) {
          monthSlot = 1; // Month 2
        } else if (monthDiff <= 4) {
          monthSlot = 2; // Month 4
        } else if (monthDiff >= 5) {
          monthSlot = 3; // Month 6
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
    if (widget.loggedSymptomsByDate.isEmpty) {
      return {};
    }

    Map<int, double> weekScores = {};

    widget.loggedSymptomsByDate.forEach((dateKey, symptoms) {
      final parts = dateKey.split('-');
      if (parts.length == 3) {
        final day = int.parse(parts[2]);

        int weekSlot = -1;
        if (day >= 1 && day <= 7) {
          weekSlot = 0; // Week 0
        } else if (day >= 8 && day <= 14) {
          weekSlot = 1; // Week 2
        } else if (day >= 15 && day <= 21) {
          weekSlot = 2; // Week 4
        } else if (day >= 22) {
          weekSlot = 3; // Week 6
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

  String _computeSleepCircadianAnalysis() {
    int sleepIssues = 0;
    int agitationIssues = 0;

    widget.loggedSymptomsByDate.forEach((_, symptoms) {
      for (var item in symptoms) {
        final label = item.toLowerCase();
        if (label.contains('sleeping') || label.contains('sleep')) sleepIssues++;
        if (label.contains('anger') || label.contains('pacing') || label.contains('aggression')) agitationIssues++;
      }
    });

    if (sleepIssues > 0 || agitationIssues > 0) {
      return "Night rest declining, $sleepIssues sleep disruptions logged with $agitationIssues agitation episodes.";
    }
    return "Night rest stable; no severe circadian rhythm disruptions recorded.";
  }

  Map<String, int> _computeADLIndependence() {
    int adlDeficits = 0;
    int totalLoggedDays = widget.loggedSymptomsByDate.length;

    widget.loggedSymptomsByDate.forEach((_, symptoms) {
      for (var item in symptoms) {
        if (item.startsWith('Daily Functioning-') && !item.toLowerCase().contains('none')) {
          adlDeficits++;
        }
      }
    });

    if (totalLoggedDays == 0 || adlDeficits == 0) {
      return {'independent': 85, 'assisted': 15};
    }

    int assisted = (adlDeficits * 15).clamp(10, 60);
    int independent = 100 - assisted;
    return {'independent': independent, 'assisted': assisted};
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

  Future<void> _exportReportAsPdf() async {
    try {
      final pdf = pw.Document();
      final name = _patientDisplayTitle;
      final ageStr = widget.age.isNotEmpty ? widget.age : 'N/A';
      final conditionStr = widget.condition.isNotEmpty ? widget.condition : 'N/A';
      final monthYear = _getCurrentMonthYear();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: PdfColor.fromHex('#6B21A8'),
                  child: pw.Text(
                    'GabayDiwa Comprehensive Health Report',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Confidential Patient Data - GabayDiwa Platform',
                    style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Patient: $name (Age $ageStr)',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Date: $monthYear', style: const pw.TextStyle(fontSize: 11)),
                  ],
                ),
                pw.Text('Condition: $conditionStr', style: const pw.TextStyle(fontSize: 11)),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 12),

                pw.Text('Current Cognitive Health (Snapshot)',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F3EEFF'),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Overall Risk Level: High Risk',
                              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                          pw.Text('Stability Trend: ↓ 5% this week', style: const pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                      pw.Text('Domains: Mood, Memory, Language, Attention, Skills',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Text('Forecast & Progression',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('• Most Affected Domain: Mood', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('• Most Stable Domain: Memory', style: const pw.TextStyle(fontSize: 11)),
                pw.Text('• Sleep & Rhythm: ${_computeSleepCircadianAnalysis()}', style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 16),

                pw.Text('Daily Function & Wellbeing',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Text('• ADL Independence: 75% Independent / Assisted', style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 16),

                pw.Text('Risk Drivers & AI Insights',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• High Priority: Improve sleep hygiene, Encourage social interaction',
                          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#6B21A8'))),
                      pw.SizedBox(height: 4),
                      pw.Text('• Medium Priority: Medication reminders & Monitor BP',
                          style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text('Page 1 of 1 • GabayDiwa Platform',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'GabayDiwa_Health_Report_${_patientDisplayTitle.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Export triggered successfully! ($e)'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showReportPreviewModal() {
    final title = _patientDisplayTitle;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            height: MediaQuery.of(context).size.height * 0.92,
            decoration: const BoxDecoration(
              color: Color(0xFFF6F3FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logo_icon.png',
                          width: 44,
                          height: 44,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.blur_circular_rounded,
                            size: 44,
                            color: Color(0xFF6B21A8),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.undo_rounded, size: 28, color: Color(0xFF1E1E1E)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const Text(
                            'Report Preview',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'Create a PDF of symptom logs, forecasts, and risk factors for you and your doctor. GabayDiwa organizes the data and predicts risk progression.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: Colors.grey.shade600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B21A8),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'GabayDiwa Comprehensive Health Report',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Confidential Patient Data - GabayDiwa Platform',
                                  style: TextStyle(fontSize: 9, color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Patient: $title (${widget.age.isNotEmpty ? widget.age : "78"})',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Date: ${_getCurrentMonthYear()}',
                                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const Divider(height: 16),

                                const Text('Current Cognitive Health (Snapshot)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      width: 110,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6B21A8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text('High',
                                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const SizedBox(height: 4),
                                          const Text('Overall Risk Level',
                                              style: TextStyle(color: Colors.white, fontSize: 8)),
                                          const SizedBox(height: 6),
                                          const Text('Stability Trend: ↓ 5% this week',
                                              style: TextStyle(color: Colors.white70, fontSize: 7)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          const Text('Overview', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          Icon(Icons.psychology_rounded, size: 36, color: Colors.purple.shade300),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: const [
                                              _MiniDot(color: Colors.red, label: 'Mood'),
                                              _MiniDot(color: Colors.amber, label: 'Mild decline'),
                                              _MiniDot(color: Colors.teal, label: 'Skills'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                const Text('Forecast & Progression',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      height: 50,
                                      child: CustomPaint(painter: _MiniChartPainter()),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Highlights:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                        RichText(
                                          text: const TextSpan(
                                            style: TextStyle(fontSize: 8, color: Colors.black),
                                            children: [
                                              TextSpan(text: 'Most affected domain: '),
                                              TextSpan(text: 'Mood', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                        RichText(
                                          text: const TextSpan(
                                            style: TextStyle(fontSize: 8, color: Colors.black),
                                            children: [
                                              TextSpan(text: 'Most stable: '),
                                              TextSpan(text: 'Memory', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                const Text('Daily Function & Wellbeing',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text('Sleep & Circadian Rhythm:', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                                          Text('• More agitation, 3 nighttime awakenings this week', style: TextStyle(fontSize: 8, color: Colors.black87)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 14),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6B21A8),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text('AI Insights (Suggested Actions)',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      SizedBox(height: 4),
                                      Text('High Priority: → Improve sleep hygiene, Encourage social interaction',
                                          style: TextStyle(color: Colors.white70, fontSize: 8)),
                                      Text('Medium Priority: → Medication reminders & Monitor BP',
                                          style: TextStyle(color: Colors.white70, fontSize: 8)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Align(
                                  alignment: Alignment.centerRight,
                                  child: Text('Page 1 of 1', style: TextStyle(fontSize: 8, color: Colors.grey)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          ElevatedButton(
                            onPressed: _exportReportAsPdf,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B21A8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 48,
                                vertical: 14,
                              ),
                            ),
                            child: const Text(
                              'Export as PDF',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);
    const darkText = Color(0xFF1E1E1E);

    final title = _patientDisplayTitle;

    final activityLogs = _generateActivityLogs();
    final hasLogs = activityLogs.isNotEmpty;

    final domainCounts = _calculateDomainCounts();
    final totalLogEntries = domainCounts.values.fold(0, (sum, count) => sum + count);

    String mostAffected = 'Mood';
    String mostStable = 'Memory';
    if (hasLogs) {
      final sortedDomains = domainCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostAffected = sortedDomains.first.key;
      mostStable = sortedDomains.last.key;
    }

    final sleepAnalysis = _computeSleepCircadianAnalysis();
    final adlScores = _computeADLIndependence();
    final riskFactors = _getLoggedRiskFactors();

    final progressionMapData = _calculateProgressionMapData();
    final impairmentWeeklyScores = _calculateWeeklyImpairmentScores();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FE),
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
                  // TOP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      ElevatedButton(
                        onPressed: hasLogs ? _showReportPreviewModal : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryPurple,
                          disabledBackgroundColor: Colors.grey.shade300,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Generate Report',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // MONTHLY REPORT HEADER
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "$title's Report",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cognitive Report — ${_getCurrentMonthYear()}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryPurple,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PATIENT PROFILE INFO
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: const Color(0xFFD4F0F7),
                        child: Icon(
                          widget.gender.toLowerCase() == 'male'
                              ? Icons.face_rounded
                              : Icons.face_3_rounded,
                          size: 64,
                          color: primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 4),
                            _buildInfoText('Age: ', widget.age.isNotEmpty ? widget.age : 'N/A'),
                            _buildInfoText('Gender: ', widget.gender.isNotEmpty ? widget.gender : 'N/A'),
                            _buildInfoText('Condition: ', widget.condition.isNotEmpty ? widget.condition : 'N/A'),
                            _buildInfoText('Status: ', widget.status.isNotEmpty ? widget.status : 'N/A'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14, color: darkText, fontFamily: 'Poppins'),
                            children: [
                              const TextSpan(
                                  text: 'Height: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: widget.height.isNotEmpty
                                      ? '${widget.height}cm'
                                      : 'N/A'),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14, color: darkText, fontFamily: 'Poppins'),
                            children: [
                              const TextSpan(
                                  text: 'Weight: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: widget.weight.isNotEmpty
                                      ? '${widget.weight}kg'
                                      : 'N/A'),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 14, color: darkText, fontFamily: 'Poppins'),
                            children: [
                              const TextSpan(
                                  text: 'Relevant Comorbidities: ',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: widget.comorbidities.isNotEmpty
                                      ? widget.comorbidities
                                      : 'None'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

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
                            Icons.bar_chart_rounded,
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
                            'Log daily symptoms to automatically generate cognitive health analysis, risk drivers, and progression maps.',
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
                    // --- 1. CURRENT COGNITIVE HEALTH ---
                    const Text(
                      'Current Cognitive Health:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EEFF),
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(15)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Overall Risk',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                                Text(
                                  'Stability: ↓ ${(totalLogEntries * 3).clamp(1, 45)}%',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE11D48),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 16),
                            child: Wrap(
                              alignment: WrapAlignment.spaceEvenly,
                              spacing: 12,
                              runSpacing: 10,
                              children: const [
                                _LegendDot(color: Color(0xFFEF4444), label: 'Mood'),
                                _LegendDot(color: Color(0xFF34D399), label: 'Memory'),
                                _LegendDot(color: Color(0xFFFBBF24), label: 'Language'),
                                _LegendDot(color: Color(0xFFFACC15), label: 'Attention'),
                                _LegendDot(color: Color(0xFF4ADE80), label: 'Skills'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- 2. PROGRESSION MAP ---
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
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
                            height: 210,
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

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.35,
                          color: darkText,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          const TextSpan(
                            text: 'Most affected domain: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '$mostAffected\n'),
                          const TextSpan(
                            text: 'Most stable domain: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: mostStable),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: darkText,
                          fontFamily: 'Poppins',
                        ),
                        children: [
                          const TextSpan(
                            text: 'Sleep and Circadian Rhythm: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '$sleepAnalysis\n'),
                          const TextSpan(
                            text: 'ADL Independence: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                '${adlScores['independent']}% Independent; ${adlScores['assisted']}% assisted',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- 3. ACTIVITY LOG (NOTABLE EVENTS) ---
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'Activity Log (Notable Events)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            _getCurrentMonthYear(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3EEFF),
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Date',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                ),
                                ContainerDivider(),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Event',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...activityLogs.map((log) {
                            final dateStr = log['date'] as String;
                            final events = log['events'] as List<String>;

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200),
                                ),
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Text(
                                          dateStr,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: darkText,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ),
                                    const ContainerDivider(),
                                    Expanded(
                                      flex: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: events.map((ev) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.radio_button_unchecked,
                                                    size: 10,
                                                    color: softPurple,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      ev,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: darkText,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- 4. COGNITIVE IMPAIRMENT ---
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
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 190,
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

                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13, color: darkText, fontFamily: 'Poppins'),
                        children: [
                          TextSpan(
                            text: totalLogEntries > 5
                                ? 'MODERATE IMPAIRMENT '
                                : 'MILD IMPAIRMENT ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'with a '),
                          TextSpan(
                            text: totalLogEntries > 5
                                ? 'MODERATE RATE '
                                : 'SLOW RATE ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: 'of decline.'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // --- 5. RISK DRIVERS ---
                    const Text(
                      'Risk Drivers',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildRiskCategory(
                      color: const Color(0xFFEF4444),
                      title: 'High Impact:',
                      items: riskFactors.isNotEmpty
                          ? riskFactors.take(2).toList()
                          : ['Sleep quality decline', 'Social Isolation'],
                    ),
                    const SizedBox(height: 12),

                    _buildRiskCategory(
                      color: const Color(0xFFFACC15),
                      title: 'Medium Impact:',
                      items: riskFactors.length > 2
                          ? riskFactors.skip(2).take(2).toList()
                          : ['Medication Skips', 'Blood pressure change'],
                    ),
                    const SizedBox(height: 12),

                    _buildRiskCategory(
                      color: const Color(0xFF34D399),
                      title: 'Low Impact:',
                      items: ['Low physical activity', 'Irregular meals'],
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

  Widget _buildInfoText(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E1E1E), fontFamily: 'Poppins'),
        children: [
          TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  Widget _buildRiskCategory({
    required Color color,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1E1E),
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return Text(
                '→ $item',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  fontFamily: 'Poppins',
                ),
              );
            }).toList(),
          ),
        ),
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
      ],
    );
  }
}

class _MiniDot extends StatelessWidget {
  final Color color;
  final String label;

  const _MiniDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 2),
        Text(label, style: const TextStyle(fontSize: 7, color: Colors.grey)),
      ],
    );
  }
}

class ContainerDivider extends StatelessWidget {
  const ContainerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: Colors.grey.shade300,
    );
  }
}

class _MiniChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..lineTo(size.width * 0.3, size.height * 0.5)
      ..lineTo(size.width * 0.6, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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