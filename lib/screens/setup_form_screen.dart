import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'showcase_welcome_screen.dart';

class SetupFormScreen extends StatefulWidget {
  final String userName;
  final String patientName;

  const SetupFormScreen({
    super.key,
    required this.userName,
    required this.patientName,
  });

  @override
  State<SetupFormScreen> createState() => _SetupFormScreenState();
}

class _SetupFormScreenState extends State<SetupFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // User Controllers
  late TextEditingController _userFullNameController;
  final TextEditingController _userEmailController = TextEditingController();

  // Patient Controllers
  late TextEditingController _patientNameController;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _comorbiditiesController = TextEditingController();

  // Dropdown States
  String? _selectedGender;
  String? _selectedCondition;
  String? _selectedStatus;

  // Patient Records File Paths & Names
  String? _healthReportPath;
  String? _healthReportFileName;
  String? _mriScanPath;
  String? _mriScanFileName;

  // GabayFamily Members List
  final List<TextEditingController> _familyMemberControllers = [];

  @override
  void initState() {
    super.initState();
    _userFullNameController = TextEditingController(text: widget.userName);
    _patientNameController = TextEditingController(text: widget.patientName);
    _addFamilyMemberField();
  }

  @override
  void dispose() {
    _userFullNameController.dispose();
    _userEmailController.dispose();
    _patientNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _comorbiditiesController.dispose();
    for (var controller in _familyMemberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addFamilyMemberField() {
    setState(() {
      _familyMemberControllers.add(TextEditingController());
    });
  }

  void _removeFamilyMemberField(int index) {
    if (_familyMemberControllers.length > 1) {
      setState(() {
        _familyMemberControllers[index].dispose();
        _familyMemberControllers.removeAt(index);
      });
    }
  }

  // Pick PDF or Image file
  Future<void> _pickFile({required bool isHealthReport}) async {
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
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final familyMembers = _familyMemberControllers
          .map((c) => c.text.trim())
          .where((name) => name.isNotEmpty)
          .toList();

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ShowcaseWelcomeScreen(
            userName: _userFullNameController.text.trim(),
            patientName: _patientNameController.text.trim(),
            patientGender: _selectedGender,
            age: _ageController.text.trim(),
            condition: _selectedCondition,
            status: _selectedStatus,
            height: _heightController.text.trim(),
            weight: _weightController.text.trim(),
            comorbidities: _comorbiditiesController.text.trim(),
            healthReportPath: _healthReportPath,
            healthReportName: _healthReportFileName,
            mriScanPath: _mriScanPath,
            mriScanName: _mriScanFileName,
            familyMembers: familyMembers,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            decoration: const BoxDecoration(color: Colors.white),
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
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 90, 24, 0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 24,
                                height: 1.3,
                                fontFamily: 'Poppins',
                              ),
                              children: [
                                TextSpan(
                                  text: 'Setup ',
                                  style: TextStyle(
                                    color: primaryPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Care Profile',
                                  style: TextStyle(
                                    color: skyBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Please fill in these details to personalize your dashboard.',
                            style: TextStyle(
                              color: softPurple.withValues(alpha: 0.9),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // USER DETAILS
                          _buildSectionHeader('User Details', Icons.person_outline),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _userFullNameController,
                            label: 'Full Name',
                            icon: Icons.badge_outlined,
                            validator: (v) => v!.isEmpty ? 'Enter full name' : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _userEmailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || !v.contains('@'))
                                ? 'Enter valid email'
                                : null,
                          ),
                          const SizedBox(height: 28),

                          // PATIENT DETAILS
                          _buildSectionHeader('Patient Details', Icons.accessible_outlined),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _patientNameController,
                            label: 'Patient Full Name',
                            icon: Icons.person_pin_outlined,
                            validator: (v) => v!.isEmpty ? 'Enter patient name' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _selectedGender,
                                  label: 'Gender',
                                  icon: Icons.wc_outlined,
                                  items: ['Male', 'Female', 'Other'],
                                  onChanged: (val) => setState(() => _selectedGender = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdownField(
                                  value: _selectedCondition,
                                  label: 'Condition',
                                  icon: Icons.analytics_outlined,
                                  items: ['Mild Dementia', 'Moderate Dementia', 'Severe Dementia'],
                                  onChanged: (val) => setState(() => _selectedCondition = val),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDropdownField(
                                  value: _selectedStatus,
                                  label: 'Status',
                                  icon: Icons.trending_down_outlined,
                                  items: ['Stable', 'Slow Decline', 'Rapid Decline'],
                                  onChanged: (val) => setState(() => _selectedStatus = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _heightController,
                                  label: 'Height (cm)',
                                  icon: Icons.height_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  controller: _weightController,
                                  label: 'Weight (kg)',
                                  icon: Icons.monitor_weight_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _comorbiditiesController,
                            label: 'Comorbidities (e.g. Hypertension, Diabetes)',
                            icon: Icons.medical_services_outlined,
                          ),
                          const SizedBox(height: 28),

                          // PATIENT RECORDS (OPTIONAL)
                          _buildSectionHeader('Patient Records (Optional)', Icons.folder_open_outlined),
                          const SizedBox(height: 12),
                          _buildFileUploadTile(
                            title: 'Health Reports',
                            fileName: _healthReportFileName,
                            onTap: () => _pickFile(isHealthReport: true),
                          ),
                          const SizedBox(height: 10),
                          _buildFileUploadTile(
                            title: 'MRI Scans',
                            fileName: _mriScanFileName,
                            onTap: () => _pickFile(isHealthReport: false),
                          ),
                          const SizedBox(height: 28),

                          // GABAY FAMILY
                          _buildSectionHeader('GabayFamily Members', Icons.groups_outlined),
                          const SizedBox(height: 6),
                          Text(
                            'Add family members involved in the dementia patient care.',
                            style: TextStyle(
                              color: softPurple.withValues(alpha: 0.9),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(_familyMemberControllers.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _familyMemberControllers[index],
                                      label: 'Family Member ${index + 1}',
                                      icon: Icons.person_add_alt_1_outlined,
                                    ),
                                  ),
                                  if (_familyMemberControllers.length > 1) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                      onPressed: () => _removeFamilyMemberField(index),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),
                          TextButton.icon(
                            onPressed: _addFamilyMemberField,
                            icon: const Icon(Icons.add, color: primaryPurple, size: 20),
                            label: const Text(
                              'Add Another Family Member',
                              style: TextStyle(color: primaryPurple, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Save / Complete Button
                          GestureDetector(
                            onTap: _submitForm,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primaryPurple, skyBlue],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryPurple.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Save & Complete Setup',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    const primaryPurple = Color(0xFF6B21A8);
    return Row(
      children: [
        Icon(icon, color: primaryPurple, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: primaryPurple,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: primaryPurple, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: softPurple.withValues(alpha: 0.8), fontSize: 13),
        prefixIcon: Icon(icon, color: softPurple, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softPurple.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);

    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              ))
          .toList(),
      onChanged: onChanged,
      style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: softPurple.withValues(alpha: 0.8), fontSize: 13),
        prefixIcon: Icon(icon, color: softPurple, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: softPurple.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFileUploadTile({
    required String title,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    const primaryPurple = Color(0xFF6B21A8);
    const softPurple = Color(0xFF8B7EC8);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: softPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.upload_file_outlined, color: primaryPurple, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryPurple,
                  ),
                ),
                Text(
                  fileName ?? 'No file selected',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: fileName != null ? Colors.green : softPurple.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: primaryPurple),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              fileName == null ? 'Upload' : 'Change',
              style: const TextStyle(color: primaryPurple, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}