import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class PeriodCycleOverviewCard extends StatelessWidget {
  final bool hasHistory;
  final String currentPhase;
  final int currentDay;
  final int totalDays;
  final int daysUntilNextPeriod;
  final String fertilityWindow;
  final int daysUntilOvulation;
  final VoidCallback? onTap;

  const PeriodCycleOverviewCard({
    super.key,
    this.hasHistory = true,
    this.currentPhase = 'Follicular Phase',
    this.currentDay = 8,
    this.totalDays = 28,
    this.daysUntilNextPeriod = 16,
    this.fertilityWindow = 'Days 11–16',
    this.daysUntilOvulation = 6,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: AppColors.softPurple.withValues(alpha: 0.15),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // CARD TITLE AT TOP INSIDE CARD
                Text(
                  'Period Cycle Overview',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),

                // 1. TOP ROW — THREE SUMMARY CARDS
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.water_drop_rounded,
                        label: 'Next Period',
                        value: 'In $daysUntilNextPeriod Days',
                        bgColor: AppColors.babyPink,
                        iconColor: AppColors.rosePink,
                        valueColor: AppColors.deepRose,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.wb_sunny_rounded,
                        label: 'Fertility Window',
                        value: fertilityWindow,
                        bgColor: AppColors.softLavender,
                        iconColor: AppColors.softPurple,
                        valueColor: AppColors.softPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.auto_awesome_rounded,
                        label: 'Ovulation',
                        value: 'In $daysUntilOvulation Days',
                        bgColor: const Color(0xFFFDE8E1),
                        iconColor: AppColors.peachCoral,
                        valueColor: AppColors.textDark,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 2. CURRENT CYCLE PHASE & OPEN CALENDAR ACTION ROW
                Row(
                  children: [
                    // Calendar Icon in Circular Background
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.softPurple,
                            AppColors.softPurpleLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Phase Name and Cycle Day
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
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hasHistory
                                ? 'Day $currentDay of $totalDays • Cycle Overview'
                                : 'Start tracking to see your cycle overview.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softPurple,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Navigation Arrow Button
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.softPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color bgColor,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.15),
          width: 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
