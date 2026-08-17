import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom navigation for the Doctor Portal with five primary sections:
/// Dashboard, Appointments, Consultation Room, Requests and Profile.
class DoctorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const DoctorBottomNavBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.calendar_month_rounded,
              label: 'Appointments',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.video_call_rounded,
              label: 'Consultation Room',
              emphasized: true,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.group_rounded,
              label: 'Requests',
            ),
            _buildNavItem(
              index: 4,
              icon: Icons.person_rounded,
              label: 'Profile',
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
    bool emphasized = false,
  }) {
    final bool isSelected = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: onTap != null ? () => onTap!(index) : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
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
                color: isSelected
                    ? AppColors.softPurple
                    : emphasized
                        ? AppColors.softPurpleLight
                        : AppColors.textLight,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.softPurple
                      : emphasized
                          ? AppColors.softPurpleLight
                          : AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
