import '../data/endometriosis_questions_data.dart';
import '../models/endometriosis_assessment_result.dart';
import '../models/endometriosis_result_level.dart';

class EndometriosisAssessmentScoringService {
  static EndometriosisAssessmentResult calculateResult(Map<int, int> answers) {
    int score = 0;

    for (int i = 0; i < endometriosisQuestions.length; i++) {
      final question = endometriosisQuestions[i];
      if (answers.containsKey(i) && question.isScored) {
        final optionIndex = answers[i]!;
        if (optionIndex >= 0 && optionIndex < question.scores.length) {
          score += question.scores[optionIndex];
        }
      }
    }

    // Determine Result Level (0-9: Low, 10-19: Moderate, 20+: Higher)
    final EndometriosisResultLevel level;
    if (score <= 9) {
      level = EndometriosisResultLevel.low;
    } else if (score <= 19) {
      level = EndometriosisResultLevel.moderate;
    } else {
      level = EndometriosisResultLevel.higher;
    }

    final displayTitle = level.displayTitle;

    // Retrieve Question Answers
    final q1Opt = answers[0]; // Q1 Pain: 0-None, 1-Mild, 2-Moderate, 3-Severe, 4-Very severe
    final q2Opt = answers[1]; // Q2 Interfere: 0-Never, 1-Occasionally, 2-Frequently, 3-Almost every period
    final q4Opt = answers[3]; // Q4 Worse over time: 0-No, 1-Slightly, 2-Noticeably, 3-Significantly
    final q5Opt = answers[4]; // Q5 Pain before & during: 0-No, 1-Sometimes, 2-Often, 3-Almost every cycle
    final q6Opt = answers[5]; // Q6 Non-period pelvic pain: 0-Never, 1-Occasionally, 2-Frequently, 3-Almost constantly
    final q7Opt = answers[6]; // Q7 Pelvic pain worse around period: 0-No, 1-Sometimes, 2-Often, 3-Every cycle
    final q10Opt = answers[9]; // Q10 Deep pain during sex: 0-No, 1-Occasionally, 2-Frequently, 3-Almost every time, 4-N/A
    final q11Opt = answers[10]; // Q11 Pain after sex: 0-No, 1-Occasionally, 2-Frequently, 3-Almost every time, 4-N/A
    final q12Opt = answers[11]; // Q12 Painful bowel movement: 0-Never, 1-Occasionally, 2-Frequently, 3-Mainly period, 4-Almost every period
    final q13Opt = answers[12]; // Q13 Constipation/diarrhea/bloating: 0-No, 1-Occasionally, 2-Frequently, 3-Almost every cycle
    final q14Opt = answers[13]; // Q14 Bowel pain during period: 0-No, 1-Mild, 2-Moderate, 3-Severe
    final q15Opt = answers[14]; // Q15 Blood in stool: 0-No, 1-Yes, 2-Not sure
    final q16Opt = answers[15]; // Q16 Painful urination: 0-No, 1-Occasionally, 2-Frequently, 3-Almost every cycle
    final q17Opt = answers[16]; // Q17 Blood in urine: 0-No, 1-Yes, 2-Not sure
    final q18Opt = answers[17]; // Q18 Bladder pain without infection: 0-No, 1-Occasionally, 2-Frequently, 3-Not sure
    final q22Opt = answers[21]; // Q22 Difficulty becoming pregnant: 0-No, 1-Yes, 2-N/A, 3-Prefer not to say
    final q23Opt = answers[22]; // Q23 Doctor told endo: 0-No, 1-Yes, 2-Currently evaluated
    final q24Opt = answers[23]; // Q24 Endometrioma/cyst: 0-No, 1-Yes, 2-Not sure, 3-Never had

    // 5 Symptom Clusters
    final painCluster = (q1Opt != null && q1Opt >= 3) ||
        (q2Opt != null && q2Opt >= 2) ||
        (q6Opt != null && q6Opt >= 1) ||
        (q4Opt != null && q4Opt >= 2) ||
        (q5Opt != null && q5Opt >= 1) ||
        (q7Opt != null && q7Opt >= 1);

    final deepPelvicPainCluster = (q10Opt != null && q10Opt >= 1 && q10Opt != 4) ||
        (q11Opt != null && q11Opt >= 1 && q11Opt != 4) ||
        (q6Opt == 3);

    final bowelCluster = (q12Opt != null && q12Opt >= 1) ||
        (q13Opt != null && q13Opt >= 1) ||
        (q14Opt != null && q14Opt >= 1) ||
        (q15Opt == 1);

    final urinaryCluster = (q16Opt != null && q16Opt >= 1) ||
        (q17Opt == 1) ||
        (q18Opt != null && q18Opt >= 1 && q18Opt != 3);

    final fertilityClinicalCluster =
        (q22Opt == 1) || (q23Opt == 1 || q23Opt == 2) || (q24Opt == 1);

    // Urgent Medical-Attention Safety Flags
    final hasMedicalAttentionFlags = (q15Opt == 1) ||
        (q17Opt == 1) ||
        (q1Opt != null && q1Opt >= 3) ||
        (q6Opt == 3) ||
        (q2Opt == 3) ||
        (q4Opt == 3);

    final String? medicalAttentionNotice = hasMedicalAttentionFlags
        ? 'Some of the symptoms you reported may need medical evaluation. Consider contacting a healthcare professional, particularly if symptoms are severe, new, or worsening.'
        : null;

    // Dynamic Contributing Symptoms ("Symptoms You Reported")
    final contributingSymptoms = <String>[];
    if (q1Opt != null && q1Opt >= 3) contributingSymptoms.add('Severe menstrual pain');
    if (q2Opt != null && q2Opt >= 2) contributingSymptoms.add('Period pain affecting daily activities');
    if (q6Opt != null && q6Opt >= 1) contributingSymptoms.add('Pelvic pain outside your period');
    if ((q10Opt != null && q10Opt >= 1 && q10Opt != 4) || (q11Opt != null && q11Opt >= 1 && q11Opt != 4)) {
      contributingSymptoms.add('Deep pelvic pain during or after sex');
    }
    if (q12Opt != null && q12Opt >= 1) contributingSymptoms.add('Pain with bowel movements');
    if ((q13Opt != null && q13Opt >= 1) || (q14Opt != null && q14Opt >= 1)) {
      contributingSymptoms.add('Bowel symptoms that worsen around your period');
    }
    if ((q16Opt != null && q16Opt >= 1) || (q18Opt != null && q18Opt >= 1 && q18Opt != 3)) {
      contributingSymptoms.add('Urinary symptoms that worsen around your period');
    }
    if (q22Opt == 1) contributingSymptoms.add('Difficulty becoming pregnant');
    if ((q23Opt == 1 || q23Opt == 2) || q24Opt == 1) {
      contributingSymptoms.add('Previous endometriosis-related medical evaluation or findings');
    }

    // High-Signal Symptoms ("Symptoms Worth Discussing With a Doctor")
    final highSignalSymptoms = <String>[];
    if (q1Opt != null && q1Opt >= 3) highSignalSymptoms.add('Severe or disabling period pain');
    if (q2Opt != null && q2Opt >= 2) highSignalSymptoms.add('Pain that interferes with daily activities');
    if (q6Opt != null && q6Opt >= 1) highSignalSymptoms.add('Pelvic pain outside periods');
    if (q10Opt != null && q10Opt >= 1 && q10Opt != 4) highSignalSymptoms.add('Deep pelvic pain during sex');
    if (q12Opt == 3 || q12Opt == 4) highSignalSymptoms.add('Painful bowel movements, especially around periods');
    if (q15Opt == 1) highSignalSymptoms.add('Blood in stool around periods');
    if (q16Opt == 2 || q16Opt == 3) highSignalSymptoms.add('Painful urination around periods');
    if (q17Opt == 1) highSignalSymptoms.add('Blood in urine around periods');
    if (q22Opt == 1) highSignalSymptoms.add('Difficulty becoming pregnant');
    if (q24Opt == 1) highSignalSymptoms.add('Previous endometrioma or scan/surgical findings');

    // Text descriptions per level
    final String description;
    final String additionalText;
    final String nextStepText;
    final String primaryCta;
    final String? secondaryCta;

    switch (level) {
      case EndometriosisResultLevel.low:
        description =
            'Your responses currently show relatively few features commonly associated with endometriosis.';
        additionalText =
            'This does not completely rule out endometriosis or other causes of pelvic pain. Symptoms can vary significantly between people.';
        nextStepText =
            'Continue tracking your periods and symptoms. If you develop persistent, worsening, or disruptive symptoms, consider discussing them with a healthcare professional.';
        primaryCta = 'Continue Tracking';
        secondaryCta = 'Learn About Endometriosis';
        break;

      case EndometriosisResultLevel.moderate:
        description =
            'Your responses include some symptoms or symptom patterns that can be associated with endometriosis.';
        additionalText =
            'These symptoms can also occur with other gynecological, gastrointestinal, urinary, or pelvic conditions. This screening cannot determine whether you have endometriosis.';
        nextStepText =
            'Continue tracking your symptoms and consider discussing persistent or bothersome symptoms with a healthcare professional.';
        primaryCta = 'Continue Tracking';
        secondaryCta = 'Discuss With a Doctor';
        break;

      case EndometriosisResultLevel.higher:
        description =
            'Your responses include several symptoms or symptom patterns that can be associated with endometriosis.';
        additionalText =
            'This does not mean that you have endometriosis. Similar symptoms can have other causes, and a qualified healthcare professional is needed to evaluate them.';
        nextStepText =
            'Consider discussing these symptoms with a gynecologist or another qualified healthcare professional.';
        primaryCta = 'Discuss With a Doctor';
        secondaryCta = 'Track My Symptoms';
        break;
    }

    return EndometriosisAssessmentResult(
      rawScore: score,
      resultLevel: level,
      resultTitle: displayTitle,
      description: description,
      additionalText: additionalText,
      nextStepText: nextStepText,
      painCluster: painCluster,
      deepPelvicPainCluster: deepPelvicPainCluster,
      bowelCluster: bowelCluster,
      urinaryCluster: urinaryCluster,
      fertilityClinicalCluster: fertilityClinicalCluster,
      contributingSymptoms: contributingSymptoms,
      highSignalSymptoms: highSignalSymptoms,
      hasMedicalAttentionFlags: hasMedicalAttentionFlags,
      medicalAttentionNotice: medicalAttentionNotice,
      primaryCta: primaryCta,
      secondaryCta: secondaryCta,
      answers: Map<int, int>.from(answers),
      completedAt: DateTime.now(),
    );
  }
}
