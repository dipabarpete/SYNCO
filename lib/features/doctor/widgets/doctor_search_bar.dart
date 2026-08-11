import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class DoctorSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const DoctorSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textDark,
        ),
        cursorColor: AppColors.softPurple,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search doctors, specialties...',
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textLight,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.softPurple,
            size: 22,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(11),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.softLavender.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                color: AppColors.softPurple,
                size: 20,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
