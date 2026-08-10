import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'main_dashboard_screen.dart';

typedef ProfileUpdateCallback = void Function({
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
});

class ProfileScreen extends StatefulWidget {
  final String patientName;
  final String? age;
  final String? gender;
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
  final List<NotificationItem> notifications;
  final ProfileUpdateCallback? onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.patientName,
    this.age,
    this.gender,
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
    this.notifications = const [],
    this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late String _patientName;
  late String _age;
  late String _gender;
  late String _condition;
  late String _status;
  late String _height;
  late String _weight;
  late String _comorbidities;

  String? _healthReportPath;
  String? _healthReportFileName;
  String? _mriScanPath;
  String? _mriScanFileName;

  late List<String> _familyMembers;

  @override
  void initState() {
    super.initState();
    _patientName = widget.patientName.isNotEmpty ? widget.patientName : 'Patient';
    _age = widget.age?.trim() ?? '';
    _gender = widget.gender?.trim() ?? '';
    _condition = widget.condition?.trim() ?? '';
    _status = widget.status?.trim() ?? '';
    _height = widget.height?.trim() ?? '';
    _weight = widget.weight?.trim() ?? '';
    _comorbidities = widget.comorbidities?.trim() ?? '';

    _healthReportPath = widget.healthReportPath;
    _healthReportFileName = widget.healthReportName;
    _mriScanPath = widget.mriScanPath;
    _mriScanFileName = widget.mriScanName;

    _familyMembers = widget.familyMembers
        .map((e) => _cleanNamePrefix(e))
        .where((e) => e.isNotEmpty)
        .toList();
  }

  // Helper to strictly override display title to Lolo/Lola based on gender
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

  void _notifyParentState() {
    if (widget.onProfileUpdated != null) {
      widget.onProfileUpdated!(
        patientName: _patientName,
        age: _age,
        gender: _gender,
        condition: _condition,
        status: _status,
        height: _height,
        weight: _weight,
        comorbidities: _comorbidities,
        familyMembers: _familyMembers,
        healthReportPath: _healthReportPath,
        healthReportName: _healthReportFileName,
        mriScanPath: _mriScanPath,
        mriScanName: _mriScanFileName,
      );
    }
  }

  String _cleanNamePrefix(String rawName) {
    return rawName
        .replaceAll(RegExp(r'^(Ate|Kuya)\.?\s+', caseSensitive: false), '')
        .trim();
  }

