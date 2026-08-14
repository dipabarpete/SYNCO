import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/fibroids_assessment_result.dart';
import '../models/fibroids_result_level.dart';
import '../providers/fibroids_assessment_provider.dart';

class FibroidsAssessmentResultScreen extends ConsumerWidget {
  final UterineFibroidAssessmentResult result;

  const FibroidsAssessmentResultScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color levelBgColor;
    Color levelTextColor;
    Color levelBorderColor;

    switch (result.resultLevel) {
      case UterineFibroidResultLevel.low:
        levelBgColor = const Color(0xFFEBF7EE);
        levelTextColor = const Color(0xFF2E7D32);
        levelBorderColor = const Color(0xFFA5D6A7);
        break;
      case UterineFibroidResultLevel.moderate:
        levelBgColor = const Color(0xFFFFF8E1);
        levelTextColor = const Color(0xFFF57F17);
        levelBorderColor = const Color(0xFFFFE082);
        break;
      case UterineFibroidResultLevel.higher:
        levelBgColor = AppColors.babyPink;
        levelTextColor = AppColors.softPurple;
        levelBorderColor = AppColors.softPurple.withValues(alpha: 0.3);
        break;
    }

    final hasClusters = result.heavyBleedingCluster ||
        result.pelvicPressureCluster ||
        result.bladderBowelCluster ||
        result.anemiaAssociatedCluster ||
        result.fertilityClinicalCluster;

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
                        ref.read(fibroidsAssessmentProvider.notifier).reset();
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
                        'Your Uterine Fibroids Screening Result',
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

