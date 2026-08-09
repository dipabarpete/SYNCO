import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingScreenLayout extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBackTap;
  final Widget child;
  final Widget? bottomButton;

  const OnboardingScreenLayout({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBackTap,
    required this.child,
    this.bottomButton,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentStep / totalSteps).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.creamWhite,
              Color(0xFFFFF0F5),
              Color(0xFFFAF8F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Back Button, Logo/Title & Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  children: [
                    if (onBackTap != null)
                      IconButton(
                        onPressed: onBackTap,
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textDark,
                          size: 20,
                        ),
                        tooltip: 'Back',
                      )
                    else
                      const SizedBox(width: 44),
                    const Spacer(),
                    // Brand Title
                    Text(
                      'SYNCO',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    // Step Counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.lavenderAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        '$currentStep/$totalSteps',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar Line
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: AppColors.softLavender.withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.softPurple),
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: child,
                  ),
                ),
              ),

              // Bottom Button Container
              if (bottomButton != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: bottomButton!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
