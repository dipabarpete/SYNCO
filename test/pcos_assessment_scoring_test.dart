import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/symptoms_assessment/data/pcos_questions_data.dart';
import 'package:hersync/features/symptoms_assessment/models/pcos_result_level.dart';
import 'package:hersync/features/symptoms_assessment/services/pcos_assessment_calculator.dart';
import 'package:hersync/features/symptoms_assessment/services/pcos_assessment_scoring_service.dart';

void main() {
  group('PCOS Assessment Questionnaire Data & Scoring Service Tests', () {
    test('Questionnaire contains exactly 23 questions across 4 sections', () {
      expect(pcosQuestions.length, equals(23));

      for (int i = 0; i < pcosQuestions.length; i++) {
        final q = pcosQuestions[i];
        expect(q.questionNumber, equals(i + 1));
        expect(q.options.length, equals(q.scores.length));
        expect(q.section.isNotEmpty, isTrue);
        expect(q.question.isNotEmpty, isTrue);
      }

      // Verify Q23 is non-scored
      final q23 = pcosQuestions.last;
      expect(q23.id, equals('q23'));
      expect(q23.isScored, isFalse);
      expect(q23.scores.every((s) => s == 0), isTrue);
    });

    test('Score 0-6 returns PcosResultLevel.low ("Low indication of PCOS-associated features")', () {
      final answers = <int, int>{for (int i = 0; i < 23; i++) i: 0};
      final result = PcosAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(0));
      expect(result.resultLevel, equals(PcosResultLevel.low));
      expect(result.categoryTitle, equals('Low indication of PCOS-associated features'));
      expect(result.primaryCta, equals('Continue Tracking'));
      expect(result.secondaryCta, equals('Learn About PCOS'));
    });

    test('Score 7-12 returns PcosResultLevel.moderate ("Moderate indication of PCOS-associated features")', () {
      final answers = <int, int>{
        1: 2, // 2 pts (Q2 > 35 days)
        2: 2, // 2 pts (Q3 Frequently)
        3: 1, // 2 pts (Q4 90+ days)
        7: 2, // 2 pts (Q8 moderate facial hair)
      };
      final result = PcosAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(8));
      expect(result.resultLevel, equals(PcosResultLevel.moderate));
      expect(result.categoryTitle, equals('Moderate indication of PCOS-associated features'));
      expect(result.primaryCta, equals('Continue Tracking'));
      expect(result.secondaryCta, equals('Learn About PCOS'));
    });

    test('Score 13+ returns PcosResultLevel.higher ("Higher indication of PCOS-associated features")', () {
      final answers = <int, int>{
        1: 2, // Q2: 2 pts
        2: 2, // Q3: 2 pts
        3: 1, // Q4: 2 pts
        7: 2, // Q8: 2 pts
        9: 3, // Q10: 2 pts
        10: 3, // Q11: 2 pts
        14: 1, // Q15: 2 pts
      };
      final result = PcosAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(14));
      expect(result.resultLevel, equals(PcosResultLevel.higher));
      expect(result.categoryTitle, equals('Higher indication of PCOS-associated features'));
      expect(result.primaryCta, equals('Discuss With a Doctor'));
    });

    test('Q23 answer MUST NOT contribute to score', () {
      final answersWithoutQ23 = <int, int>{1: 2, 2: 2};
      final resultWithout = PcosAssessmentScoringService.calculateResult(answersWithoutQ23);

      final answersWithQ23 = <int, int>{1: 2, 2: 2, 22: 1}; // Q23 selected option 1 ("Yes")
      final resultWith = PcosAssessmentScoringService.calculateResult(answersWithQ23);

      expect(resultWith.rawScore, equals(resultWithout.rawScore));
    });

    test('Symptom group category statuses and high-signal symptoms evaluate correctly', () {
      final answers = <int, int>{
        1: 2, // Q2 > 35 days -> Menstrual cluster & high signal
        3: 1, // Q4 90+ days -> Menstrual & high signal & special case notice
        7: 2, // Q8 moderate facial hair -> Androgen cluster & high signal
        14: 1, // Q15 insulin resistance -> Metabolic cluster
        17: 1, // Q18 doctor suspected PCOS -> Clinical evidence cluster
      };

      final result = PcosAssessmentCalculator.calculateResult(answers);

      expect(result.menstrualCluster, isTrue);
      expect(result.androgenCluster, isTrue);
      expect(result.metabolicCluster, isTrue);
      expect(result.clinicalEvidenceCluster, isTrue);

      expect(result.menstrualStatus, equals('Several associated features'));
      expect(result.androgenStatus, equals('Several associated features'));
      expect(result.metabolicStatus, equals('Several associated features'));
      expect(result.clinicalEvidenceStatus, equals('Previous clinical findings reported'));

      expect(result.hasSpecialCaseNotice, isTrue);
      expect(result.highSignalSymptoms, contains('Your periods are very irregular or widely spaced.'));
      expect(result.highSignalSymptoms, contains('You reported going 90 days or more without a period when not pregnant.'));
      expect(result.highSignalSymptoms, contains('You reported increased facial or body hair.'));
    });
  });
}
