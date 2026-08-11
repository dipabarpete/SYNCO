import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/doctor.dart';

class ConsultationModeCard extends StatelessWidget {
  final ConsultationMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  const ConsultationModeCard({
    super.key,
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOnline = mode == ConsultationMode.online;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.pureWhite : AppColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.softPurple
                  : AppColors.borderGrey.withValues(alpha: 0.7),
              width: isSelected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.softPurple.withValues(alpha: 0.12)
                    : AppColors.shadowColor,
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.primaryGradient
                      : const LinearGradient(
                          colors: [
                            AppColors.softLavender,
                            AppColors.softLavender,
                          ],
                        ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOnline
                      ? Icons.videocam_rounded
                      : Icons.local_hospital_rounded,
                  color: isSelected ? Colors.white : AppColors.softPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOnline ? 'Online Consultation' : 'Offline Consultation',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isOnline ? 'Consult from anywhere' : 'Visit a nearby clinic',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
