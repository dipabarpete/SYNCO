import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/pcos_assessment_result.dart';
import '../models/pcos_result_level.dart';
import '../providers/pcos_assessment_provider.dart';

class PcosAssessmentResultScreen extends ConsumerWidget {
  final PcosAssessmentResult result;

  const PcosAssessmentResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color levelBgColor;
    Color levelTextColor;
    Color levelBorderColor;

    switch (result.resultLevel) {
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
              // Top Bar Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(pcosAssessmentProvider.notifier).reset();
                        Navigator.pop(context);
                      },
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
                      // 1. RESULT HEADER
                      Text(
                        'Your PCOS Screening Result',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Level Badge Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: levelBgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: levelBorderColor),
                        ),
                        child: Text(
                          result.resultLevel.levelBadgeText,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: levelTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Result Display Title
                      Text(
                        result.categoryTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Text(
                        'Based on the symptoms and health information you provided.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textMedium,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. IMPORTANT DISCLAIMER CARD
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.softPurple.withValues(alpha: 0.25),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowColor,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline_rounded,
                                  size: 20,
                                  color: AppColors.softPurple,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Important: Screening result, not a diagnosis',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'This screening looks at symptoms and health factors that can be associated with PCOS. It does not diagnose PCOS, and the result is not a probability of having PCOS. Other conditions can cause similar symptoms. A qualified healthcare professional is needed for diagnosis.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textMedium,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Do not use this result to start, stop, or change medication or treatment.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.deepRose,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 3. SYMPTOM GROUP SUMMARY
                      Text(
                        'Symptom Group Summary',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _symptomGroupRow('Menstrual / Cycle Symptoms', result.menstrualStatus),
                      const SizedBox(height: 10),
                      _symptomGroupRow('Hair / Skin / Androgen-Related Symptoms', result.androgenStatus),
                      const SizedBox(height: 10),
                      _symptomGroupRow('Metabolic-Associated Features', result.metabolicStatus),
                      const SizedBox(height: 10),
                      _symptomGroupRow('Existing Clinical Information', result.clinicalEvidenceStatus),
                      const SizedBox(height: 22),

                      // 4. USER-FRIENDLY EXPLANATION
                      Text(
                        'Explanation of Your Answers',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),

                      for (final bullet in result.explanationBullets)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.softPurple)),
                              Expanded(
                                child: Text(
                                  bullet,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.textDark,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      // 5. LEVEL-SPECIFIC DETAILS & CONTRIBUTING CATEGORIES
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderGrey),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowColor,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.categoryDescription,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textDark,
                                height: 1.45,
                              ),
                            ),
                            if (result.contributingCategories.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Text(
                                (result.resultLevel == PcosResultLevel.higher)
                                    ? 'Your result was mainly influenced by:'
                                    : 'Some areas worth keeping track of:',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              for (final category in result.contributingCategories)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 16, color: AppColors.softPurple),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
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
                      ),
                      const SizedBox(height: 22),

                      // 6. HIGH-SIGNAL SYMPTOMS (If present)
                      if (result.highSignalSymptoms.isNotEmpty) ...[
                        Text(
                          'Symptoms Worth Discussing With a Doctor',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final symptom in result.highSignalSymptoms)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.babyPink.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.medical_services_outlined, size: 18, color: AppColors.softPurple),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    symptom,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textDark,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],

                      // 7. LOWER-SPECIFICITY SYMPTOMS (If present)
                      if (result.lowerSpecificitySymptoms.isNotEmpty) ...[
                        Text(
                          'Other Symptoms You Reported',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'These symptoms can occur for many different reasons and are not specific to PCOS.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textMedium,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final symptom in result.lowerSpecificitySymptoms)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 6, color: AppColors.textMedium),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    symptom,
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],

                      // 8. SPECIAL CASES NOTICE (If present)
                      if (result.hasSpecialCaseNotice && result.specialCaseNoticeText != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFB74D)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 22, color: Color(0xFFE65100)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result.specialCaseNoticeText!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE65100),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 9. WHAT SHOULD I DO NEXT?
                      Text(
                        'What should I do next?',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        result.nextStepText,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textDark,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 26),

                      // 10. ACTION BUTTONS & DOCTOR SHARING
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: AppColors.primaryGradient,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              ref.read(pcosAssessmentProvider.notifier).reset();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              result.primaryCta,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      if (result.secondaryCta != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () {
                              ref.read(pcosAssessmentProvider.notifier).reset();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.softPurple),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              result.secondaryCta!,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.softPurple,
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Share With a Doctor Feature
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton.icon(
                          onPressed: () => _showDoctorSummaryDialog(context),
                          icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.softPurple),
                          label: Text(
                            'Share Summary With Doctor',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.softPurple,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
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

  Widget _symptomGroupRow(String title, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.babyPink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softPurple,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorSummaryDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'PCOS Screening Summary for Doctor',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(height: 20),

              Text('Assessment Date: ${result.completedAt.toString().split(' ').first}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium)),
              const SizedBox(height: 6),

              Text('Screening Result: ${result.categoryTitle}',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.softPurple)),
              const SizedBox(height: 14),

              Text('Symptom Group Statuses:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text('• Menstrual: ${result.menstrualStatus}', style: GoogleFonts.inter(fontSize: 13)),
              Text('• Hair/Skin/Androgen: ${result.androgenStatus}', style: GoogleFonts.inter(fontSize: 13)),
              Text('• Metabolic: ${result.metabolicStatus}', style: GoogleFonts.inter(fontSize: 13)),
              Text('• Clinical Info: ${result.clinicalEvidenceStatus}', style: GoogleFonts.inter(fontSize: 13)),
              const SizedBox(height: 16),

              if (result.highSignalSymptoms.isNotEmpty) ...[
                Text('Reported High-Signal Symptoms:',
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                for (final s in result.highSignalSymptoms)
                  Text('• $s', style: GoogleFonts.inter(fontSize: 13)),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.creamWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Text(
                  'Disclaimer: This summary is generated from user self-reported symptom screening. It is non-diagnostic and intended only to facilitate clinical discussion.',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium, height: 1.35),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Screening summary ready for doctor consultation.')),
                    );
                  },
                  icon: const Icon(Icons.check_rounded, color: Colors.white),
                  label: const Text('Close & Ready for Consultation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.softPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
