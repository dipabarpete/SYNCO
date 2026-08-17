import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/services/doctor_service.dart';
import '../../doctor/models/doctor.dart';

class DoctorSettingsScreen extends ConsumerStatefulWidget {
  const DoctorSettingsScreen({super.key});

  @override
  ConsumerState<DoctorSettingsScreen> createState() => _DoctorSettingsScreenState();
}

class _DoctorSettingsScreenState extends ConsumerState<DoctorSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _aboutController = TextEditingController();
  final _clinicLocationController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _languagesController = TextEditingController();

  String? _gender;
  bool _showGender = false;

  bool _isLoading = true;
  bool _isSaving = false;
  Doctor? _doctor;

  static const _genderOptions = [
    'Female',
    'Male',
    'Non-binary',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _aboutController.dispose();
    _clinicLocationController.dispose();
    _clinicNameController.dispose();
    _licenseController.dispose();
    _qualificationsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final doctor = await DoctorService().getDoctor(user.id);
    if (doctor != null && mounted) {
      setState(() {
        _doctor = doctor;
        _nameController.text = doctor.name;
        _specializationController.text = doctor.specializationList.join(', ');
        _experienceController.text = doctor.experience;
        _feeController.text = doctor.consultationFee.toString();
        _aboutController.text = doctor.about;
        _clinicLocationController.text = doctor.clinicLocation ?? '';
        _clinicNameController.text = doctor.clinicName ?? '';
        _licenseController.text = doctor.licenseId ?? '';
        _qualificationsController.text = doctor.qualifications.join(', ');
        _languagesController.text = doctor.languages.join(', ');
        _gender = doctor.gender;
        _showGender = doctor.showGender;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).user;
    if (user == null || _doctor == null) return;

    setState(() => _isSaving = true);

    try {
      final specializations = _splitList(_specializationController.text);
      final updatedData = {
        'name': _nameController.text.trim(),
        'specialization':
            specializations.isEmpty ? '' : specializations.first,
        'specializations': specializations,
        'experience': _experienceController.text.trim(),
        'consultationFee': int.tryParse(_feeController.text.trim()) ?? 50,
        'about': _aboutController.text.trim(),
        'clinicLocation': _clinicLocationController.text.trim(),
        'clinicName': _clinicNameController.text.trim(),
        'licenseId': _licenseController.text.trim(),
        'qualifications': _splitList(_qualificationsController.text),
        'gender': _gender,
        'showGender': _showGender,
        'languages': _splitList(_languagesController.text),
      };

      await DoctorService().updateDoctorProfile(user.id, updatedData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.softPurple,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: AppColors.deepRose,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Splits a comma-separated list into clean, non-empty trimmed entries.
  List<String> _splitList(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.softPurple),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branding Header
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.pureWhite,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.softPurple.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 48,
                            color: AppColors.softPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Personal Details'),
                      const SizedBox(height: 12),
                      _buildLabel('Full Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'e.g. Dr. Sarah Jenkins',
                        icon: Icons.badge_outlined,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Medical License ID'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _licenseController,
                        hintText: 'e.g. MCI-84920-IND',
                        icon: Icons.verified_user_outlined,
                      ),
                      const SizedBox(height: 16),

                      _buildLabel('Qualifications'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _qualificationsController,
                        hintText: 'e.g. MBBS, MD (separate with commas)',
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Specializations'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _specializationController,
                                  hintText: 'e.g. Gynecologist, Endometriosis',
                                  icon: Icons.medical_services_outlined,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Separate multiple specializations with '
                                  'commas.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Experience'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _experienceController,
                                  hintText: 'e.g. 10 Years',
                                  icon: Icons.timeline_rounded,
                                  validator: (v) =>
                                      v!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Languages'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _languagesController,
                                  hintText: 'e.g. English, Hindi',
                                  icon: Icons.translate_rounded,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Optional gender with a public-visibility toggle. When
                      // the toggle is off the gender is never shown on the
                      // public profile.
                      _buildLabel('Gender (optional)'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        isExpanded: true,
                        decoration: _buildInputDecoration(
                          hintText: 'Prefer not to say',
                          icon: Icons.wc_rounded,
                        ),
                        items: _genderOptions
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _gender = value),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softLavender.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _showGender
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              size: 18,
                              color: _showGender
                                  ? AppColors.softPurple
                                  : AppColors.textLight,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Show gender on my profile',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            Switch(
                              value: _showGender,
                              activeTrackColor: AppColors.softPurpleLight,
                              onChanged: (value) =>
                                  setState(() => _showGender = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Consultation Settings'),
                      const SizedBox(height: 12),
                      _buildLabel('Consultation Fee (\u20B9)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _feeController,
                        hintText: 'e.g. 50',
                        icon: Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Clinic / Hospital Name'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _clinicNameController,
                        hintText: 'e.g. Sunflower Women\u2019s Hospital',
                        icon: Icons.local_hospital_outlined,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Clinic Location'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _clinicLocationController,
                        hintText: 'e.g. 123 Health Ave, NY',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 24),

                      _buildSectionTitle('About Me'),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _aboutController,
                        hintText: 'Write a brief bio...',
                        icon: Icons.edit_note_rounded,
                        maxLines: 4,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),

                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 3,
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Save Profile',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Danger Zone
                      _buildSectionTitle('Danger Zone', color: AppColors.deepRose),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () => _confirmDeleteAccount(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.deepRose,
                            side: const BorderSide(color: AppColors.deepRose),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Delete Account & Data',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Account?',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.deepRose,
          ),
        ),
        content: Text(
          'This action is irreversible. All your profile data, chat history, and appointments will be permanently deleted. Do you wish to proceed?',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final authService = ref.read(authServiceProvider);
        await authService.deleteAccount();
        // The authStateChanges stream will naturally log the user out and redirect them to login.
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.deepRose,
            ),
          );
        }
      }
    }
  }

  Widget _buildSectionTitle(String title, {Color color = AppColors.textDark}) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _buildInputDecoration(hintText: hintText, icon: icon),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: AppColors.softPurple),
      filled: true,
      fillColor: AppColors.pureWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.softPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.deepRose, width: 2),
      ),
    );
  }
}
