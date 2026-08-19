import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../doctor_dashboard/screens/doctor_dashboard_screen.dart';
import '../../models/doctor_verification.dart';
import '../../providers/doctor_verification_provider.dart';
import 'professional_step_screen.dart';
import 'verification_step_scaffold.dart';

/// Shows the persisted verification status of the doctor account.
///
/// The status is read from the backend and never guessed on the client. The
/// "Verified Doctor" state is only displayed when the backend record actually
/// says the credentials were verified.
class VerificationStatusScreen extends ConsumerStatefulWidget {
  final String uid;

  const VerificationStatusScreen({super.key, required this.uid});

  @override
  ConsumerState<VerificationStatusScreen> createState() =>
      _VerificationStatusScreenState();
}

class _VerificationStatusScreenState
    extends ConsumerState<VerificationStatusScreen> {
  late Future<DoctorVerification?> _recordFuture;

  @override
  void initState() {
    super.initState();
    _recordFuture = _load();
  }

  Future<DoctorVerification?> _load() {
    final service = ref.read(doctorVerificationServiceProvider);
    return service.getVerification(widget.uid);
  }

  Future<void> _goToPortal() async {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
      (route) => false,
    );
  }

  Future<void> _startEdit(DoctorVerification record) async {
    if (!mounted) return;
    final notifier = ref.read(doctorVerificationProvider.notifier);
    notifier.loadExisting(record);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfessionalStepScreen()),
    );
    if (mounted) {
      setState(() {
        _recordFuture = _load();
      });
    }
  }

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
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
          child: FutureBuilder<DoctorVerification?>(
            future: _recordFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.softPurple),
                );
              }
              final record = snapshot.data;
              if (record == null) {
                return _buildMissing(context);
              }
              return _buildContent(context, record);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMissing(BuildContext context) {
    return _StatusLayout(
      icon: Icons.hourglass_empty_rounded,
      iconColor: AppColors.pendingAmber,
      title: 'No Verification Found',
      message:
          'We could not find a verification record for this account. Please '
          'start the verification process again.',
      primaryLabel: 'Start Verification',
      onPrimary: () async {
        ref.read(doctorVerificationProvider.notifier).reset();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfessionalStepScreen()),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, DoctorVerification record) {
    final status = record.status;

    if (status == DoctorVerificationStatus.verified) {
      return _StatusLayout(
        icon: Icons.verified_user_rounded,
        iconColor: AppColors.confirmedGreen,
        title: 'Verified Doctor',
        message:
            'Congratulations! Your professional credentials have been '
            'verified. You can now fully use your doctor portal.',
        primaryLabel: 'Go to Doctor Portal',
        onPrimary: _goToPortal,
        secondaryLabel: 'Sign Out',
        onSecondary: _signOut,
      );
    }

    if (status == DoctorVerificationStatus.rejected) {
      return _StatusLayout(
        icon: Icons.edit_note_rounded,
        iconColor: AppColors.pendingAmber,
        title: 'Verification Needs Changes',
        message:
            'Our team reviewed your submission and requested updates to your '
            'information. Your account stays the same - update the requested '
            'details and resubmit for verification.',
        primaryLabel: 'Update Information',
        onPrimary: () => _startEdit(record),
        secondaryLabel: 'Go to Doctor Portal',
        onSecondary: _goToPortal,
        tertiaryLabel: 'Sign Out',
        onTertiary: _signOut,
      );
    }

    // submitted / pending_verification / draft
    return _StatusLayout(
      icon: Icons.mark_email_read_outlined,
      iconColor: AppColors.pendingAmber,
      title: 'Verification Submitted',
      message:
          'Your professional information has been submitted for verification. '
          'We\'ll review the information you submitted. You can use your '
          'account to return to your doctor portal when verification is '
          'complete.',
      statusChip: 'Verification Pending',
      primaryLabel: 'Go to Doctor Portal',
      onPrimary: _goToPortal,
      secondaryLabel: 'Sign Out',
      onSecondary: _signOut,
    );
  }
}

class _StatusLayout extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String? statusChip;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;

  const _StatusLayout({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    this.statusChip,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tertiaryLabel,
    this.onTertiary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.12),
            ),
            child: Icon(icon, size: 64, color: iconColor),
          ),
          const SizedBox(height: 28),
          if (statusChip != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.pendingAmberSoft,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.pendingAmber,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusChip!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pendingAmber,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),
          VerificationPrimaryButton(
            label: primaryLabel,
            onPressed: onPrimary,
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: onSecondary,
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.pureWhite,
                  side: BorderSide(
                    color: AppColors.lavenderAccent.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  secondaryLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
            ),
          ],
          if (tertiaryLabel != null) ...[
            const SizedBox(height: 10),
            TextButton(
              onPressed: onTertiary,
              child: Text(
                tertiaryLabel!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}