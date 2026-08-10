import '../data/pcos_questions_data.dart';
import '../models/pcos_assessment_result.dart';
import '../models/pcos_result_level.dart';

class PcosAssessmentScoringService {
  static PcosAssessmentResult calculateResult(Map<int, int> answers) {
    int score = 0;

    for (int i = 0; i < pcosQuestions.length; i++) {
      final question = pcosQuestions[i];
      if (answers.containsKey(i) && question.isScored) {
        final optionIndex = answers[i]!;
        if (optionIndex >= 0 && optionIndex < question.scores.length) {
          score += question.scores[optionIndex];
        }
      }
    }

    // Determine Result Level
    final PcosResultLevel level;
    if (score <= 6) {
      level = PcosResultLevel.low;
    } else if (score <= 12) {
      level = PcosResultLevel.moderate;
    } else {
      level = PcosResultLevel.higher;
    }

    final displayTitle = level.displayTitle;

    // Evaluate Category Statuses & Cluster Flags
    final q2Opt = answers[1]; // Q2: 0-21/35, 1-<21, 2->35, 3-unpredictable, 4-don't know
    final q3Opt = answers[2]; // Q3: 0-Never, 1-Occasionally, 2-Frequently, 3-Not sure
    final q4Opt = answers[3]; // Q4: 0-No, 1-Yes (90+ days), 2-Not sure
    final q5Opt = answers[4]; // Q5: 0-No, 1-Yes, 2-Not sure
    final q6Opt = answers[5]; // Q6: 0-1-7d, 1->7d, 2-<1d, 3-unpredictable
    final q7Opt = answers[6]; // Q7: 0-Light, 1-Moderate, 2-Heavy, 3-Very heavy

    int menstrualCount = 0;
    if (q2Opt == 2 || q2Opt == 3) menstrualCount += 2;
    if (q3Opt == 2) menstrualCount += 2;
    if (q4Opt == 1) menstrualCount += 2;
    if (q5Opt == 1) menstrualCount += 1;
    if (q6Opt == 1 || q6Opt == 3) menstrualCount += 1;
    if (q7Opt == 2 || q7Opt == 3) menstrualCount += 1;

    final menstrualCluster = menstrualCount >= 2 || (q2Opt == 2 || q2Opt == 3 || q4Opt == 1);
    final String menstrualStatus;
    if (menstrualCount >= 3 || q4Opt == 1) {
      menstrualStatus = 'Several associated features';
    } else if (menstrualCount >= 1) {
      menstrualStatus = 'Some associated features';
    } else {
      menstrualStatus = 'Few associated features';
    }

    // Hair / Skin / Androgen
    final q8Opt = answers[7]; // Facial hair: 0-No, 1-Mild, 2-Moderate, 3-Significant
    final q9Opt = answers[8]; // Body hair: 0-No, 1-Yes, 2-Not sure
    final q10Opt = answers[9]; // Acne: 0-No, 1-Occasionally, 2-Frequently, 3-Severe
    final q11Opt = answers[10]; // Scalp thinning: 0-No, 1-Mild, 2-Moderate, 3-Significant
    final q12Opt = answers[11]; // Worsening: 0-No, 1-Yes, 2-Not sure
    final q19Opt = answers[18]; // High testosterone: 0-No, 1-Yes, 2-Not tested, 3-Not sure

    int androgenCount = 0;
    if (q8Opt != null && q8Opt >= 1) androgenCount += (q8Opt >= 2 ? 2 : 1);
    if (q9Opt == 1) androgenCount += 1;
    if (q10Opt != null && q10Opt >= 1) androgenCount += (q10Opt >= 2 ? 2 : 1);
    if (q11Opt != null && q11Opt >= 1) androgenCount += (q11Opt >= 2 ? 2 : 1);
    if (q12Opt == 1) androgenCount += 1;
    if (q19Opt == 1) androgenCount += 2;

    final androgenCluster = androgenCount >= 2 || (q8Opt != null && q8Opt >= 2) || (q19Opt == 1);
    final String androgenStatus;
    if (androgenCount >= 3 || q19Opt == 1 || (q8Opt != null && q8Opt >= 2)) {
      androgenStatus = 'Several associated features';
    } else if (androgenCount >= 1) {
      androgenStatus = 'Some associated features';
    } else {
      androgenStatus = 'Few associated features';
    }

    // Metabolic
    final q13Opt = answers[12]; // Weight gain: 0-No, 1-Yes, 2-Not sure
    final q14Opt = answers[13]; // Difficult to lose: 0-No, 1-Sometimes, 2-Frequently, 3-N/A
    final q15Opt = answers[14]; // Insulin resistance: 0-No, 1-Yes, 2-Not sure
    final q16Opt = answers[15]; // Dark skin folds: 0-No, 1-Yes, 2-Not sure
    final q17Opt = answers[16]; // Type 2 diabetes: 0-No, 1-Yes, 2-Not sure

    int metabolicCount = 0;
    if (q13Opt == 1) metabolicCount += 1;
    if (q14Opt == 1 || q14Opt == 2) metabolicCount += 1;
    if (q15Opt == 1) metabolicCount += 2;
    if (q16Opt == 1) metabolicCount += 1;
    if (q17Opt == 1) metabolicCount += 2;

    final metabolicCluster = metabolicCount >= 2 || (q15Opt == 1) || (q17Opt == 1);
    final String metabolicStatus;
    if (metabolicCount >= 3 || q15Opt == 1 || q17Opt == 1) {
      metabolicStatus = 'Several associated features';
    } else if (metabolicCount >= 1) {
      metabolicStatus = 'Some associated features';
    } else {
      metabolicStatus = 'Few associated features';
    }

    // Existing Clinical Information
    final q18Opt = answers[17]; // Doctor told PCOS: 0-No, 1-Yes, 2-Currently evaluated
    final q20Opt = answers[19]; // Ultrasound polycystic: 0-No, 1-Yes, 2-Not sure, 3-Never had

    final clinicalEvidenceCluster = (q18Opt == 1 || q18Opt == 2) || (q20Opt == 1) || (q19Opt == 1);
    final String clinicalEvidenceStatus;
    if (q18Opt == 1 || q20Opt == 1 || q19Opt == 1) {
      clinicalEvidenceStatus = 'Previous clinical findings reported';
    } else if (q18Opt == 2) {
      clinicalEvidenceStatus = 'Some previous PCOS-related information reported';
    } else {
      clinicalEvidenceStatus = 'No previous PCOS-related information reported';
    }

    // User-friendly Dynamic Explanation Bullets (from actual answers)
    final explanationBullets = <String>[];
    if (menstrualCluster || menstrualCount >= 1) {
      explanationBullets.add(
        'Your responses indicate some menstrual-cycle features that can be associated with PCOS, such as irregular or widely spaced periods.',
      );
    }
    if (androgenCluster || androgenCount >= 1) {
      explanationBullets.add(
        'You also reported symptoms such as increased facial/body hair, persistent acne, or scalp-hair changes. These can sometimes be associated with higher androgen activity, but they can also have other causes.',
      );
    }
    if (metabolicCluster || metabolicCount >= 1) {
      explanationBullets.add(
        'You reported some metabolic health factors that can sometimes occur alongside PCOS.',
      );
    }
    if (clinicalEvidenceCluster) {
      explanationBullets.add(
        'You reported prior clinical findings or medical evaluation history relevant to PCOS.',
      );
    }
    if (explanationBullets.isEmpty) {
      explanationBullets.add(
        'Your answers currently show few features commonly associated with PCOS across menstrual, androgen, and metabolic domains.',
      );
    }

    // Dynamic Contributing Categories for Higher/Moderate Level
    final contributingCategories = <String>[];
    if (q2Opt == 2 || q2Opt == 3 || q4Opt == 1 || q3Opt == 2) {
      contributingCategories.add('Irregular or widely spaced menstrual cycles');
    }
    if (q8Opt != null && q8Opt >= 1 || q9Opt == 1) {
      contributingCategories.add('Increased facial or body hair');
    }
    if (q10Opt != null && q10Opt >= 1) {
      contributingCategories.add('Persistent acne');
    }
    if (q11Opt != null && q11Opt >= 1) {
      contributingCategories.add('Scalp-hair thinning');
    }
    if (q15Opt == 1 || q17Opt == 1) {
      contributingCategories.add('Insulin resistance or blood sugar history');
    }
    if (q16Opt == 1) {
      contributingCategories.add('Darkened skin folds');
    }
    if (q19Opt == 1) {
      contributingCategories.add('Previously elevated androgen/testosterone levels');
    }
    if (q20Opt == 1) {
      contributingCategories.add('Polycystic ovaries on prior ultrasound');
    }

    // High-Signal Symptoms ("Symptoms Worth Discussing With a Doctor")
    final highSignalSymptoms = <String>[];
    if (q2Opt == 2 || q2Opt == 3) {
      highSignalSymptoms.add('Your periods are very irregular or widely spaced.');
    }
    if (q4Opt == 1) {
      highSignalSymptoms.add('You reported going 90 days or more without a period when not pregnant.');
    }
    if ((q8Opt != null && q8Opt >= 2) || q9Opt == 1) {
      highSignalSymptoms.add('You reported increased facial or body hair.');
    }
    if (q11Opt != null && q11Opt >= 2) {
      highSignalSymptoms.add('You reported noticeable scalp-hair thinning or hair loss.');
    }
    if (q19Opt == 1) {
      highSignalSymptoms.add('You reported previously elevated androgen/testosterone levels.');
    }
    if (q20Opt == 1) {
      highSignalSymptoms.add('You reported previous ultrasound findings that may be relevant to PCOS evaluation.');
    }

    // Lower-Specificity Symptoms ("Other Symptoms You Reported")
    final lowerSpecificitySymptoms = <String>[];
    if (q13Opt == 1 || q14Opt == 1 || q14Opt == 2) {
      lowerSpecificitySymptoms.add('Difficulty losing weight despite diet or physical activity changes');
    }
    if (q10Opt == 1 || q10Opt == 2) {
      lowerSpecificitySymptoms.add('Acne or recurring breakouts');
    }

    // Special Cases Notice (90+ days without period, very heavy bleeding, severe rapid changes)
    final hasSpecialCaseNotice = (q4Opt == 1) || (q7Opt == 3) || (q12Opt == 1);
    final String? specialCaseNoticeText = hasSpecialCaseNotice
        ? 'Please consider speaking with a healthcare professional regarding persistent 90+ day absence of periods, very heavy bleeding, or marked recent symptom changes.'
        : null;

    // Body description & Recommendations per level
    final String description;
    final String? recommendation;
    final String nextStepText;
    final String primaryCta;
    final String? secondaryCta;
    final String? categoryCta;

    switch (level) {
      case PcosResultLevel.low:
        description =
            'Your responses currently show few features commonly associated with PCOS. This does not completely rule out PCOS or other hormonal conditions. Continue tracking your menstrual cycle and symptoms, especially if you notice persistent changes.';
        recommendation = 'Continue tracking your cycles and symptoms.';
        nextStepText =
            'Keep tracking your periods and symptoms. If your cycle becomes consistently irregular or you develop new symptoms, consider discussing them with a healthcare professional.';
        primaryCta = 'Continue Tracking';
        secondaryCta = 'Learn About PCOS';
        categoryCta = null;
        break;

      case PcosResultLevel.moderate:
        description =
            'Your responses include some symptoms or health factors that can occur with PCOS. However, these symptoms are not specific to PCOS and cannot determine whether you have the condition.';
        recommendation =
            'Continue tracking your cycles and symptoms. Consider discussing persistent or concerning changes with a healthcare professional.';
        nextStepText =
            'Continue tracking your menstrual cycle and symptoms. If these symptoms persist, become worse, or concern you, consider discussing them with a healthcare professional.';
        primaryCta = 'Continue Tracking';
        secondaryCta = 'Learn About PCOS';
        categoryCta = null;
        break;

      case PcosResultLevel.higher:
        description =
            'Your responses include multiple features that can be associated with PCOS. This does not mean that you have PCOS. Similar symptoms can occur with other hormonal or medical conditions.';
        recommendation =
            'This screening cannot diagnose PCOS. We recommend discussing your results with a qualified healthcare professional.';
        nextStepText =
            'Consider discussing your results and symptoms with a qualified healthcare professional. They can determine whether further evaluation is appropriate.';
        primaryCta = 'Discuss With a Doctor';
        secondaryCta = null;
        categoryCta = 'Discuss With a Doctor';
        break;
    }

    return PcosAssessmentResult(
      rawScore: score,
      resultLevel: level,
      categoryTitle: displayTitle,
      categoryDescription: description,
      categoryRecommendation: recommendation,
      categoryCta: categoryCta,
      menstrualCluster: menstrualCluster,
      androgenCluster: androgenCluster,
      metabolicCluster: metabolicCluster,
      clinicalEvidenceCluster: clinicalEvidenceCluster,
      menstrualStatus: menstrualStatus,
      androgenStatus: androgenStatus,
      metabolicStatus: metabolicStatus,
      clinicalEvidenceStatus: clinicalEvidenceStatus,
      explanationBullets: explanationBullets,
      highSignalSymptoms: highSignalSymptoms,
      lowerSpecificitySymptoms: lowerSpecificitySymptoms,
      contributingCategories: contributingCategories,
      nextStepText: nextStepText,
      primaryCta: primaryCta,
      secondaryCta: secondaryCta,
      hasSpecialCaseNotice: hasSpecialCaseNotice,
      specialCaseNoticeText: specialCaseNoticeText,
      answers: Map<int, int>.from(answers),
      completedAt: DateTime.now(),
    );
  }
}
