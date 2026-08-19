import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../models/user_profile.dart';
import '../../models/doctor_verification.dart';
import '../../providers/doctor_verification_provider.dart';
import 'account_step_screen.dart';
import 'contact_step_screen.dart';
import 'identity_step_screen.dart';
import 'practice_step_screen.dart';
import 'professional_step_screen.dart';
import 'verification_status_screen.dart';
import 'verification_step_scaffold.dart';

/// Review of all collected information before submission.
///
/// Sensitive identity document contents are never displayed - the review only
/// shows that a document was uploaded.
class VerificationReviewScreen extends ConsumerStatefulWidget {
  const VerificationReviewScreen({super.key});

  @override
  ConsumerState<VerificationReviewScreen> createState() =>
      _VerificationReviewScreenState();
}

class _VerificationReviewScreenState
    extends ConsumerState<VerificationReviewScreen> {
  String? _submitError;

  Future<void> _submit() async {
    final notifier = ref.read(doctorVerificationProvider.notifier);
    setState(() => _submitError = null);
    try {
      final uid = await notifier.submit();
      if (!mounted) return;

      // Keep the auth state in sync so the app routes this doctor to the
      // Doctor Portal on their next login.
      final data = ref.read(doctorVerificationProvider).data;
      await ref.read(authNotifierProvider.notifier).updateLocalProfile(
            UserProfile(
              id: uid,
              username: data.fullName,
              avatarUrl: data.profilePhoto?.url ?? '',
              email: data.professionalEmail,
              phone: data.phone,
              onboardingCompleted: true,
              role: UserRole.doctor,
            ),
          );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => VerificationStatusScreen(uid: uid),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      final state = ref.read(doctorVerificationProvider);
      setState(() => _submitError = state.errorMessage ?? e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(doctorVerificationProvider).data;
    final isSubmitting = ref.watch(doctorVerificationProvider).isSubmitting;

    return VerificationStepScaffold(
      step: 7,
      title: 'Review Your Information',
      subtitle:
          'Please review everything before submitting. You can edit any '
          'section below.',
      showBottomBar: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReviewSection(
            title: 'Professional Information',
            icon: Icons.medical_services_outlined,
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfessionalStepScreen()),
            ),
            rows: [
              _ReviewRow(label: 'Full Name', value: data.fullName),
              _ReviewRow(
                label: 'Registration Number',
                value: data.registrationNumber,
              ),
              _ReviewRow(
                label: 'Registering Authority',
                value: data.registeringAuthority,
              ),
              _ReviewRow(label: 'Qualification', value: data.qualification),
              _ReviewRow(
                label: 'Specialization',
                value: data.specializations.isNotEmpty
                    ? data.specializations.join(', ')
                    : 'Not specified',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Identity',
            icon: Icons.verified_user_outlined,
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IdentityStepScreen()),
            ),
            rows: [
              _ReviewRow(
                label: 'Date of Birth',
                value: data.dateOfBirth != null
                    ? DateFormat('dd MMM yyyy').format(data.dateOfBirth!)
                    : 'Not provided',
              ),
              _ReviewRow(
                label: 'Government ID',
                value: _hasFile(VerificationDocKind.governmentId)
                    ? 'Uploaded'
                    : 'Not uploaded',
              ),
              _ReviewRow(
                label: 'Profile photo',
                value: _hasFile(VerificationDocKind.profilePhoto)
                    ? 'Uploaded'
                    : 'Not uploaded',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Practice',
            icon: Icons.local_hospital_outlined,
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PracticeStepScreen()),
            ),
            rows: [
              _ReviewRow(
                label: 'Clinic / Hospital',
                value: data.clinicName.isEmpty
                    ? 'Not provided'
                    : data.clinicName,
              ),
              _ReviewRow(
                label: 'Location',
                value: data.clinicLocation.isEmpty
                    ? 'Not provided'
                    : data.clinicLocation,
              ),
              if (data.clinicAddress.isNotEmpty)
                _ReviewRow(label: 'Address', value: data.clinicAddress),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Contact',
            icon: Icons.contact_mail_outlined,
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactStepScreen()),
            ),
            rows: [
              _ReviewRow(
                label: 'Professional Email',
                value: data.professionalEmail,
              ),
              _ReviewRow(label: 'Phone', value: data.phone),
            ],
          ),
          const SizedBox(height: 16),
          _ReviewSection(
            title: 'Account',
            icon: Icons.lock_outline_rounded,
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountStepScreen()),
            ),
            rows: const [
              _ReviewRow(
                label: 'Password',
                value: 'Secured by Firebase Authentication (not stored)',
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _submitError!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent,
                ),
              ),
            ),
          VerificationPrimaryButton(
            label: 'Submit for Verification',
            isLoading: isSubmitting,
            enabled: !isSubmitting,
            onPressed: _submit,
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'After submission your status will be "Verification Pending" '
              'until our team reviews your credentials.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textLight,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  bool _hasFile(VerificationDocKind kind) {
    final state = ref.read(doctorVerificationProvider);
    return state.pendingFiles[kind] != null ||
        state.data.storedFor(kind) != null;
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<Widget> rows;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: AppColors.softPurple, size: 20),
              const SizedBox(width: 8),
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
              TextButton(
                onPressed: onEdit,
                child: Text(
                  'Edit',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}