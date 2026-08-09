import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_screen_layout.dart';
import 'onboarding_pcos_screen.dart';

class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(onboardingProvider).userName;
    final displayName = userName.isNotEmpty ? userName : 'there';

    return OnboardingScreenLayout(
      currentStep: 2,
      totalSteps: 3,
      onBackTap: () => Navigator.pop(context),
      bottomButton: SizedBox(
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
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const OnboardingPcosScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Continue',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Decorative Hero Icon Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.pureWhite,
              boxShadow: [
                BoxShadow(
                  color: AppColors.softPurple.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: AppColors.softPurple,
            ),
          ),
          const SizedBox(height: 28),

          // Dynamic Heading
          Text(
            'Hi, $displayName',
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Main Welcome Statement
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.borderGrey.withValues(alpha: 0.6),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "I'm so glad you are here.",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Synco is your everyday companion —',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cycle, mood, food, movement, rest.',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepRose,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: AppColors.textMedium,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Two minutes to set things up.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