  Future<void> _pickNewRecord({required bool isHealthReport}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isHealthReport) {
          _healthReportPath = result.files.single.path;
          _healthReportFileName = result.files.single.name;
        } else {
          _mriScanPath = result.files.single.path;
          _mriScanFileName = result.files.single.name;
        }
      });
      _notifyParentState();
    }
  }

  void _showEditDetailsModal() {
    final nameCtrl = TextEditingController(text: _patientName);
    final ageCtrl = TextEditingController(text: _age);
    final heightCtrl = TextEditingController(text: _height);
    final weightCtrl = TextEditingController(text: _weight);
    final comorbiditiesCtrl = TextEditingController(text: _comorbidities);

    String? tempGender = _gender.isNotEmpty ? _gender : null;
    String? tempCondition = _condition.isNotEmpty ? _condition : null;
    String? tempStatus = _status.isNotEmpty ? _status : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Patient Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B21A8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Patient Name'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Age'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: tempGender,
                            hint: const Text('Gender'),
                            items: ['Male', 'Female', 'Other']
                                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                .toList(),
                            onChanged: (val) => setModalState(() => tempGender = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: tempCondition,
                            hint: const Text('Condition'),
                            items: ['Mild Dementia', 'Moderate Dementia', 'Severe Dementia']
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (val) => setModalState(() => tempCondition = val),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: tempStatus,
                            hint: const Text('Status'),
                            items: ['Stable', 'Slow Decline', 'Rapid Decline']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (val) => setModalState(() => tempStatus = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightCtrl,
                            decoration: const InputDecoration(labelText: 'Height (cm)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            decoration: const InputDecoration(labelText: 'Weight (kg)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: comorbiditiesCtrl,
                      decoration: const InputDecoration(labelText: 'Comorbidities'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B21A8),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _patientName = nameCtrl.text.trim();
                            _age = ageCtrl.text.trim();
                            _gender = tempGender ?? '';
                            _condition = tempCondition ?? '';
                            _status = tempStatus ?? '';
                            _height = heightCtrl.text.trim();
                            _weight = weightCtrl.text.trim();
                            _comorbidities = comorbiditiesCtrl.text.trim();
                          });
                          _notifyParentState();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddMemberModal() {
    final memberCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Family Member',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B21A8),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: memberCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Family Member Name',
                  hintText: 'e.g. May or Abe',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B21A8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final cleanName = _cleanNamePrefix(memberCtrl.text);
                    if (cleanName.isNotEmpty) {
                      setState(() {
                        _familyMembers.add(cleanName);
                      });
                      _notifyParentState();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Add Member',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllNotificationsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'All Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B21A8),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: widget.notifications.isEmpty
                        ? const Center(
                            child: Text(
                              'No notifications logged yet.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: widget.notifications.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = widget.notifications[index];
                              return _buildNotificationTile(
                                bgColor: item.bgColor,
                                icon: item.icon,
                                iconColor: item.iconColor,
                                text: item.text,
                                time: item.time,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);
    const darkText = Color(0xFF1E1E1E);

    final healthCount = _healthReportPath != null ? 1 : 0;
    final mriCount = _mriScanPath != null ? 1 : 0;
    final title = _patientDisplayTitle;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FE),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/logo_icon.png',
                      width: 44,
                      height: 44,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.blur_circular_rounded,
                        size: 44,
                        color: primaryPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "$title's Profile",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. PATIENT DETAILS CARD
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Patient Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextButton(
                              onPressed: _showEditDetailsModal,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xFFD4F0F7),
                              child: Icon(
                                _gender.toLowerCase() == 'male'
                                    ? Icons.face_rounded
                                    : Icons.face_3_rounded,
                                size: 52,
                                color: primaryPurple,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Age', _age),
                                  _buildDetailRow('Gender', _gender),
                                  _buildDetailRow('Condition', _condition),
                                  _buildDetailRow('Status', _status),
                                  _buildDetailRow('Height', _height.isNotEmpty ? '$_height cm' : ''),
                                  _buildDetailRow('Weight', _weight.isNotEmpty ? '$_weight kg' : ''),
                                  _buildDetailRow('Comorbidities', _comorbidities),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. PATIENT RECORDS CARD
                  _buildCardContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Patient Records',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View Records',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildRecordTileWithPreview(
                          title: 'Health reports',
                          count: healthCount,
                          filePath: _healthReportPath,
                          fileName: _healthReportFileName,
                          icon: Icons.article_rounded,
                          iconColor: primaryPurple,
                        ),
                        const SizedBox(height: 12),
                        _buildRecordTileWithPreview(
                          title: 'MRI scans',
                          count: mriCount,
                          filePath: _mriScanPath,
                          fileName: _mriScanFileName,
                          icon: Icons.psychology_rounded,
                          iconColor: softPurple,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: _buildSmallPurpleButton(
                            label: 'Add records',
                            onPressed: () {
                              _pickNewRecord(isHealthReport: true);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. GABAY FAMILY CARD
                  _buildCardContainer(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'GabayFamily (${_familyMembers.length})',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: darkText,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'View Plan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        if (_familyMembers.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No family members added yet.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        else
                          ..._familyMembers.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final memberName = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildFamilyMemberRow(
                                name: memberName,
                                role: idx == 0 ? 'Primary' : 'Support',
                                avatarColor: idx == 0
                                    ? const Color(0xFFD7C2DF)
                                    : const Color(0xFF94BBA8),
                              ),
                            );
                          }),
                        const SizedBox(height: 8),
                        Center(
                          child: _buildSmallPurpleButton(
                            label: 'Add member',
                            onPressed: _showAddMemberModal,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. NOTIFICATIONS CARD
                  _buildCardContainer(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 14),

                        if (widget.notifications.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              'No notifications yet.',
                              style: TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          )
                        else ...[
                          ...widget.notifications.take(3).map((notif) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: _buildNotificationTile(
                                bgColor: notif.bgColor,
                                icon: notif.icon,
                                iconColor: notif.iconColor,
                                text: notif.text,
                                time: notif.time,
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: _showAllNotificationsModal,
                              child: const Text(
                                'See All Notifications',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
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

  Widget _buildCardContainer({
    required Widget child,
    Color color = const Color(0xFFEFE8FF),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1E1E1E),
            fontFamily: 'Poppins',
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: value.isNotEmpty ? value : 'N/A',
              style: TextStyle(
                color: value.isNotEmpty ? const Color(0xFF1E1E1E) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTileWithPreview({
    required String title,
    required int count,
    required String? filePath,
    required String? fileName,
    required IconData icon,
    required Color iconColor,
  }) {
    final isImage = filePath != null &&
        (filePath.endsWith('.png') ||
            filePath.endsWith('.jpg') ||
            filePath.endsWith('.jpeg'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFDCD2F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E1E1E),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  Text(
                    '$count file${count == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (filePath != null && fileName != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(filePath),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFamilyMemberRow({
    required String name,
    required String role,
    required Color avatarColor,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: avatarColor,
          child: const Icon(Icons.person, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E1E1E),
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFF22C55E),
          size: 24,
        ),
      ],
    );
  }

  Widget _buildNotificationTile({
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
    required String text,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                    fontFamily: 'Poppins',
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPurpleButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B21A8),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}