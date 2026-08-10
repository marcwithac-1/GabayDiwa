import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'gabay_board_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';

class NotificationItem {
  final String text;
  final String time;
  final Color bgColor;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.text,
    required this.time,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
  });
}

class MainDashboardScreen extends StatefulWidget {
  final String? patientName;
  final String? age;
  final String? patientGender;
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

  const MainDashboardScreen({
    super.key,
    this.patientName,
    this.age,
    this.patientGender,
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
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  late DateTime _selectedFullDate;
  late int _selectedDateNum;
  late List<DateTime> _currentWeekDays;
  int _selectedNavIndex = 2; // Middle button default for Dashboard

  final Map<String, Set<String>> _loggedSymptomsByDate = {};
  final List<NotificationItem> _notifications = [];

  // Master State Sync
  late String _patientName;
  late String _age;
  late String _gender;
  late String _condition;
  late String _status;
  late String _height;
  late String _weight;
  late String _comorbidities;
  late List<String> _familyMembers;
  String? _healthReportPath;
  String? _healthReportName;
  String? _mriScanPath;
  String? _mriScanName;

  @override
  void initState() {
    super.initState();
    _selectedFullDate = DateTime.now();
    _selectedDateNum = _selectedFullDate.day;
    _currentWeekDays = _generateCurrentWeekDays(_selectedFullDate);

    _patientName = widget.patientName ?? '';
    _age = widget.age ?? '';
    _gender = widget.patientGender ?? '';
    _condition = widget.condition ?? '';
    _status = widget.status ?? '';
    _height = widget.height ?? '';
    _weight = widget.weight ?? '';
    _comorbidities = widget.comorbidities ?? '';
    _familyMembers = List.from(widget.familyMembers);
    _healthReportPath = widget.healthReportPath;
    _healthReportName = widget.healthReportName;
    _mriScanPath = widget.mriScanPath;
    _mriScanName = widget.mriScanName;
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  String get _patientDisplayTitle {
    final g = _gender.trim().toLowerCase();
    if (g == 'male') {
      return 'Lolo';
    } else if (g == 'female') {
      return 'Lola';
    }
    if (_patientName.trim().isNotEmpty) {
      return _patientName;
    }
    return 'Lolo/Lola';
  }

  List<DateTime> _generateCurrentWeekDays(DateTime referenceDate) {
    final startOfWeek = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  int get _irregularityDaysCount {
    int count = 0;
    for (var dateObj in _currentWeekDays) {
      final key = _getDateKey(dateObj);
      final symptoms = _loggedSymptomsByDate[key];
      if (symptoms != null &&
          symptoms.any((s) => !s.toLowerCase().contains('none'))) {
        count++;
      }
    }
    return count;
  }

  // Dynamic Suggestion Generator based on Logged Symptoms
  Map<String, String> _generateDynamicTip() {
    final title = _patientDisplayTitle;
    final Set<String> activeWeekSymptoms = {};

    for (var d in _currentWeekDays) {
      final key = _getDateKey(d);
      if (_loggedSymptomsByDate.containsKey(key)) {
        activeWeekSymptoms.addAll(_loggedSymptomsByDate[key]!);
      }
    }

    final lowerLogs = activeWeekSymptoms
        .where((s) => !s.toLowerCase().contains('none'))
        .map((s) => s.toLowerCase())
        .toList();

    if (lowerLogs.isEmpty) {
      return {
        'headline': "Look out for $title's mood.",
        'mainTip': "Check in on\n$title today.",
        'subTip': "Learn how $title's mood and daily routine can be supported this month.",
      };
    }

    if (lowerLogs.any((s) => s.contains('anger') || s.contains('aggression') || s.contains('anxiety') || s.contains('sad'))) {
      return {
        'headline': "Look out for $title's emotional comfort.",
        'mainTip': "Play $title some\ncalming music today.",
        'subTip': "Gentle music or soothing scents can help relieve agitation and anxiety.",
      };
    }

    if (lowerLogs.any((s) => s.contains('dizzy') || s.contains('balance') || s.contains('fall') || s.contains('unsteady'))) {
      return {
        'headline': "Look out for $title's mobility & safety.",
        'mainTip': "Keep $title's walkways\nwell-lit today.",
        'subTip': "Ensure clear pathways and non-slip mats to lower fall risks.",
      };
    }

    if (lowerLogs.any((s) => s.contains('sleep') || s.contains('sleeping') || s.contains('pacing') || s.contains('restless'))) {
      return {
        'headline': "Look out for $title's sleep rhythm.",
        'mainTip': "Guide $title through a\nlight walk today.",
        'subTip': "Daytime sunlight and light activity improve evening sleep quality.",
      };
    }

    if (lowerLogs.any((s) => s.contains('routine') || s.contains('task') || s.contains('repeat') || s.contains('forgot'))) {
      return {
        'headline': "Look out for $title's cognitive memory.",
        'mainTip': "Set up a visual\nroutine for $title.",
        'subTip': "Simple visual prompts reduce confusion and ease daily memory strain.",
      };
    }

    if (lowerLogs.any((s) => s.contains('meal') || s.contains('meds') || s.contains('bath') || s.contains('care'))) {
      return {
        'headline': "Look out for $title's daily care.",
        'mainTip': "Use gentle, step-by-step\nprompts for $title.",
        'subTip': "Breaking daily activities into small, calm tasks helps gain cooperation.",
      };
    }

    return {
      'headline': "Look out for $title's wellbeing.",
      'mainTip': "Engage $title in\ncalm activities today.",
      'subTip': "Consistent routines help manage daily cognitive changes effectively.",
    };
  }

  Future<void> _openCalendarPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFullDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6B21A8),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedFullDate) {
      setState(() {
        _selectedFullDate = picked;
        _selectedDateNum = picked.day;
        _currentWeekDays = _generateCurrentWeekDays(picked);
      });
    }
  }

  void _showSymptomLoggingModal() async {
    final currentKey = _getDateKey(_selectedFullDate);
    final Set<String>? newLogs = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: _SymptomLoggingModal(
              initialSelected: _loggedSymptomsByDate[currentKey] ?? {},
              displayDate: _selectedFullDate,
            ),
          ),
        );
      },
    );

    if (newLogs != null) {
      final oldLogs = _loggedSymptomsByDate[currentKey] ?? {};
      final addedLogs = newLogs.difference(oldLogs);

      setState(() {
        _loggedSymptomsByDate[currentKey] = newLogs;

        final now = TimeOfDay.now();
        final timeStr = now.format(context);

        for (var item in addedLogs) {
          if (!item.toLowerCase().contains('none')) {
            final title = item.split('-').last;
            _notifications.insert(
              0,
              NotificationItem(
                text: "Logged '$title'",
                time: timeStr,
                bgColor: const Color(0xFFEFE8FF),
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF6B21A8),
              ),
            );
          }
        }
      });
    }
  }

  void _onSeeMorePressed() {
    debugPrint('Redirecting to full activities screen...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedNavIndex,
            children: [
              // Index 0: Leftmost Icon -> GabayBoard
              GabayBoardScreen(
                patientName: _patientName,
                patientGender: _gender,
                loggedSymptomsByDate: _loggedSymptomsByDate,
                onSeeFullReportPressed: () {
                  setState(() {
                    _selectedNavIndex = 3; // Switch tab to Report Screen (Index 3)
                  });
                },
              ),

              const Center(child: Text('Second Page')), // Index 1

              _buildDashboardContent(), // Index 2 (Middle Main Dashboard)

              // Index 3 (4th Icon -> Report Screen)
              ReportScreen(
                patientName: _patientName,
                age: _age,
                gender: _gender,
                condition: _condition,
                status: _status,
                height: _height,
                weight: _weight,
                comorbidities: _comorbidities,
                loggedSymptomsByDate: _loggedSymptomsByDate,
              ),

              // Index 4 (5th Icon -> Profile Screen)
              ProfileScreen(
                patientName: _patientName,
                age: _age,
                gender: _gender,
                condition: _condition,
                status: _status,
                height: _height,
                weight: _weight,
                comorbidities: _comorbidities,
                healthReportPath: _healthReportPath,
                healthReportName: _healthReportName,
                mriScanPath: _mriScanPath,
                mriScanName: _mriScanName,
                familyMembers: _familyMembers,
                notifications: _notifications,
                onProfileUpdated: ({
                  required String patientName,
                  required String age,
                  required String gender,
                  required String condition,
                  required String status,
                  required String height,
                  required String weight,
                  required String comorbidities,
                  required List<String> familyMembers,
                  String? healthReportPath,
                  String? healthReportName,
                  String? mriScanPath,
                  String? mriScanName,
                }) {
                  setState(() {
                    _patientName = patientName;
                    _age = age;
                    _gender = gender;
                    _condition = condition;
                    _status = status;
                    _height = height;
                    _weight = weight;
                    _comorbidities = comorbidities;
                    _familyMembers = List.from(familyMembers);
                    if (healthReportPath != null) _healthReportPath = healthReportPath;
                    if (healthReportName != null) _healthReportName = healthReportName;
                    if (mriScanPath != null) _mriScanPath = mriScanPath;
                    if (mriScanName != null) _mriScanName = mriScanName;
                  });
                },
              ),
            ],
          ),

          // Floating Bottom Navigation Bar
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 380),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3FF),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.grid_view_rounded),
                    _buildNavItem(1, Icons.psychology_outlined),
                    _buildNavItem(2, Icons.edit_note_rounded, isGradient: true),
                    _buildNavItem(3, Icons.article_outlined),
                    _buildNavItem(4, Icons.people_outline_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF9D84EC);
    const lightBgPurple = Color(0xFFF3EEFF);
    const skyBlue = Color(0xFF5BC0EB);
    const darkText = Color(0xFF1E1E1E);

    final currentKey = _getDateKey(_selectedFullDate);
    final currentLogs = _loggedSymptomsByDate[currentKey] ?? {};
    final activeLogsList = currentLogs
        .where((s) => !s.toLowerCase().contains('none'))
        .toList();

    // Generate dynamic tip based on symptom logs
    final dynamicTip = _generateDynamicTip();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 110.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // TOP HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                          color: primaryPurple,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openCalendarPicker,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: lightBgPurple.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: primaryPurple,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // DYNAMIC MONTH & DAY HEADER
                Text(
                  '${_getMonthName(_selectedFullDate.month)} ${_selectedFullDate.day}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),

                // DYNAMIC WEEK DATE STRIP
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _currentWeekDays.map((dateObj) {
                      final dateNum = dateObj.day;
                      final isSelected = _selectedDateNum == dateNum;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFullDate = dateObj;
                            _selectedDateNum = dateNum;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? softPurple.withValues(alpha: 0.35)
                                : Colors.transparent,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dateNum',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),

                // DYNAMIC HEADLINE
                Text(
                  dynamicTip['headline']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryPurple,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),

                // DYNAMIC MAIN TIP
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    dynamicTip['mainTip']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // DYNAMIC SUB-TIP
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    dynamicTip['subTip']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.grey.shade600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _showSymptomLoggingModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: softPurple,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 36,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    'Log symptoms',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // IRREGULARITIES CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: lightBgPurple.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: softPurple.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 15,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              const TextSpan(text: 'Irregularities: ', style: TextStyle(fontWeight: FontWeight.w500)),
                              TextSpan(
                                text: '$_irregularityDaysCount/7 days this week',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _currentWeekDays.map((d) {
                            final key = _getDateKey(d);
                            final hasIrregularity = _loggedSymptomsByDate[key] != null &&
                                _loggedSymptomsByDate[key]!
                                    .any((s) => !s.toLowerCase().contains('none'));
                            return _DotIndicator(
                              color: hasIrregularity
                                  ? primaryPurple
                                  : const Color(0xFFDCD2F9),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // RECENT ACTIVITY HEADER
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // RECENT ACTIVITIES LIST
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: activeLogsList.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 32,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F8FE),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.assignment_outlined,
                                size: 40,
                                color: skyBlue,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No activities logged yet',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Tap 'Log symptoms' to record daily changes.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: 180,
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                                PointerDeviceKind.trackpad,
                              },
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: (activeLogsList.length > 5 ? 5 : activeLogsList.length) + 1,
                              itemBuilder: (context, index) {
                                final totalCards = activeLogsList.length > 5 ? 5 : activeLogsList.length;

                                if (index == totalCards) {
                                  return GestureDetector(
                                    onTap: _onSeeMorePressed,
                                    child: Container(
                                      width: 90,
                                      margin: const EdgeInsets.only(left: 8, right: 12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.chevron_right_rounded,
                                              size: 32,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'See more',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade500,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                final itemKey = activeLogsList[index];
                                final cardTitle = itemKey.split('-').last;
                                final monthAbbr = _getMonthAbbreviation(_selectedFullDate.month);

                                return Container(
                                  width: 170,
                                  margin: const EdgeInsets.only(right: 12),
                                  child: _ActivityCard(
                                    date: '$monthAbbr $_selectedDateNum',
                                    title: cardTitle,
                                    cardColor: const Color(0xFFD7CAFA),
                                    icon: Icons.sentiment_very_dissatisfied_rounded,
                                    iconColor: softPurple,
                                    dotColor: primaryPurple,
                                  ),
                                );
                              },
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

  Widget _buildNavItem(int index, IconData icon, {bool isGradient = false}) {
    final isSelected = _selectedNavIndex == index;
    const primaryPurple = Color(0xFF6B21A8);
    const skyBlue = Color(0xFF5BC0EB);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected && !isGradient
              ? primaryPurple.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: isGradient
            ? ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [primaryPurple, skyBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(icon, size: 28, color: Colors.white),
              )
            : Icon(
                icon,
                size: 26,
                color: isSelected ? primaryPurple : Colors.black87,
              ),
      ),
    );
  }
}

class _SymptomLoggingModal extends StatefulWidget {
  final Set<String> initialSelected;
  final DateTime displayDate;

  const _SymptomLoggingModal({
    this.initialSelected = const {},
    required this.displayDate,
  });

  @override
  State<_SymptomLoggingModal> createState() => _SymptomLoggingModalState();
}

class _SymptomLoggingModalState extends State<_SymptomLoggingModal> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _searchQuery = '';
  late Set<String> _selectedSymptoms;

  @override
  void initState() {
    super.initState();
    _selectedSymptoms = Set.from(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  String _getFormattedDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF9D84EC);
    const darkText = Color(0xFF1E1E1E);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F8FE),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: darkText, size: 20),
                          onPressed: () => Navigator.pop(context, _selectedSymptoms),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Text(
                                _getFormattedDate(widget.displayDate),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          height: 34,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              contentPadding: EdgeInsets.zero,
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          _buildCategorySection(
                            title: 'Cognitive Abilities',
                            subtitle:
                                'Memory, Language, Orientation, Decision Making.',
                            items: const [
                              _SymptomData('Forgot name', Icons.psychology_outlined),
                              _SymptomData('Forgot task', Icons.psychology_outlined),
                              _SymptomData('Forgot item', Icons.psychology_outlined),
                              _SymptomData('Repeat question', Icons.psychology_outlined),
                              _SymptomData('Word trouble', Icons.record_voice_over_outlined),
                              _SymptomData('Naming trouble', Icons.record_voice_over_outlined),
                              _SymptomData('Wrong time', Icons.sentiment_neutral_outlined),
                              _SymptomData('Wrong place', Icons.sentiment_neutral_outlined),
                              _SymptomData('Wrong person', Icons.sentiment_neutral_outlined),
                              _SymptomData('Inefficient decision', Icons.cloud_outlined),
                              _SymptomData('Money mistake', Icons.cloud_outlined),
                              _SymptomData('Forgot routine', Icons.cloud_outlined),
                            ],
                            chipColor: const Color(0xFFDFD6FD),
                            iconColor: primaryPurple,
                          ),
                          const SizedBox(height: 24),
                          _buildCategorySection(
                            title: 'Behavior',
                            subtitle:
                                'Aggressiveness, Apathy, Disinhibition, Anxiety, etc',
                            items: const [
                              _SymptomData('Verbal anger', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Physical aggression', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Restless pacing', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Refused care', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Social withdrawal', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Low interest', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Impulsive act', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Difficulty Sleeping', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Sad mood', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Anxiety', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Fearful Reaction', Icons.sentiment_dissatisfied_outlined),
                              _SymptomData('Excess sleep', Icons.sentiment_dissatisfied_outlined),
                            ],
                            chipColor: const Color(0xFFC7EBF9),
                            iconColor: const Color(0xFF0284C7),
                          ),
                          const SizedBox(height: 24),
                          _buildCategorySection(
                            title: 'Daily Functioning',
                            subtitle:
                                'Disability Assessment for Dementia (DAD)',
                            items: const [
                              _SymptomData('Missed meal', Icons.bubble_chart_outlined),
                              _SymptomData('Skipped meds', Icons.bubble_chart_outlined),
                              _SymptomData('Unsafe actions', Icons.bubble_chart_outlined),
                              _SymptomData('Refused bath', Icons.bubble_chart_outlined),
                              _SymptomData('Unbrushed teeth', Icons.bubble_chart_outlined),
                              _SymptomData('Messy clothes', Icons.bubble_chart_outlined),
                              _SymptomData('Poor grooming', Icons.bubble_chart_outlined),
                              _SymptomData('Toileting issue', Icons.bubble_chart_outlined),
                              _SymptomData('Messy room', Icons.bubble_chart_outlined),
                              _SymptomData('Wandered outside', Icons.bubble_chart_outlined),
                              _SymptomData('Left door open', Icons.bubble_chart_outlined),
                              _SymptomData('Phone Trouble', Icons.bubble_chart_outlined),
                            ],
                            chipColor: const Color(0xFFFFD8E9),
                            iconColor: const Color(0xFFDB2777),
                          ),
                          const SizedBox(height: 24),
                          _buildCategorySection(
                            title: 'Risk Factors',
                            subtitle:
                                'Falls, Stroke Signs, Numbness, Dizziness, Fatigue.',
                            items: const [
                              _SymptomData('Felt dizzy', Icons.error_outline_rounded),
                              _SymptomData('Lost balance', Icons.error_outline_rounded),
                              _SymptomData('Had a fall', Icons.error_outline_rounded),
                              _SymptomData('Weak hands', Icons.error_outline_rounded),
                              _SymptomData('Numb feeling', Icons.error_outline_rounded),
                              _SymptomData('Slurred talk', Icons.error_outline_rounded),
                              _SymptomData('Blurry eyes', Icons.error_outline_rounded),
                              _SymptomData('Chest pain', Icons.error_outline_rounded),
                              _SymptomData('Breathing difficulty', Icons.error_outline_rounded),
                              _SymptomData('High BP', Icons.error_outline_rounded),
                              _SymptomData('Feeling weak', Icons.error_outline_rounded),
                              _SymptomData('Unsteady walk', Icons.error_outline_rounded),
                            ],
                            chipColor: const Color(0xFFFFC2C2),
                            iconColor: const Color(0xFFE11D48),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.note_add_outlined,
                                  color: primaryPurple, size: 22),
                              SizedBox(width: 8),
                              Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _notesController,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 13,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Add notes here...',
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, _selectedSymptoms),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: softPurple,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'Finish logs',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategorySection({
    required String title,
    required String subtitle,
    required List<_SymptomData> items,
    required Color chipColor,
    required Color iconColor,
  }) {
    const primaryPurple = Color(0xFF6B21A8);

    final filteredItems = items.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.label.toLowerCase().contains(_searchQuery);
    }).toList();

    if (_searchQuery.isNotEmpty && filteredItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryPurple,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredItems.length + 2,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            if (index == filteredItems.length) {
              final key = '$title-Others';
              return _buildChip(
                label: 'Others',
                icon: Icons.edit_note_rounded,
                bgColor: const Color(0xFFFDE68A),
                iconColor: const Color(0xFFB45309),
                isSelected: _selectedSymptoms.contains(key),
                onTap: () => _toggleSymptom(key),
              );
            }
            if (index == filteredItems.length + 1) {
              final key = '$title-None';
              return _buildChip(
                label: 'None',
                icon: Icons.check_rounded,
                bgColor: const Color(0xFFA7F3D0),
                iconColor: const Color(0xFF047857),
                isSelected: _selectedSymptoms.contains(key),
                onTap: () => _toggleSymptom(key),
              );
            }

            final data = filteredItems[index];
            final key = '$title-${data.label}';
            return _buildChip(
              label: data.label,
              icon: data.icon,
              bgColor: chipColor,
              iconColor: iconColor,
              isSelected: _selectedSymptoms.contains(key),
              onTap: () => _toggleSymptom(key),
            );
          },
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? bgColor.withValues(alpha: 0.6) : bgColor,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: iconColor, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.15),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
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
      ),
    );
  }
}

class _SymptomData {
  final String label;
  final IconData icon;

  const _SymptomData(this.label, this.icon);
}

class _ActivityCard extends StatelessWidget {
  final String date;
  final String title;
  final Color cardColor;
  final IconData icon;
  final Color iconColor;
  final Color dotColor;

  const _ActivityCard({
    required this.date,
    required this.title,
    required this.cardColor,
    required this.icon,
    required this.iconColor,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                Icon(icon, size: 48, color: iconColor),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'logged',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final Color color;

  const _DotIndicator({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}