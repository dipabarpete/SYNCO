import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/doctor_verification.dart';
import '../../providers/doctor_verification_provider.dart';
import 'document_upload_field.dart';
import 'verification_step_scaffold.dart';
import 'specialty_step_screen.dart';

/// Step 3 - Identity verification.
class IdentityStepScreen extends ConsumerStatefulWidget {
  const IdentityStepScreen({super.key});

  @override
  ConsumerState<IdentityStepScreen> createState() => _IdentityStepScreenState();
}

class _IdentityStepScreenState extends ConsumerState<IdentityStepScreen> {
  String? _fileError;

  bool _requiredUploadsUploaded() {
    final state = ref.read(doctorVerificationProvider);
    final hasGovId = state.pendingFiles[VerificationDocKind.governmentId] !=
            null ||
        state.data.governmentId != null;
    final hasPhoto = state.pendingFiles[VerificationDocKind.profilePhoto] !=
            null ||
        state.data.profilePhoto != null;
    return hasGovId && hasPhoto;
  }

  Future<void> _pickDateOfBirth() async {
    final current = ref.read(doctorVerificationProvider).data.dateOfBirth;
    final now = DateTime.now();
    final initial = current ?? DateTime(now.year - 30);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 15),
      helpText: 'Select Date of Birth',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.softPurple,
            onPrimary: Colors.white,
            surface: AppColors.pureWhite,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(doctorVerificationProvider.notifier).setDateOfBirth(picked);
    }
  }

  void _continue() {
    final state = ref.read(doctorVerificationProvider);
    if (state.data.dateOfBirth == null) {
      setState(() => _fileError = 'Date of birth is required.');
      return;
    }
    if (!_requiredUploadsUploaded()) {
      setState(() {
        _fileError =
            'Government-issued ID and a profile photo are required before '
            'continuing.';
      });
      return;
    }
    setState(() => _fileError = null);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SpecialtyStepScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateOfBirth = ref.watch(doctorVerificationProvider).data.dateOfBirth;

    return VerificationStepScaffold(
      step: 3,
      title: 'Identity Verification',
      subtitle:
          'Confirm your identity so we can match your profile to your '
          'professional records.',
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerificationCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationSectionHeader(
                  title: 'Identity Information',
                  trailing: 'Step 3 of 7',
                ),
                const SizedBox(height: 16),
                DocumentUploadField(
                  kind: VerificationDocKind.governmentId,
                  label: 'Government-Issued ID',
                  helperText:
                      'Upload a government-issued identity document (passport, '
                      'national ID or driver license). This document is '
                      'PRIVATE and never shown on your public profile.',
                ),
                const SizedBox(height: 20),
                _DateOfBirthField(
                  dateOfBirth: dateOfBirth,
                  onTap: _pickDateOfBirth,
                ),
                if (dateOfBirth == null)
                  _RequiredInlineError(
                    visible: _fileError != null,
                    message: 'Date of birth is required.',
                  ),
                const SizedBox(height: 20),
                DocumentUploadField(
                  kind: VerificationDocKind.profilePhoto,
                  label: 'Profile Photo / Selfie',
                  helperText:
                      'This photo is used on your professional profile and for '
                      'the verification process. It is the only verification '
                      'image that appears on your public profile.',
                  isPhoto: true,
                ),
                if (_fileError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _RequiredInlineError(
                      visible: true,
                      message: _fileError!,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softLavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.softPurple,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Government-issued ID and verification documents are '
                    'private data. They will never appear publicly on your '
                    'doctor profile.',
                    style: TextStyle(
                      color: AppColors.textMedium,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  final DateTime? dateOfBirth;
  final VoidCallback onTap;

  const _DateOfBirthField({required this.dateOfBirth, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.borderGrey.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.cake_outlined,
                    color: AppColors.softPurple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dateOfBirth != null
                          ? DateFormat('dd MMM yyyy').format(dateOfBirth!)
                          : 'Select your date of birth',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: dateOfBirth != null
                            ? AppColors.textDark
                            : AppColors.textLight,
                        fontWeight: dateOfBirth != null
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.softPurpleLight,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Required where needed for identity verification.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

class _RequiredInlineError extends StatelessWidget {
  final bool visible;
  final String message;

  const _RequiredInlineError({
    required this.visible,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}