import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/saved_screening_result.dart';
import '../providers/screening_results_provider.dart';
import 'pcos_assessment_screen.dart';
import 'endometriosis_assessment_screen.dart';
import 'fibroids_assessment_screen.dart';

class SymptomsAssessmentScreen extends ConsumerWidget {
  const SymptomsAssessmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(screeningResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.creamWhite,
              Color(0xFFFFF0F5),
              Color(0xFFFAF8F5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textDark,
                        size: 20,
                      ),
                      tooltip: 'Back',
                    ),
                    const Spacer(),
                    Text(
                      'SYNCO',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Screen Title
                      Text(
                        'Symptoms Assessment',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Choose an assessment',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softPurple,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Medical Safety Notice
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.softPurple.withValues(alpha: 0.18),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowColor,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 20,
                              color: AppColors.softPurple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Symptom screening — This assessment is for informational and educational purposes only and is not a substitute for professional medical diagnosis or care.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMedium,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Option 1: PCOS
                      _AssessmentOptionCard(
                        title: 'PCOS',
                        subtitle: 'Symptom screening for Polycystic Ovary Syndrome / PCOD',
                        icon: Icons.donut_large_rounded,
                        lastResult: results[ScreeningAssessmentType.pcos],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PcosAssessmentScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Option 2: Endometriosis
                      _AssessmentOptionCard(
                        title: 'Endometriosis',
                        subtitle: 'Symptom screening for Endometriosis & pelvic health',
                        icon: Icons.favorite_border_rounded,
                        lastResult: results[ScreeningAssessmentType.endometriosis],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EndometriosisAssessmentScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),

                      // Option 3: Uterine Fibroids
                      _AssessmentOptionCard(
                        title: 'Uterine Fibroids',
                        subtitle: 'Symptom screening for Uterine Fibroids & uterine health',
                        icon: Icons.grain_rounded,
                        lastResult: results[ScreeningAssessmentType.uterineFibroids],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FibroidsAssessmentScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final SavedScreeningResult? lastResult;
  final VoidCallback onTap;

  const _AssessmentOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.lastResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.8),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.babyPink,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.lavenderAccent.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.softPurple,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMedium,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.softPurple,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                if (lastResult != null) ...[
                  const SizedBox(height: 16),
                  _LastAssessmentSection(result: lastResult!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LastAssessmentSection extends StatelessWidget {
  final SavedScreeningResult result;

  const _LastAssessmentSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text, Color border) = _levelColors(result.levelLabel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.softPurple,
              ),
              const SizedBox(width: 6),
              Text(
                'Last Assessment',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Score: ${result.rawScore}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Text(
              result.levelLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Last assessed: ${_formatDate(result.completedAt)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(DateTime date) {
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Mirrors the LOW / MODERATE / HIGH colors used across SYNCO result screens.
  (Color, Color, Color) _levelColors(String levelLabel) {
    final label = levelLabel.toLowerCase();
    if (label.contains('low')) {
      return (
        const Color(0xFFEBF7EE),
        const Color(0xFF2E7D32),
        const Color(0xFFA5D6A7),
      );
    }
    if (label.contains('moderate')) {
      return (
        const Color(0xFFFFF8E1),
        const Color(0xFFF57F17),
        const Color(0xFFFFE082),
      );
    }
    return (
      AppColors.babyPink,
      AppColors.softPurple,
      AppColors.softPurple.withValues(alpha: 0.3),
    );
  }
}
