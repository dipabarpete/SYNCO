import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/pcos_result_level.dart';

class PcosScreeningResultCard extends StatelessWidget {
  final PcosResultLevel level;
  final String title;
  final String summary;
  final List<String> contributingClusters;
  final List<String> reportedSymptoms;
  final String nextStep;

  const PcosScreeningResultCard({
    super.key,
    required this.level,
    required this.title,
    required this.summary,
    required this.contributingClusters,
    required this.reportedSymptoms,
    required this.nextStep,
  });

  @override
  Widget build(BuildContext context) {
    Color levelBgColor;
    Color levelTextColor;
    Color levelBorderColor;

    switch (level) {
      case PcosResultLevel.low:
        levelBgColor = const Color(0xFFEBF7EE);
        levelTextColor = const Color(0xFF2E7D32);
        levelBorderColor = const Color(0xFFA5D6A7);
        break;
      case PcosResultLevel.moderate:
        levelBgColor = const Color(0xFFFFF8E1);
        levelTextColor = const Color(0xFFF57F17);
        levelBorderColor = const Color(0xFFFFE082);
        break;
      case PcosResultLevel.higher:
        levelBgColor = AppColors.babyPink;
        levelTextColor = AppColors.softPurple;
        levelBorderColor = AppColors.softPurple.withValues(alpha: 0.3);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: levelBorderColor,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Pill Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: levelBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: levelBorderColor),
            ),
            child: Text(
              level.levelBadgeText,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: levelTextColor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),

          // Summary
          Text(
            summary,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.45,
            ),
          ),

          if (contributingClusters.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Contributing Areas:',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            for (final cluster in contributingClusters)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
                    Expanded(
                      child: Text(
                        cluster,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          if (nextStep.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creamWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.softPurple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      nextStep,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
