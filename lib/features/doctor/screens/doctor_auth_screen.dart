import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor_dashboard/screens/doctor_dashboard_screen.dart';
import '../models/doctor_verification.dart';
import '../providers/doctor_verification_provider.dart';
import 'verification/professional_step_screen.dart';
import 'verification/verification_status_screen.dart';

/// Doctor sign-in with the professional email + password created during
/// one-time verification.
///
/// After authentication the existing authentication identity/user ID is used
/// to determine whether a doctor account/profile already exists:
///  - doctor record exists → Doctor Portal (or verification status screen)
///  - no doctor record → the one-time verification questionnaire
///
/// The doctor never has to repeat the verification questionnaire once their
/// account has been created.
class DoctorAuthScreen extends ConsumerStatefulWidget {
  const DoctorAuthScreen({super.key});

  @override
  ConsumerState<DoctorAuthScreen> createState() => _DoctorAuthScreenState();
}

class _DoctorAuthScreenState extends ConsumerState<DoctorAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.deepRose,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    ref.read(authNotifierProvider.notifier).clearMessages();

    debugPrint('[DOCTOR_PORTAL] Starting doctor sign-in...');
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final success = await ref.read(authNotifierProvider.notifier).loginWithEmail(
            email: email,
            password: password,
          );

      if (!success) {
        final error =
            ref.read(authNotifierProvider).errorMessage ?? 'Login failed';
        debugPrint('[DOCTOR_PORTAL] Doctor login failed: $error');
        _showError(error);
        return;
      }

      final user = ref.read(authNotifierProvider).user;
      if (user == null) {
        debugPrint('[DOCTOR_PORTAL] User profile is null after sign-in');
        _showError('Login failed. Please try again.');
        return;
      }

      debugPrint('[DOCTOR_PORTAL] Current user UID: ${user.id}. Checking doctor record...');

      // Determine what this identity already has on the backend.
      final service = ref.read(doctorVerificationServiceProvider);
      final hasRecord = await service.hasDoctorRecord(user.id);
      if (!hasRecord) {
        debugPrint('[DOCTOR_PORTAL] Doctor record not found for UID: ${user.id}. Routing to verification steps.');
        ref.read(doctorVerificationProvider.notifier).reset();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const ProfessionalStepScreen()),
          (route) => false,
        );
        return;
      }

      debugPrint('[DOCTOR_PORTAL] Doctor record found. Loading verification status...');
      final verification = await service.getVerification(user.id);
      if (!mounted) return;

      if (verification == null ||
          verification.status == DoctorVerificationStatus.verified) {
        debugPrint('[DOCTOR_PORTAL] Verified doctor. Navigating to doctor dashboard portal.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
          (route) => false,
        );
        return;
      }

      debugPrint('[DOCTOR_PORTAL] Pending verification. Navigating to VerificationStatusScreen.');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationStatusScreen(uid: user.id),
        ),
        (route) => false,
      );
    } catch (e, st) {
      debugPrint('[DOCTOR_PORTAL] Exception during doctor sign in: $e\n$st');
      _showError('Unable to open Doctor Portal: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.creamWhite,
              Color(0xFFF3EFF7),
              Color(0xFFFAF8F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.softLavender,
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        size: 44,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Text(
                      'Doctor Login',
                      style: GoogleFonts.outfit(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Sign in with your professional email and password.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildLabel('Professional / Work Email'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'dr.smith@hospital.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Professional email is required.';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(text)) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blushPink.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Sign In',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfessionalStepScreen(),
                              ),
                            ),
                      child: Text(
                        'New practitioner? Start your verification here.',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.softPurple,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Your verification information was collected only once - '
                      'signing in again never asks for it a second time.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textLight,
                        height: 1.4,
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
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
        prefixIcon: Icon(icon, color: AppColors.softPurple),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.softPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepRose, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepRose, width: 2),
        ),
      ),
    );
  }
}