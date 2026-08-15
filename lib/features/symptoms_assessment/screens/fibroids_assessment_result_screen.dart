import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../doctor/models/doctor.dart';
import '../../doctor/screens/all_doctors_screen.dart';
import '../../doctor/screens/find_doctor_screen.dart';
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
                            onPressed: () => _onPrimaryCta(context, ref),
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
                            onPressed: () => _onSecondaryCta(context, ref),
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

                      // Consult a Doctor Feature
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton.icon(
                          onPressed: () => _onConsultDoctor(context, ref),
                          icon: const Icon(
                            Icons.medical_services_outlined,
                            size: 18,
                            color: AppColors.softPurple,
                          ),
                          label: Text(
                            'Consult a Doctor',
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

  /// Primary CTA: "Discuss With a Doctor" opens the existing All Doctors
  /// list from the Consult section; other CTAs return to the assessment menu.
  void _onPrimaryCta(BuildContext context, WidgetRef ref) {
    ref.read(fibroidsAssessmentProvider.notifier).reset();
    if (result.primaryCta == 'Discuss With a Doctor') {
      _openDoctorList(context, ref);
    } else {
      Navigator.pop(context);
    }
  }

  void _onSecondaryCta(BuildContext context, WidgetRef ref) {
    ref.read(fibroidsAssessmentProvider.notifier).reset();
    if (result.secondaryCta == 'Discuss With a Doctor') {
      _openDoctorList(context, ref);
    } else {
      Navigator.pop(context);
    }
  }

  /// Opens the existing Consult section.
  void _onConsultDoctor(BuildContext context, WidgetRef ref) {
    ref.read(fibroidsAssessmentProvider.notifier).reset();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FindDoctorScreen()),
    );
  }

  void _openDoctorList(BuildContext context, WidgetRef ref) {
    final doctors =
        ref.read(doctorsProvider).value ?? const <Doctor>[];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllDoctorsScreen(doctors: doctors),
      ),
    );
  }
}