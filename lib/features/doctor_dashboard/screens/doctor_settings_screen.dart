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

  bool _isLoading = true;
  bool _isSaving = false;
  Doctor? _doctor;

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
        _specializationController.text = doctor.specialization;
        _experienceController.text = doctor.experience;
        _feeController.text = doctor.consultationFee.toString();
        _aboutController.text = doctor.about;
        _clinicLocationController.text = doctor.clinicLocation ?? '';
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
      final updatedData = {
        'name': _nameController.text.trim(),
        'specialization': _specializationController.text.trim(),
        'experience': _experienceController.text.trim(),
        'consultationFee': int.tryParse(_feeController.text.trim()) ?? 50,
        'about': _aboutController.text.trim(),
        'clinicLocation': _clinicLocationController.text.trim(),
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
                      
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Specialization'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _specializationController,
                                  hintText: 'e.g. Gynecologist',
                                  icon: Icons.medical_services_outlined,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
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
        if (mounted) {
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
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: maxLines == 1 ? Icon(icon, color: AppColors.softPurple) : null,
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
      ),
    );
  }
}
