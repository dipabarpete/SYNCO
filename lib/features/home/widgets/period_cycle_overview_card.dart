import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PeriodCycleOverviewCard extends StatelessWidget {
  final String currentPhase;
  final int currentDay;
  final int totalDays;
  final int daysUntilNextPeriod;
  final VoidCallback? onTap;

  const PeriodCycleOverviewCard({
    super.key,
    this.currentPhase = 'Follicular Phase',
    this.currentDay = 8,
    this.totalDays = 28,
    this.daysUntilNextPeriod = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentDay / totalDays).clamp(0.0, 1.0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppColors.cycleGradient,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 14,
              offset: Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: AppColors.softPurple.withValues(alpha: 0.2),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Phase, Day & Mini Calendar Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.softPurple,
                              AppColors.softPurpleLight,
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentPhase,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Day $currentDay of $totalDays • Cycle Overview',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.softPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Clickable Arrow visual indicator
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.softPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.softPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress Bar for Cycle Days
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cycle Progress',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMedium,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor:
                        AppColors.softPurple.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.softPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mini Calendar Highlights Row (Next Period & Phases)
            Row(
              children: [
                Expanded(
                  child: _buildCyclePill(
                    label: 'Next Period',
                    value: 'In $daysUntilNextPeriod Days',
                    bgColor: AppColors.babyPink,
                    textColor: AppColors.deepRose,
                    icon: Icons.water_drop_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCyclePill(
                    label: 'Fertile Window',
                    value: 'Days 11-16',
                    bgColor: AppColors.softLavender,
                    textColor: AppColors.softPurple,
                    icon: Icons.wb_sunny_rounded,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCyclePill(
                    label: 'Ovulation',
                    value: 'In 6 Days',
                    bgColor: AppColors.peachCoral.withValues(alpha: 0.25),
                    textColor: AppColors.textDark,
                    icon: Icons.auto_awesome_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclePill({
    required String label,
    required String value,
    required Color bgColor,
    required Color textColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: textColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
