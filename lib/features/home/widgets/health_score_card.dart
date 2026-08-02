import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

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
    this.description = 'Your consistency is paying off.',
    this.onTap,
    this.onViewReportTap,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final double percent = (score / 100.0).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCF5FB),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: const Color(0xFFF3E4F3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B4397).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: Stack(
          children: [
            // Background Decorative Glow Circles
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFE0EE).withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF4E8FB).withValues(alpha: 0.4),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. TOP HEADER ROW: Pulse Icon + HEALTH SCORE + Info Icon
                  Row(
                    children: [
                      const Icon(
                        Icons.show_chart_rounded,
                        size: 16,
                        color: Color(0xFFFF4081),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9D658B),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.info_outline_rounded,
                        size: 15,
                        color: const Color(0xFF9D658B).withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. MAIN SECTION: Circular Progress (Left) + Heading & Suggestion Card (Right)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Circular Progress Ring
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: CircularPercentIndicator(
                          radius: 46.0,
                          lineWidth: 9.0,
                          animation: true,
                          animationDuration: 1000,
                          percent: percent,
                          circularStrokeCap: CircularStrokeCap.round,
                          backgroundColor: const Color(0xFFFFE3EC),
                          linearGradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF5EA3),
                              Color(0xFFFF2D75),
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
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF2D75),
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '/100',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7B6D86),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Right Section: Title, Subtitle, Emoji & Suggestion Card
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Primary Heading
                            Text(
                              "You're doing amazing!",
                              style: GoogleFonts.newsreader(
                                fontSize: 18.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2B2035),
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Text(
                                  '👏',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              description,
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF756A80),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Suggestion Card
                            GestureDetector(
                              onTap: onSuggestionTap ?? onTap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 9.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.0),
                                  border: Border.all(
                                    color: const Color(0xFFF1E5F6),
                                    width: 1.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7B4397)
                                          .withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Moon/Sleep Icon Badge
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3EAF8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.nightlight_round_outlined,
                                        size: 17,
                                        color: Color(0xFF9D65C9),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Suggestion Text
                                    Expanded(
                                      child: Text(
                                        'Better sleep can\nimprove your score',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF382A45),
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    // Arrow Icon
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: Color(0xFFB893D9),
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

                  const SizedBox(height: 14),
                  // Thin Separator Line
                  Container(
                    height: 1.0,
                    color: const Color(0xFFF1E4F2),
                  ),
                  const SizedBox(height: 12),

                  // 3. BOTTOM ROW: "Great job!" (Left) + Gradient Pill Button "View Full Report →" (Right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Great job!',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7B6D86),
                        ),
                      ),
                      GestureDetector(
                        onTap: onViewReportTap ?? onTap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 9.0,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF5EA3),
                                Color(0xFFFF3366),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(30.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF3366)
                                    .withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Full Report',
                                style: GoogleFonts.outfit(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
