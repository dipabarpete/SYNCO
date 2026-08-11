import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/symptoms_assessment/data/fibroids_questions_data.dart';
import 'package:hersync/features/symptoms_assessment/models/fibroids_result_level.dart';
import 'package:hersync/features/symptoms_assessment/services/fibroids_assessment_scoring_service.dart';

void main() {
  group('Uterine Fibroids Assessment Questionnaire Data & Scoring Tests', () {
    test('Questionnaire contains exactly 24 questions across 7 sections', () {
      expect(fibroidsQuestions.length, equals(24));

      final sections = fibroidsQuestions.map((q) => q.section).toSet();
      expect(sections.length, equals(7));

      for (int i = 0; i < fibroidsQuestions.length; i++) {
        final q = fibroidsQuestions[i];
        expect(q.questionNumber, equals(i + 1));
        expect(q.options.length, equals(q.scores.length));
        expect(q.section.isNotEmpty, isTrue);
        expect(q.question.isNotEmpty, isTrue);
        expect(q.id, startsWith('fib_q'));
      }

      // Verify Q20 is contextual (non-scored, contributes zero)
      final q20 = fibroidsQuestions[19];
      expect(q20.id, equals('fib_q20'));
      expect(q20.isScored, isFalse);
      expect(q20.scores.every((s) => s == 0), isTrue);

      // Verify zero-score "Not sure"/"Not applicable"/"Prefer not to say"
      // options across questions where they exist.
      final q5 = fibroidsQuestions[4];
      expect(q5.options.last, equals('Not sure'));
      expect(q5.scores.last, equals(0));

      final q12 = fibroidsQuestions[11];
      expect(q12.options.last, equals('Not sure'));
      expect(q12.scores.last, equals(0));

      final q19 = fibroidsQuestions[18];
      expect(q19.scores.last, equals(0)); // Prefer not to say
      expect(q19.scores[2], equals(0)); // Not sure

      final q21 = fibroidsQuestions[20];
      expect(q21.scores[2], equals(0)); // Not applicable
      expect(q21.scores[3], equals(0)); // Prefer not to say

      final q24 = fibroidsQuestions[23];
      expect(q24.scores[2], equals(0)); // Not sure
      expect(q24.scores[3], equals(0)); // Never had an evaluation
    });

    test('Score 0-8 returns UterineFibroidResultLevel.low', () {
      final answers = <int, int>{for (int i = 0; i < 24; i++) i: 0};
      final result =
          UterineFibroidAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(0));
      expect(result.resultLevel, equals(UterineFibroidResultLevel.low));
      expect(
        result.resultTitle,
        equals('Low indication of uterine-fibroid-associated features'),
      );
      expect(result.primaryCta, equals('Continue Tracking'));
      expect(result.secondaryCta, equals('Learn About Fibroids'));
    });

    test('Score 9-17 returns UterineFibroidResultLevel.moderate', () {
      final answers = <int, int>{
        0: 2, // Q1 Heavy (2 pts)
        2: 2, // Q3 Frequently (2 pts)
        8: 2, // Q9 Frequently (2 pts)
        12: 2, // Q13 Frequently (2 pts)
        16: 2, // Q17 Frequently (1 pt)
      }; // Total = 9 pts
      final result =
          UterineFibroidAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(9));
      expect(result.resultLevel, equals(UterineFibroidResultLevel.moderate));
      expect(
        result.resultTitle,
        equals('Moderate indication of uterine-fibroid-associated features'),
      );
      expect(result.primaryCta, equals('Continue Tracking'));
      expect(result.secondaryCta, equals('Discuss With a Doctor'));
    });

    test('Score 18+ returns UterineFibroidResultLevel.higher', () {
      final answers = <int, int>{
        0: 3, // Q1 Very heavy (3 pts)
        2: 3, // Q3 Almost every period (3 pts)
        3: 3, // Q4 Almost every period (3 pts)
        8: 3, // Q9 Almost constantly (3 pts)
        9: 3, // Q10 Almost constantly (2 pts)
        18: 1, // Q19 Yes (2 pts)
        22: 1, // Q23 Yes (3 pts)
      }; // Total = 19 pts
      final result =
          UterineFibroidAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(19));
      expect(result.resultLevel, equals(UterineFibroidResultLevel.higher));
      expect(
        result.resultTitle,
        equals('Higher indication of uterine-fibroid-associated features'),
      );
      expect(result.primaryCta, equals('Discuss With a Doctor'));
      expect(result.secondaryCta, equals('Track My Symptoms'));
    });

    test('Q20 contextual, Not sure / N/A options all contribute zero', () {
      final answers = <int, int>{
        4: 4, // Q5 Not sure (0)
        11: 3, // Q12 Not sure (0)
        18: 3, // Q19 Prefer not to say (0)
        19: 1, // Q20 Yes - contextual (0)
        20: 2, // Q21 Not applicable (0)
        23: 3, // Q24 Never had an evaluation (0)
      };
      final result =
          UterineFibroidAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(0));
      expect(result.resultLevel, equals(UterineFibroidResultLevel.low));
      expect(result.heavyBleedingCluster, isFalse);
      expect(result.pelvicPressureCluster, isFalse);
      expect(result.bladderBowelCluster, isFalse);
      expect(result.anemiaAssociatedCluster, isFalse);
      expect(result.fertilityClinicalCluster, isFalse);
      expect(result.hasMedicalAttentionFlags, isFalse);
    });

    test('All five feature clusters evaluate correctly', () {
      final heavyBleeding = <int, int>{
        0: 2, // Q1 Heavy
        2: 2, // Q3 Frequently changes products
        3: 2, // Q4 Frequently soaks through
        4: 2, // Q5 Frequent clots
        5: 2, // Q6 Noticeably heavier over time
      };
      final heavyResult =
          UterineFibroidAssessmentScoringService.calculateResult(heavyBleeding);
      expect(heavyResult.heavyBleedingCluster, isTrue);
      expect(heavyResult.pelvicPressureCluster, isFalse);
      expect(heavyResult.bladderBowelCluster, isFalse);
      expect(heavyResult.anemiaAssociatedCluster, isFalse);
      expect(heavyResult.fertilityClinicalCluster, isFalse);

      final pelvic = <int, int>{8: 1}; // Q9 Occasionally
      final pelvicResult =
          UterineFibroidAssessmentScoringService.calculateResult(pelvic);
      expect(pelvicResult.pelvicPressureCluster, isTrue);
      expect(pelvicResult.heavyBleedingCluster, isFalse);

      final bladderBowel = <int, int>{12: 1}; // Q13 Occasionally
      final bladderBowelResult =
          UterineFibroidAssessmentScoringService.calculateResult(bladderBowel);
      expect(bladderBowelResult.bladderBowelCluster, isTrue);
      expect(bladderBowelResult.pelvicPressureCluster, isFalse);

      final anemia = <int, int>{16: 2}; // Q17 Frequently
      final anemiaResult =
          UterineFibroidAssessmentScoringService.calculateResult(anemia);
      expect(anemiaResult.anemiaAssociatedCluster, isTrue);
      expect(anemiaResult.bladderBowelCluster, isFalse);

      final fertility = <int, int>{
        20: 1, // Q21 Yes - difficulty becoming pregnant
        22: 1, // Q23 Yes - told of fibroids
        23: 1, // Q24 Yes - imaging finding
      };
      final fertilityResult =
          UterineFibroidAssessmentScoringService.calculateResult(fertility);
      expect(fertilityResult.fertilityClinicalCluster, isTrue);
      expect(fertilityResult.anemiaAssociatedCluster, isFalse);
    });

    test('Heavy bleeding medical-attention flag triggers correctly', () {
      // Very heavy bleeding
      final veryHeavy = <int, int>{0: 3};
      final veryHeavyResult =
          UterineFibroidAssessmentScoringService.calculateResult(veryHeavy);
      expect(veryHeavyResult.hasHeavyBleedingFlag, isTrue);
      expect(veryHeavyResult.medicalAttentionFlags.first.id, equals('heavyBleeding'));
      expect(
        veryHeavyResult.medicalAttentionFlags.first.message,
        contains('seek medical care promptly'),
      );

      // Frequent soaking through products/clothes
      final soaking = <int, int>{3: 2};
      final soakingResult =
          UterineFibroidAssessmentScoringService.calculateResult(soaking);
      expect(soakingResult.hasHeavyBleedingFlag, isTrue);

      // Significant dizziness/weakness associated with bleeding
      final dizzy = <int, int>{17: 2};
      final dizzyResult =
          UterineFibroidAssessmentScoringService.calculateResult(dizzy);
      expect(dizzyResult.hasHeavyBleedingFlag, isTrue);

      // Moderate bleeding alone does not trigger the flag
      final moderate = <int, int>{0: 2};
      final moderateResult =
          UterineFibroidAssessmentScoringService.calculateResult(moderate);
      expect(moderateResult.hasHeavyBleedingFlag, isFalse);
    });

    test('Anemia-related medical-attention flag triggers correctly', () {
      // Q19 = Yes
      final toldAnemia = <int, int>{18: 1};
      final toldAnemiaResult =
          UterineFibroidAssessmentScoringService.calculateResult(toldAnemia);
      expect(toldAnemiaResult.hasAnemiaFlag, isTrue);
      expect(
        toldAnemiaResult.medicalAttentionFlags.any((f) => f.id == 'anemia'),
        isTrue,
      );

      // Frequent dizziness/weakness
      final frequentDizzy = <int, int>{17: 2};
      final frequentDizzyResult =
          UterineFibroidAssessmentScoringService.calculateResult(frequentDizzy);
      expect(frequentDizzyResult.hasAnemiaFlag, isTrue);

      // Frequent fatigue combined with heavy bleeding
      final combo = <int, int>{16: 2, 0: 2};
      final comboResult =
          UterineFibroidAssessmentScoringService.calculateResult(combo);
      expect(comboResult.hasAnemiaFlag, isTrue);
      expect(
        comboResult.medicalAttentionFlags.any(
          (f) => f.message.contains('blood testing'),
        ),
        isTrue,
      );

      // Occasional fatigue alone does not trigger the flag
      final occasionalFatigue = <int, int>{16: 1};
      final occasionalResult =
          UterineFibroidAssessmentScoringService.calculateResult(occasionalFatigue);
      expect(occasionalResult.hasAnemiaFlag, isFalse);
    });

    test('Existing fibroid medical-attention flag triggers correctly', () {
      // Q23 = Yes (told of fibroids)
      final diagnosed = <int, int>{22: 1};
      final diagnosedResult =
          UterineFibroidAssessmentScoringService.calculateResult(diagnosed);
      expect(diagnosedResult.hasExistingFibroidFlag, isTrue);
      expect(
        diagnosedResult.medicalAttentionFlags.any(
          (f) => f.id == 'existingFibroid',
        ),
        isTrue,
      );

      // Q24 = Yes (imaging finding)
      final imaged = <int, int>{23: 1};
      final imagedResult =
          UterineFibroidAssessmentScoringService.calculateResult(imaged);
      expect(imagedResult.hasExistingFibroidFlag, isTrue);

      // Existing fibroid history is kept separate from the screening score
      final onlyHistory = <int, int>{22: 1, 23: 1};
      final onlyHistoryResult =
          UterineFibroidAssessmentScoringService.calculateResult(onlyHistory);
      expect(onlyHistoryResult.hasExistingFibroidFlag, isTrue);
      expect(onlyHistoryResult.rawScore, equals(6)); // 3 + 3 from Q23/Q24
    });

    test('Dynamic symptom summary contains only reported symptoms', () {
      final answers = <int, int>{
        0: 2, // Q1 Heavy
        8: 1, // Q9 Pelvic pressure occasionally
        20: 1, // Q21 Difficulty becoming pregnant
      };
      final result =
          UterineFibroidAssessmentScoringService.calculateResult(answers);

      expect(
        result.contributingSymptoms,
        contains('Heavy or very heavy menstrual bleeding'),
      );
      expect(result.contributingSymptoms, contains('Pelvic pressure or fullness'));
      expect(result.contributingSymptoms, contains('Difficulty becoming pregnant'));
      expect(
        result.contributingSymptoms,
        isNot(contains('Frequent urination or bladder pressure')),
      );
      expect(
        result.contributingSymptoms,
        isNot(contains('Previous fibroid-related medical evaluation')),
      );
    });

    test('High-signal symptoms (worth discussing) evaluate correctly', () {
      final answers = <int, int>{
        0: 3, // Q1 Very heavy
        4: 2, // Q5 Frequent clots
        8: 2, // Q9 Pelvic pressure frequently
        18: 1, // Q19 Previous anemia
      };
      final result =
          UterineFibroidAssessmentScoringService.calculateResult(answers);

      expect(result.highSignalSymptoms, contains('Very heavy menstrual bleeding'));
      expect(result.highSignalSymptoms, contains('Frequent or larger blood clots'));
      expect(result.highSignalSymptoms, contains('Pelvic pressure/fullness'));
      expect(result.highSignalSymptoms, contains('Previous anemia/low iron'));
      expect(
        result.highSignalSymptoms,
        isNot(contains('Persistent pelvic pain')),
      );
    });

    test('No percentage probability or diagnostic language is produced', () {
      final answers = <int, int>{for (int i = 0; i < 24; i++) i: 3};
      final result = UterineFibroidAssessmentScoringService.calculateResult(answers);

      final allText = [
        result.resultTitle,
        result.description,
        result.additionalText,
        result.nextStepText,
        ...result.contributingSymptoms,
        ...result.highSignalSymptoms,
        ...result.medicalAttentionFlags.map((f) => f.message),
      ].join(' ').toLowerCase();

      // No diagnostic assertions, no percentage probabilities
      expect(allText, isNot(contains('fibroids detected')));
      expect(allText, isNot(contains('fibroids confirmed')));
      expect(allText, isNot(contains('probably have fibroids')));
      expect(allText, isNot(contains('definitely have fibroids')));
      expect(allText, isNot(contains('high chance of fibroids')));
      expect(allText, isNot(contains('%')));
      expect(result.resultTitle, contains('indication of uterine-fibroid-associated features'));
    });
  });
}