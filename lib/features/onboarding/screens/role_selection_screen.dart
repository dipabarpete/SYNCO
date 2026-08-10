import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/user_profile.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/role_selection_card.dart';
import 'onboarding_name_screen.dart';
import '../../doctor/screens/doctor_auth_screen.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final onboardingNotifier = ref.read(onboardingProvider.notifier);

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Synco Logo Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.pureWhite,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.blushPink.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/synco.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.favorite_rounded,
                          size: 36,
                          color: AppColors.softPurple,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  'Choose Your Role',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select how you would like to experience Synco.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // Option 1: Login as User
                RoleSelectionCard(
                  role: UserRole.user,
                  title: 'Login as User',
                  description:
                      'Track cycle, symptoms, nutrition, AI companion Kyra, and health records.',
                  icon: Icons.person_outline_rounded,
                  isSelected: onboardingState.selectedRole == UserRole.user,
                  onTap: () {
                    onboardingNotifier.setRole(UserRole.user);
                  },
                ),

                // Option 2: Login as Consultant / Doctor
                RoleSelectionCard(
                  role: UserRole.doctor,
                  title: 'Login as Consultant / Doctor',
                  description:
                      'Manage patient requests, review lab summaries, and conduct consultations.',
                  icon: Icons.medical_services_outlined,
                  isSelected: onboardingState.selectedRole == UserRole.doctor,
                  onTap: () {
                    onboardingNotifier.setRole(UserRole.doctor);
                  },
                ),

                const Spacer(),

                // Primary Continue Button
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
                      onPressed: () {
                        if (onboardingState.selectedRole == UserRole.user) {
                          // Route to User Onboarding Screen 1
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingNameScreen(),
                            ),
                          );
                        } else {
                          // Route to Doctor Flow
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorAuthScreen(),
                            ),
                          );
                        }
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
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
