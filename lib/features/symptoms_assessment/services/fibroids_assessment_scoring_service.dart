import '../data/fibroids_questions_data.dart';
import '../models/fibroids_assessment_result.dart';
import '../models/fibroids_result_level.dart';

class UterineFibroidAssessmentScoringService {
  static UterineFibroidAssessmentResult calculateResult(Map<int, int> answers) {
    int score = 0;

    for (int i = 0; i < fibroidsQuestions.length; i++) {
      final question = fibroidsQuestions[i];
      if (answers.containsKey(i) && question.isScored) {
        final optionIndex = answers[i]!;
        if (optionIndex >= 0 && optionIndex < question.scores.length) {
          score += question.scores[optionIndex];
        }
      }
    }

    // Determine Result Level (0-8: Low, 9-17: Moderate, 18+: Higher)
    // These are product screening thresholds only, not clinically
    // validated diagnostic thresholds.
    final UterineFibroidResultLevel level;
    if (score <= 8) {
      level = UterineFibroidResultLevel.low;
    } else if (score <= 17) {
      level = UterineFibroidResultLevel.moderate;
    } else {
      level = UterineFibroidResultLevel.higher;
    }

    final displayTitle = level.displayTitle;

    // Retrieve Question Answers (option indexes)
    final q1Opt = answers[0]; // Q1 Bleeding description
    final q2Opt = answers[1]; // Q2 Period length
    final q3Opt = answers[2]; // Q3 Frequent product changes
    final q4Opt = answers[3]; // Q4 Soaking through
    final q5Opt = answers[4]; // Q5 Blood clots
    final q6Opt = answers[5]; // Q6 Heavier/longer over time
    final q7Opt = answers[6]; // Q7 Spotting between periods
    final q8Opt = answers[7]; // Q8 Bleeding after intercourse
    final q9Opt = answers[8]; // Q9 Pelvic pressure/heaviness
    final q10Opt = answers[9]; // Q10 Pelvic pain
    final q11Opt = answers[10]; // Q11 Lower back pain
    final q12Opt = answers[11]; // Q12 Abdomen enlarged/swollen
    final q13Opt = answers[12]; // Q13 Frequent urination
    final q14Opt = answers[13]; // Q14 Bladder pressure
    final q15Opt = answers[14]; // Q15 Constipation
    final q16Opt = answers[15]; // Q16 Bowel pressure
    final q17Opt = answers[16]; // Q17 Fatigue
    final q18Opt = answers[17]; // Q18 Dizziness/weakness
    final q19Opt = answers[18]; // Q19 Previous anemia/low iron
    final q21Opt = answers[20]; // Q21 Difficulty becoming pregnant
    final q22Opt = answers[21]; // Q22 Recurrent pregnancy loss
    final q23Opt = answers[22]; // Q23 Told of fibroids by professional
    final q24Opt = answers[23]; // Q24 Imaging showed fibroid/growth

    // 5 Feature Clusters (evaluated independently of the total score)
    final heavyBleedingCluster = (q1Opt != null && q1Opt >= 2) ||
        (q2Opt != null && q2Opt >= 2) ||
        (q3Opt != null && q3Opt >= 2) ||
        (q4Opt != null && q4Opt >= 2) ||
        (q5Opt == 2 || q5Opt == 3) ||
        (q6Opt != null && q6Opt >= 2);

    final pelvicPressureCluster = (q9Opt != null && q9Opt >= 1) ||
        (q10Opt != null && q10Opt >= 1) ||
        (q12Opt != null && q12Opt >= 1 && q12Opt != 3);

    final bladderBowelCluster = (q13Opt != null && q13Opt >= 1) ||
        (q14Opt != null && q14Opt >= 1) ||
        (q15Opt != null && q15Opt >= 1) ||
        (q16Opt != null && q16Opt >= 1);

    final anemiaAssociatedCluster = (q17Opt != null && q17Opt >= 2) ||
        (q18Opt != null && q18Opt >= 1) ||
        (q19Opt == 1);

    final fertilityClinicalCluster = (q21Opt == 1) ||
        (q22Opt == 1) ||
        (q23Opt == 1 || q23Opt == 2) ||
        (q24Opt == 1);

    // Medical-Attention Safety Flags (separate from the screening score)
    final medicalAttentionFlags = <UterineFibroidAttentionFlag>[];

    final hasHeavyBleedingFlag =
        (q1Opt == 3) || (q4Opt != null && q4Opt >= 2) || (q18Opt != null && q18Opt >= 2);
    if (hasHeavyBleedingFlag) {
      medicalAttentionFlags.add(
        const UterineFibroidAttentionFlag(
          id: 'heavyBleeding',
          message:
              'Your reported bleeding may need medical evaluation. If you are experiencing very heavy bleeding, significant weakness, dizziness, fainting, or other concerning symptoms, seek medical care promptly.',
        ),
      );
    }

    final hasAnemiaFlag = (q19Opt == 1) ||
        (q18Opt != null && q18Opt >= 2) ||
        ((q17Opt != null && q17Opt >= 2) && (q1Opt != null && q1Opt >= 2));
    if (hasAnemiaFlag) {
      medicalAttentionFlags.add(
        const UterineFibroidAttentionFlag(
          id: 'anemia',
          message:
              'You reported information that may be relevant to anemia or low iron. Consider discussing this with a healthcare professional and asking whether blood testing is appropriate.',
        ),
      );
    }

    final hasExistingFibroidFlag =
        (q23Opt != null && q23Opt >= 1) || (q24Opt == 1);
    if (hasExistingFibroidFlag) {
      medicalAttentionFlags.add(
        const UterineFibroidAttentionFlag(
          id: 'existingFibroid',
          message:
              'You reported previous medical information related to fibroids. Your healthcare professional can interpret your previous diagnosis or imaging together with your current symptoms.',
        ),
      );
    }

    // Dynamic Contributing Symptoms ("Symptoms You Reported")
    // Only symptoms actually selected by the user are included.
    final contributingSymptoms = <String>[];
    if (q1Opt != null && q1Opt >= 2) {
      contributingSymptoms.add('Heavy or very heavy menstrual bleeding');
    }
    if (q2Opt != null && q2Opt >= 2) {
      contributingSymptoms.add('Periods lasting longer than usual');
    }
    if (q3Opt != null && q3Opt >= 2) {
      contributingSymptoms.add('Frequent menstrual product changes due to bleeding');
    }
    if (q4Opt != null && q4Opt >= 2) {
      contributingSymptoms.add('Bleeding that sometimes soaks through products or clothes');
    }
    if (q5Opt == 2 || q5Opt == 3) {
      contributingSymptoms.add('Frequent or larger blood clots');
    }
    if (q6Opt != null && q6Opt >= 2) {
      contributingSymptoms.add('Periods becoming heavier or longer over time');
    }
    if (q7Opt != null && q7Opt >= 1) {
      contributingSymptoms.add('Bleeding or spotting between periods');
    }
    if (q8Opt != null && q8Opt >= 1 && q8Opt != 3) {
      contributingSymptoms.add('Bleeding after sexual intercourse');
    }
    if (q9Opt != null && q9Opt >= 1) {
      contributingSymptoms.add('Pelvic pressure or fullness');
    }
    if (q10Opt != null && q10Opt >= 1) {
      contributingSymptoms.add('Pelvic or lower abdominal pain');
    }
    if (q11Opt != null && q11Opt >= 1) {
      contributingSymptoms.add('Lower back pain related to pelvic symptoms');
    }
    if (q12Opt != null && q12Opt >= 1 && q12Opt != 3) {
      contributingSymptoms.add('Lower abdomen feeling enlarged or unusually full');
    }
    if ((q13Opt != null && q13Opt >= 1) || (q14Opt != null && q14Opt >= 1)) {
      contributingSymptoms.add('Frequent urination or bladder pressure');
    }
    if ((q15Opt != null && q15Opt >= 1) || (q16Opt != null && q16Opt >= 1)) {
      contributingSymptoms.add('Constipation or bowel pressure');
    }
    if ((q17Opt != null && q17Opt >= 2) ||
        (q18Opt != null && q18Opt >= 1) ||
        q19Opt == 1) {
      contributingSymptoms.add('Fatigue, dizziness, or previously reported low iron');
    }
    if (q21Opt == 1 || q22Opt == 1) {
      contributingSymptoms.add('Difficulty becoming pregnant');
    }
    if ((q23Opt != null && q23Opt >= 1) || q24Opt == 1) {
      contributingSymptoms.add('Previous fibroid-related medical evaluation');
    }

    // Symptoms Worth Discussing With a Doctor
    final highSignalSymptoms = <String>[];
    if (q1Opt == 3) highSignalSymptoms.add('Very heavy menstrual bleeding');
    if (q2Opt != null && q2Opt >= 3) highSignalSymptoms.add('Periods lasting unusually long');
    if (q4Opt != null && q4Opt >= 2) {
      highSignalSymptoms.add('Bleeding that frequently soaks through menstrual products or clothes');
    }
    if (q5Opt == 2 || q5Opt == 3) highSignalSymptoms.add('Frequent or larger blood clots');
    if (q9Opt != null && q9Opt >= 2) highSignalSymptoms.add('Pelvic pressure/fullness');
    if (q10Opt != null && q10Opt >= 3) highSignalSymptoms.add('Persistent pelvic pain');
    if ((q13Opt != null && q13Opt >= 2) || (q14Opt != null && q14Opt >= 2)) {
      highSignalSymptoms.add('Frequent urination or bladder pressure');
    }
    if ((q15Opt != null && q15Opt >= 2) || (q16Opt != null && q16Opt >= 2)) {
      highSignalSymptoms.add('Constipation or bowel pressure');
    }
    if (q18Opt != null && q18Opt >= 2) {
      highSignalSymptoms.add('Dizziness or weakness associated with heavy periods');
    }
    if (q19Opt == 1) highSignalSymptoms.add('Previous anemia/low iron');
    if (q21Opt == 1) highSignalSymptoms.add('Difficulty becoming pregnant');
    if ((q23Opt != null && q23Opt >= 1) || q24Opt == 1) {
      highSignalSymptoms.add('Previous fibroid diagnosis or imaging finding');
    }

    // Text descriptions per level
    final String description;
    final String additionalText;
    final String nextStepText;
    final String primaryCta;
    final String? secondaryCta;

    switch (level) {
      case UterineFibroidResultLevel.low:
        description =
            'Your responses currently show relatively few symptoms commonly associated with uterine fibroids.';
        additionalText =
            'This does not completely rule out fibroids or other causes of menstrual or pelvic symptoms.';
        nextStepText =
            'Continue tracking your periods and symptoms. If you develop persistent, worsening, or disruptive symptoms, consider discussing them with a healthcare professional.';
        primaryCta = 'Continue Tracking';
        secondaryCta = 'Learn About Fibroids';
        break;

      case UterineFibroidResultLevel.moderate:
        description =
            'Your responses include some symptoms that can occur with uterine fibroids, particularly related to menstrual bleeding and/or pelvic pressure.';
        additionalText =
            'These symptoms can have many other causes, so this screening cannot determine whether you have fibroids.';
        nextStepText =
            'Consider continuing to track your symptoms and discussing persistent or bothersome symptoms with a healthcare professional.';
        primaryCta = 'Continue Tracking';
        secondaryCta = 'Discuss With a Doctor';
        break;

      case UterineFibroidResultLevel.higher:
        description =
            'Your responses include several symptoms that can occur with uterine fibroids.';
        additionalText =
            'This does not mean that you have fibroids. Similar symptoms can occur with other conditions. A healthcare professional can determine whether further evaluation or imaging, such as an ultrasound, is appropriate.';
        nextStepText =
            'Consider discussing your symptoms with a gynecologist or another qualified healthcare professional.';
        primaryCta = 'Discuss With a Doctor';
        secondaryCta = 'Track My Symptoms';
        break;
    }

    return UterineFibroidAssessmentResult(
      rawScore: score,
      resultLevel: level,
      resultTitle: displayTitle,
      description: description,
      additionalText: additionalText,
      nextStepText: nextStepText,
      heavyBleedingCluster: heavyBleedingCluster,
      pelvicPressureCluster: pelvicPressureCluster,
      bladderBowelCluster: bladderBowelCluster,
      anemiaAssociatedCluster: anemiaAssociatedCluster,
      fertilityClinicalCluster: fertilityClinicalCluster,
      contributingSymptoms: contributingSymptoms,
      highSignalSymptoms: highSignalSymptoms,
      medicalAttentionFlags: medicalAttentionFlags,
      primaryCta: primaryCta,
      secondaryCta: secondaryCta,
      answers: Map<int, int>.from(answers),
      completedAt: DateTime.now(),
    );
  }
}