import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_screen_layout.dart';
import 'onboarding_welcome_screen.dart';

class OnboardingNameScreen extends ConsumerStatefulWidget {
  const OnboardingNameScreen({super.key});

  @override
  ConsumerState<OnboardingNameScreen> createState() => _OnboardingNameScreenState();
}

class _OnboardingNameScreenState extends ConsumerState<OnboardingNameScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final existingName = ref.read(onboardingProvider).userName;
    _nameController = TextEditingController(text: existingName);
    _nameController.addListener(() {
      setState(() {}); // Rebuild to update Continue button enabled status
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onContinuePressed() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      ref.read(onboardingProvider.notifier).setName(name);
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OnboardingWelcomeScreen(),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNameEntered = _nameController.text.trim().isNotEmpty;

    return OnboardingScreenLayout(
      currentStep: 1,
      totalSteps: 3,
      onBackTap: () => Navigator.pop(context),
      bottomButton: SizedBox(
        width: double.infinity,
        height: 56,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isNameEntered ? AppColors.primaryGradient : null,
            color: isNameEntered ? null : AppColors.lightGrey,
            boxShadow: isNameEntered
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
            onPressed: isNameEntered ? _onContinuePressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              disabledBackgroundColor: AppColors.lightGrey,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isNameEntered ? Colors.white : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'What should I call you?',
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We would love to know how to address you in your daily companion insights.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 36),

          // Clean Text Input Field
          Container(
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: 'Enter your name',
                hintStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textLight,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(
                    Icons.face_outlined,
                    color: AppColors.softPurple,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.borderGrey.withValues(alpha: 0.8),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: AppColors.borderGrey.withValues(alpha: 0.8),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(
                    color: AppColors.softPurple,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
