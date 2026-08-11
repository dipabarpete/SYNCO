import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const CustomBottomNavBar({
    super.key,
    this.currentIndex = 0, // Defaults to 0 (Home selected)
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 20,
            offset: Offset(0, -6),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Home Tab (Selected)
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              label: 'Home',
            ),
            // 2. Whisper Room Tab
            _buildNavItem(
              index: 1,
              icon: Icons.forum_rounded,
              label: 'Whisper Room',
            ),
            // 3. Consult Tab (Center Highlight)
            _buildConsultNavItem(
              index: 2,
            ),
            // 4. Pink Corner Tab
            _buildNavItem(
              index: 3,
              icon: Icons.menu_book_rounded,
              label: 'Pink Corner',
            ),
            // 5. Health Tab
            _buildNavItem(
              index: 4,
              icon: Icons.favorite_rounded,
              label: 'Health',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(index) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.softPurple.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.softPurple : AppColors.textLight,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.softPurple : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsultNavItem({required int index}) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(index) : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? AppColors.primaryGradient
                  : const LinearGradient(
                      colors: [
                        AppColors.softPurple,
                        AppColors.softPurpleLight,
                      ],
                    ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.softPurple.withValues(alpha: 0.35),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              size: 19,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Consult',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.softPurple : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
