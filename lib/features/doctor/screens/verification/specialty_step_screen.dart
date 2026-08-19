import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/doctor_verification.dart';
import '../../providers/doctor_verification_provider.dart';
import 'document_upload_field.dart';
import 'verification_step_scaffold.dart';
import 'practice_step_screen.dart';

/// Step 4 - Professional specialty.
class SpecialtyStepScreen extends ConsumerStatefulWidget {
  const SpecialtyStepScreen({super.key});

  @override
  ConsumerState<SpecialtyStepScreen> createState() =>
      _SpecialtyStepScreenState();
}

class _SpecialtyStepScreenState extends ConsumerState<SpecialtyStepScreen> {
  static const List<String> _suggestedSpecialties = [
    'Gynecology',
    'General Medicine',
    'Endometriosis',
    'Menstrual Disorders',
  ];

  final _customController = TextEditingController();
  String? _certificateError;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _addCustomSpecialization() {
    final notifier = ref.read(doctorVerificationProvider.notifier);
    notifier.addCustomSpecialization(_customController.text);
    _customController.clear();
  }

  void _continue() {
    final state = ref.read(doctorVerificationProvider);
    final claimsSpecialty = state.data.specializations.isNotEmpty;
    final hasCertificate =
        state.pendingFiles[VerificationDocKind.specializationCertificate] !=
            null ||
        state.data.specializationCertificate != null;

    if (claimsSpecialty && !hasCertificate) {
      setState(() {
        _certificateError =
            'Add a specialization certificate for the specialty you claim.';
      });
      return;
    }
    setState(() => _certificateError = null);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PracticeStepScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final specializations =
        ref.watch(doctorVerificationProvider).data.specializations;

    return VerificationStepScaffold(
      step: 4,
      title: 'Professional Specialty',
      subtitle:
          'Tell us your specialty. Your specialization will be shown on your '
          'public profile but is never considered verified just because it '
          'was entered.',
      onContinue: _continue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerificationCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationSectionHeader(
                  title: 'Specialization',
                  trailing: 'One or more',
                ),
                const SizedBox(height: 8),
                Text(
                  'Select or add your specializations.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final specialty in _suggestedSpecialties)
                      _SpecialtyChip(
                        label: specialty,
                        isSelected: specializations.contains(specialty),
                        onTap: () => ref
                            .read(doctorVerificationProvider.notifier)
                            .toggleSpecialization(specialty),
                      ),
                    for (final specialty in specializations)
                      if (!_suggestedSpecialties.contains(specialty))
                        _SpecialtyChip(
                          label: specialty,
                          isSelected: true,
                          onTap: () => ref
                              .read(doctorVerificationProvider.notifier)
                              .toggleSpecialization(specialty),
                        ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customController,
                        decoration: InputDecoration(
                          hintText: 'Add your own specialty',
                          prefixIcon: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.softPurple,
                          ),
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textLight,
                          ),
                          filled: true,
                          fillColor: AppColors.pureWhite,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color:
                                  AppColors.borderGrey.withValues(alpha: 0.8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color:
                                  AppColors.borderGrey.withValues(alpha: 0.8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.softPurple,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _addCustomSpecialization(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _addCustomSpecialization,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.softPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Add',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          VerificationCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VerificationSectionHeader(
                  title: 'Specialization Certificate',
                ),
                const SizedBox(height: 16),
                DocumentUploadField(
                  kind: VerificationDocKind.specializationCertificate,
                  label: 'Specialization Certificate',
                  helperText:
                      'If you claim a specialist designation, upload the '
                      'relevant certificate or document. Your specialization '
                      'will not be marked verified based on entry alone.',
                  optional: true,
                ),
                if (_certificateError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _certificateError!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
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

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpecialtyChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.softPurple : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected
                  ? AppColors.softPurple
                  : AppColors.lavenderAccent.withValues(alpha: 0.8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}