                      Text(
                        result.resultTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. PERSISTENT SAFETY DISCLAIMER CARD
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 22,
                              color: AppColors.softPurple,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Important: This is a symptom screening result, not a diagnosis. It does not determine whether you have uterine fibroids. Similar symptoms can occur with other conditions. Please consult a qualified healthcare professional for diagnosis and treatment.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textMedium,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 3. MEDICAL-ATTENTION FLAGS (If triggered)
                      for (final flag in result.medicalAttentionFlags) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFFB74D)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 22, color: Color(0xFFE65100)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  flag.message,
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
                        const SizedBox(height: 12),
                      ],
                      if (result.hasMedicalAttentionFlags) const SizedBox(height: 8),

                      // 4. MAIN DESCRIPTION & ADDITIONAL DETAILS
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(22),
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
                              result.description,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textDark,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              result.additionalText,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textMedium,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // 5. SYMPTOM CLUSTERS OVERVIEW
                      if (hasClusters) ...[
                        Text(
                          'Flagged Symptom Domains',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (result.heavyBleedingCluster)
                              _clusterChip(Icons.water_drop_outlined, 'Heavy Bleeding'),
                            if (result.pelvicPressureCluster)
                              _clusterChip(Icons.compress_rounded, 'Pelvic Pressure'),
                            if (result.bladderBowelCluster)
                              _clusterChip(Icons.local_hospital_outlined, 'Bladder/Bowel'),
                            if (result.anemiaAssociatedCluster)
                              _clusterChip(Icons.energy_savings_leaf_outlined, 'Anemia-Associated'),
                            if (result.fertilityClinicalCluster)
                              _clusterChip(Icons.medical_information_outlined, 'Fertility / Clinical History'),
                          ],
                        ),
                        const SizedBox(height: 22),
                      ],

                      // 6. SYMPTOMS YOU REPORTED
                      if (result.contributingSymptoms.isNotEmpty) ...[
                        Text(
                          'Symptoms You Reported',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final s in result.contributingSymptoms)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.softPurple),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    s,
                                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 22),
                      ],

                      // 7. SYMPTOMS WORTH DISCUSSING WITH A DOCTOR
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
                        for (final s in result.highSignalSymptoms)
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
                                    s,
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
                        const SizedBox(height: 22),
                      ],

                      // 8. WHAT SHOULD I DO NEXT?
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

                      // 9. ACTION BUTTONS & DOCTOR SHARING
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
                              ref.read(fibroidsAssessmentProvider.notifier).reset();
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
                              ref.read(fibroidsAssessmentProvider.notifier).reset();
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

  Widget _clusterChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.softPurple),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
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
                      'Uterine Fibroids Symptom Screening Summary',
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

              Text('Screening Result: ${result.resultTitle}',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.softPurple)),
              const SizedBox(height: 14),

              Text('Flagged Symptom Clusters:',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (result.heavyBleedingCluster) Text('• Heavy Bleeding Reported', style: GoogleFonts.inter(fontSize: 13)),
              if (result.pelvicPressureCluster) Text('• Pelvic Pressure Reported', style: GoogleFonts.inter(fontSize: 13)),
              if (result.bladderBowelCluster) Text('• Bladder/Bowel Symptoms Reported', style: GoogleFonts.inter(fontSize: 13)),
              if (result.anemiaAssociatedCluster) Text('• Anemia-Associated Symptoms Reported', style: GoogleFonts.inter(fontSize: 13)),
              if (result.fertilityClinicalCluster) Text('• Fertility / Clinical History Reported', style: GoogleFonts.inter(fontSize: 13)),
              const SizedBox(height: 16),

              if (result.contributingSymptoms.isNotEmpty) ...[
                Text('Reported Symptoms:', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                for (final s in result.contributingSymptoms)
                  Text('• $s', style: GoogleFonts.inter(fontSize: 13)),
                const SizedBox(height: 16),
              ],

              for (final entry in _summaryGroupBullets()) ...[
                Text(entry.$1, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                for (final line in entry.$2) Text(line, style: GoogleFonts.inter(fontSize: 13)),
                const SizedBox(height: 10),
              ],

              if (result.hasMedicalAttentionFlags) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFB74D)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medical-Attention Flags:',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFE65100)),
                      ),
                      const SizedBox(height: 4),
                      for (final flag in result.medicalAttentionFlags)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${flag.message}',
                            style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFE65100), height: 1.35),
                          ),
                        ),
                    ],
                  ),
                ),
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
                  'This summary is based on user-reported symptoms and is not a medical diagnosis.',
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
                      const SnackBar(content: Text('Uterine fibroids summary ready for doctor consultation.')),
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

  List<(String, List<String>)> _summaryGroupBullets() {
    final answers = result.answers;
    final q1Opt = answers[0];
    final q2Opt = answers[1];
    final q3Opt = answers[2];
    final q4Opt = answers[3];
    final q5Opt = answers[4];
    final q6Opt = answers[5];
    final q7Opt = answers[6];
    final q8Opt = answers[7];
    final q9Opt = answers[8];
    final q10Opt = answers[9];
    final q11Opt = answers[10];
    final q12Opt = answers[11];
    final q13Opt = answers[12];
    final q14Opt = answers[13];
    final q15Opt = answers[14];
    final q16Opt = answers[15];
    final q17Opt = answers[16];
    final q18Opt = answers[17];
    final q19Opt = answers[18];
    final q20Opt = answers[19];
    final q21Opt = answers[20];
    final q22Opt = answers[21];
    final q23Opt = answers[22];
    final q24Opt = answers[23];

    final groups = <(String, List<String>)>[];
    void addGroup(String label, List<String> lines) {
      if (lines.isNotEmpty) groups.add((label, lines));
    }

    addGroup('Menstrual Bleeding', [
      if (q1Opt != null && q1Opt >= 2) '• Heavy or very heavy menstrual bleeding',
      if (q2Opt != null && q2Opt >= 2) '• Periods lasting longer than usual',
      if (q3Opt != null && q3Opt >= 2) '• Frequent menstrual product changes due to bleeding',
      if (q4Opt != null && q4Opt >= 2) '• Bleeding that soaks through products or clothes',
      if (q5Opt == 2 || q5Opt == 3) '• Frequent or larger blood clots',
      if (q6Opt != null && q6Opt >= 2) '• Periods becoming heavier or longer over time',
      if (q7Opt != null && q7Opt >= 1) '• Spotting or bleeding between periods',
      if (q8Opt != null && q8Opt >= 1 && q8Opt != 3) '• Bleeding after sexual intercourse',
    ]);

    addGroup('Pelvic Symptoms', [
      if (q9Opt != null && q9Opt >= 1) '• Pelvic pressure, heaviness, or fullness',
      if (q10Opt != null && q10Opt >= 1) '• Pelvic or lower abdominal pain',
      if (q11Opt != null && q11Opt >= 1) '• Lower back pain related to pelvic symptoms',
      if (q12Opt != null && q12Opt >= 1 && q12Opt != 3) '• Lower abdomen enlarged or unusually full',
    ]);

    addGroup('Bladder/Bowel Symptoms', [
      if (q13Opt != null && q13Opt >= 1) '• More frequent urination',
      if (q14Opt != null && q14Opt >= 1) '• Bladder pressure or incomplete emptying',
      if (q15Opt != null && q15Opt >= 1) '• Constipation or difficulty passing stool',
      if (q16Opt != null && q16Opt >= 1) '• Pressure or discomfort with bowel movements',
    ]);

    addGroup('Anemia-Associated Information', [
      if (q17Opt != null && q17Opt >= 2) '• Frequent fatigue or low energy',
      if (q18Opt != null && q18Opt >= 1) '• Dizziness, light-headedness, or weakness around periods',
      if (q19Opt == 1) '• Previously told of anemia or low iron',
    ]);

    addGroup('Fertility Information', [
      if (q20Opt == 1) '• Currently trying to become pregnant',
      if (q21Opt == 1) '• Difficulty becoming pregnant',
      if (q22Opt == 1) '• Recurrent pregnancy loss',
    ]);

    addGroup('Existing Fibroid-Related Medical History', [
      if (q23Opt != null && q23Opt >= 1) '• Previously told by a healthcare professional of uterine fibroids',
      if (q24Opt == 1) '• Previous imaging showing a uterine fibroid or growth',
    ]);

    return groups;
  }
}