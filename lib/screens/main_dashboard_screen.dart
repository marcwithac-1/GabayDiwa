import 'package:flutter/material.dart';
import 'profile_screen.dart';

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
  late DateTime _today;
  late int _selectedDate;
  late List<DateTime> _currentWeekDays;
  int _selectedNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDate = _today.day;
    _currentWeekDays = _generateCurrentWeekDays(_today);
  }

  String get _patientTitle {
    if (widget.patientName != null && widget.patientName!.trim().isNotEmpty) {
      return widget.patientName!;
    }
    final gender = widget.patientGender?.trim().toLowerCase();
    if (gender == 'male') {
      return 'Lolo';
    } else if (gender == 'female') {
      return 'Lola';
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

  Widget _buildBody() {
    if (_selectedNavIndex == 4) {
      return ProfileScreen(
        patientName: _patientTitle,
        age: widget.age,
        gender: widget.patientGender,
        condition: widget.condition,
        status: widget.status,
        height: widget.height,
        weight: widget.weight,
        comorbidities: widget.comorbidities,
        healthReportPath: widget.healthReportPath,
        healthReportName: widget.healthReportName,
        mriScanPath: widget.mriScanPath,
        mriScanName: widget.mriScanName,
        familyMembers: widget.familyMembers,
      );
    }

    return _buildDashboardContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildBody(),
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
                      Container(
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${_getMonthName(_today.month)} ${_today.day}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _currentWeekDays.map((dateObj) {
                      final dateNum = dateObj.day;
                      final isSelected = _selectedDate == dateNum;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDate = dateNum;
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
                Text(
                  "Look out for $_patientTitle's mood.",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: primaryPurple,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Play $_patientTitle some\nmusic today.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: darkText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    "Learn how $_patientTitle's mood may be the most affected for this month.",
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
                  onPressed: () {
                    debugPrint('Log Symptoms Tapped');
                  },
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
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 15,
                              color: darkText,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                              TextSpan(text: 'Irregularities: ', style: TextStyle(fontWeight: FontWeight.w500)),
                              TextSpan(text: '4/7 days this week', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _DotIndicator(color: Color(0xFFDCD2F9)),
                            _DotIndicator(color: skyBlue),
                            _DotIndicator(color: primaryPurple),
                            _DotIndicator(color: Color(0xFFDCD2F9)),
                            _DotIndicator(color: softPurple),
                            _DotIndicator(color: Color(0xFFE2DAFA)),
                            _DotIndicator(color: primaryPurple),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: const [
                      Expanded(
                        child: _ActivityCard(
                          date: 'SEP 25',
                          title: 'Wandering at Night',
                          cardColor: Color(0xFFC7EBF9),
                          icon: Icons.directions_walk_rounded,
                          iconColor: skyBlue,
                          dotColor: skyBlue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _ActivityCard(
                          date: 'SEP 26',
                          title: 'Aggression',
                          cardColor: Color(0xFFD7CAFA),
                          icon: Icons.sentiment_very_dissatisfied_rounded,
                          iconColor: softPurple,
                          dotColor: primaryPurple,
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