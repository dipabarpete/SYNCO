import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';

class HealthScoreCard extends StatelessWidget {
  final int score;
  final int percentile;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const HealthScoreCard({
    super.key,
    this.score = 82,
    this.percentile = 78,
    this.title = 'Health Score',
    this.description =
        'Your body is in optimal balance today! Good sleep and hydration are boosting your energy.',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (score / 100.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF0F5),
              Color(0xFFF5EEF8),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 16,
              offset: Offset(0, 6),
            )
          ],
          border: Border.all(
            color: AppColors.blushPinkLight.withValues(alpha: 0.6),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Progress Visualization
                CircularPercentIndicator(
                  radius: 52.0,
                  lineWidth: 9.5,
                  animation: true,
                  animationDuration: 1000,
                  percent: percent,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$score',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softPurple,
                            ),
                          ),
                          Text(
                            '/100',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Icon(
                        Icons.favorite_rounded,
                        size: 13,
                        color: AppColors.rosePink,
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: AppColors.softLavender.withValues(alpha: 0.4),
                  linearGradient: const LinearGradient(
                    colors: [
                      AppColors.blushPink,
                      AppColors.softPurple,
                    ],
                  ),
                ),
                const SizedBox(width: 18),

                // Text & Badges Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Health Icon & Title Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.rosePink.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.health_and_safety_rounded,
                              size: 14,
                              color: AppColors.rosePink,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              title,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Motivational Badge: "Better than XX% of users"
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.softPurple.withValues(alpha: 0.2),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 13,
                              color: AppColors.softPurple,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Better than $percentile% of users',
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.softPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Supporting Description
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textMedium,
                          height: 1.35,
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
    );
  }
}
