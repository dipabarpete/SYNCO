import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../theme/app_colors.dart';

class AnimatedHealthScoreRing extends StatelessWidget {
  final int score; // e.g. 82
  final int percentile; // e.g. 78
  final String motivationalText;
  final VoidCallback? onTap;

  const AnimatedHealthScoreRing({
    super.key,
    required this.score,
    this.percentile = 78,
    this.motivationalText = 'Your body is in balance today! Great sleep & hydration.',
    this.onTap,
  });

  @override
  Widget build(BuildContext meContext) {
    final double percent = (score / 100.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF5F7),
              Color(0xFFF3EAF8),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 18,
              offset: Offset(0, 8),
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
              children: [
                // Circular Ring Indicator
                CircularPercentIndicator(
                  radius: 54.0,
                  lineWidth: 10.0,
                  animation: true,
                  animationDuration: 1200,
                  percent: percent,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score',
                        style: GoogleFonts.outfit(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softPurple,
                        ),
                      ),
                      Text(
                        '/100',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  circularStrokeCap: CircularStrokeCap.round,
                  backgroundColor: AppColors.softLavender.withValues(alpha: 0.5),
                  linearGradient: const LinearGradient(
                    colors: [
                      AppColors.blushPink,
                      AppColors.softPurple,
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Right Text Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.trending_up_rounded,
                              size: 14,
                              color: AppColors.softPurple,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Better than $percentile% of SYNCO users',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.softPurple,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Health Score',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        motivationalText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMedium,
                          height: 1.3,
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
