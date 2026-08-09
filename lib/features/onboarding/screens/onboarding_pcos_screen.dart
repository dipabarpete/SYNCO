import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_profile.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_screen_layout.dart';
import '../widgets/diagnosis_option_card.dart';
import '../../../app.dart';

class OnboardingPcosScreen extends ConsumerWidget {
  const OnboardingPcosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

    final isOptionSelected = onboardingState.diagnosisStatus != null;

    Future<void> onContinuePressed() async {
      if (!isOptionSelected) return;

      final success = await onboardingNotifier.completeOnboarding();
      if (success && context.mounted) {
        // Navigate cleanly to Main App Layout
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HerSyncMainLayout(),
          ),
          (route) => false,
        );
      }
    }

    return OnboardingScreenLayout(
      currentStep: 3,
      totalSteps: 3,
      onBackTap: () => Navigator.pop(context),
      bottomButton: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isOptionSelected ? AppColors.primaryGradient : null,
            color: isOptionSelected ? null : AppColors.lightGrey,
            boxShadow: isOptionSelected
                ? [
                    BoxShadow(
                      color: AppColors.blushPink.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: ElevatedButton(
            onPressed: isOptionSelected && !onboardingState.isSubmitting
                ? onContinuePressed
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: AppColors.lightGrey,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: onboardingState.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOptionSelected ? Colors.white : AppColors.textLight,
                    ),
                  ),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          Text(
            'Have you been diagnosed with PCOS, PCOD, or PMOS?',
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 28),

          // Option 1: Yes
          DiagnosisOptionCard(
            label: 'Yes, I have PCOS, PCOD, or PMOS',
            isSelected: onboardingState.diagnosisStatus == PcosDiagnosisStatus.diagnosed,
            onTap: () {
              onboardingNotifier.setDiagnosisStatus(PcosDiagnosisStatus.diagnosed);
            },
          ),

          // Option 2: No
          DiagnosisOptionCard(
            label: 'No',
            isSelected: onboardingState.diagnosisStatus == PcosDiagnosisStatus.notDiagnosed,
            onTap: () {
              onboardingNotifier.setDiagnosisStatus(PcosDiagnosisStatus.notDiagnosed);
            },
          ),

          // Option 3: Prefer not to say
          DiagnosisOptionCard(
            label: 'Prefer not to say',
            isSelected: onboardingState.diagnosisStatus == PcosDiagnosisStatus.preferNotToSay,
            onTap: () {
              onboardingNotifier.setDiagnosisStatus(PcosDiagnosisStatus.preferNotToSay);
            },
          ),

          const SizedBox(height: 20),

          // Supporting Text / Medical Disclaimer Notice
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.softPurple.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 20,
                  color: AppColors.softPurple,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Synco works for every woman — this just personalizes your experience.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMedium,
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
