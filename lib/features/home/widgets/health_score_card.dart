import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../health/services/health_score_status.dart';

class HealthScoreCard extends StatelessWidget {
  final int score;
  final int percentile;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final VoidCallback? onViewReportTap;
  final VoidCallback? onSuggestionTap;

  const HealthScoreCard({
    super.key,
    this.score = 84,
    this.percentile = 78,
    this.title = 'HEALTH SCORE',
    this.description = '',
    this.onTap,
    this.onViewReportTap,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (score / 100.0).clamp(0.0, 1.0);
    final status = getHealthScoreStatus(score);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: AppColors.softPurple.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          onTap: onViewReportTap ?? onTap,
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. TOP HEADER ROW: Pulse Icon + HEALTH SCORE Title
                Row(
                  children: [
                    const Icon(
                      Icons.show_chart_rounded,
                      size: 16,
                      color: AppColors.rosePink,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.softPurple,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: AppColors.softPurple.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 2. MAIN CONTENT ROW: Circular Progress (Left) + Heading & View Full Report Button (Right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Circular Progress Ring
                    CircularPercentIndicator(
                      radius: 44.0,
                      lineWidth: 8.5,
                      animation: true,
                      animationDuration: 1000,
                      percent: percent,
                      circularStrokeCap: CircularStrokeCap.round,
                      backgroundColor: AppColors.softLavender.withValues(alpha: 0.6),
                      linearGradient: const LinearGradient(
                        colors: [
                          AppColors.softPurpleLight,
                          AppColors.softPurple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$score',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softPurple,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '/100',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Right Section: Status, Message & View Full Report Button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: status.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  status.status,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textDark,
                                    letterSpacing: 1.2,
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            status.message,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.textDark,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // View Full Report Button/Card
                          GestureDetector(
                            onTap: onViewReportTap ?? onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 9.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.softPurple.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14.0),
                                border: Border.all(
                                  color: AppColors.softPurple.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'View Full Report',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.softPurple,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: AppColors.softPurple,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
}
