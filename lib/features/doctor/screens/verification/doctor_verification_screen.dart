import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/backend.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../doctor_dashboard/screens/doctor_dashboard_screen.dart';
import '../../models/doctor_verification.dart';
import '../../providers/doctor_verification_provider.dart';
import '../doctor_auth_screen.dart';
import 'professional_step_screen.dart';
import 'verification_status_screen.dart';

/// Entry point of the doctor verification & registration flow, opened right
/// after the user picks the "Doctor / Consultant" role.
///
/// Routing logic:
///  - No signed-in session → welcome screen: start verification (new doctor)
///    or sign in with the professional email + password (existing doctor).
///  - Signed-in session without any doctor record → start the one-time
///    verification questionnaire immediately.
///  - Signed-in session with a doctor record → go to the verification status
///    screen (or straight to the Doctor Portal when already verified / legacy).
class DoctorVerificationScreen extends ConsumerStatefulWidget {
  const DoctorVerificationScreen({super.key});

  @override
  ConsumerState<DoctorVerificationScreen> createState() =>
      _DoctorVerificationScreenState();
}

class _DoctorVerificationScreenState
    extends ConsumerState<DoctorVerificationScreen> {
  bool _checking = true;
  bool _needsLogin = false;

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final auth = Backend.auth;
    final user = auth?.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _checking = false;
          _needsLogin = true;
        });
      }
      return;
    }

    final service = ref.read(doctorVerificationServiceProvider);
    final hasRecord = await service.hasDoctorRecord(user.uid);
    if (!hasRecord) {
      if (!mounted) return;
      await _startVerification();
      return;
    }

    final verification = await service.getVerification(user.uid);
    if (verification == null ||
        verification.status == DoctorVerificationStatus.verified) {
      // Legacy doctor or already verified: straight to the Doctor Portal.
      if (!mounted) return;
      _goToPortal();
      return;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationStatusScreen(uid: user.uid),
      ),
      (route) => false,
    );
  }

  Future<void> _startVerification() async {
    if (!mounted) return;
    ref.read(doctorVerificationProvider.notifier).reset();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfessionalStepScreen()),
    );
    if (mounted) {
      setState(() {
        _checking = false;
        _needsLogin = true;
      });
    }
  }

  void _goToPortal() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
      (route) => false,
    );
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
          child: _checking
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.softPurple),
                )
              : _needsLogin
                  ? _buildWelcome()
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.all(2),
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
          const SizedBox(height: 20),
          Text(
            'Doctor Verification & Registration',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome to the SYNCO doctor program. Tell us about your '
            'professional credentials once to create your verified account.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _WelcomeCard(
            icon: Icons.assignment_outlined,
            title: 'New Doctor / Consultant',
            description:
                'Create your professional account and submit your credentials '
                'for one-time verification.',
            buttonLabel: 'Start Verification',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfessionalStepScreen()),
            ),
          ),
          const SizedBox(height: 14),
          _WelcomeCard(
            icon: Icons.login_rounded,
            title: 'Already Registered',
            description:
                'Sign in with the professional email and password you created '
                'during registration.',
            buttonLabel: 'Sign In',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorAuthScreen()),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Verification information is collected only once during initial '
              'registration.',
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
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const _WelcomeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.softLavender,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.softPurple, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppColors.primaryGradient,
              ),
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}