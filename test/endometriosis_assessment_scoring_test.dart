import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/symptoms_assessment/data/endometriosis_questions_data.dart';
import 'package:hersync/features/symptoms_assessment/models/endometriosis_result_level.dart';
import 'package:hersync/features/symptoms_assessment/services/endometriosis_assessment_scoring_service.dart';

void main() {
  group('Endometriosis Assessment Questionnaire Data & Scoring Tests', () {
    test('Questionnaire contains exactly 24 questions across 7 sections', () {
      expect(endometriosisQuestions.length, equals(24));

      for (int i = 0; i < endometriosisQuestions.length; i++) {
        final q = endometriosisQuestions[i];
        expect(q.questionNumber, equals(i + 1));
        expect(q.options.length, equals(q.scores.length));
        expect(q.section.isNotEmpty, isTrue);
        expect(q.question.isNotEmpty, isTrue);
      }

      // Verify Q21 is contextual (non-scored)
      final q21 = endometriosisQuestions[20];
      expect(q21.id, equals('endo_q21'));
      expect(q21.isScored, isFalse);
      expect(q21.scores.every((s) => s == 0), isTrue);

      // Verify Q10 and Q11 N/A option scores are 0
      final q10 = endometriosisQuestions[9];
      expect(q10.options.last, equals('Not applicable'));
      expect(q10.scores.last, equals(0));

      final q11 = endometriosisQuestions[10];
      expect(q11.options.last, equals('Not applicable'));
      expect(q11.scores.last, equals(0));
    });

    test('Score 0-9 returns EndometriosisResultLevel.low', () {
      final answers = <int, int>{for (int i = 0; i < 24; i++) i: 0};
      final result = EndometriosisAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(0));
      expect(result.resultLevel, equals(EndometriosisResultLevel.low));
      expect(result.resultTitle, equals('Low indication of endometriosis-associated features'));
      expect(result.primaryCta, equals('Continue Tracking'));
      expect(result.secondaryCta, equals('Learn About Endometriosis'));
    });

    test('Score 10-19 returns EndometriosisResultLevel.moderate', () {
      final answers = <int, int>{
        0: 3, // Q1 Severe pain (3 pts)
        1: 2, // Q2 Frequently (2 pts)
        2: 2, // Q3 Most periods (2 pts)
        5: 2, // Q6 Frequently (2 pts)
        6: 2, // Q7 Often (2 pts)
      }; // Total = 11 pts
      final result = EndometriosisAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(11));
      expect(result.resultLevel, equals(EndometriosisResultLevel.moderate));
      expect(result.resultTitle, equals('Moderate indication of endometriosis-associated features'));
      expect(result.primaryCta, equals('Continue Tracking'));
      expect(result.secondaryCta, equals('Discuss With a Doctor'));
    });

    test('Score 20+ returns EndometriosisResultLevel.higher', () {
      final answers = <int, int>{
        0: 4, // Q1 Disabling pain (3 pts)
        1: 3, // Q2 Almost every period (3 pts)
        2: 3, // Q3 Multiple times (2 pts)
        5: 3, // Q6 Constantly (3 pts)
        9: 3, // Q10 Deep pain sex (3 pts)
        11: 4, // Q12 Bowel pain (3 pts)
        14: 1, // Q15 Blood in stool (3 pts)
      }; // Total = 20 pts
      final result = EndometriosisAssessmentScoringService.calculateResult(answers);

      expect(result.rawScore, equals(20));
      expect(result.resultLevel, equals(EndometriosisResultLevel.higher));
      expect(result.resultTitle, equals('Higher indication of endometriosis-associated features'));
      expect(result.primaryCta, equals('Discuss With a Doctor'));
      expect(result.secondaryCta, equals('Track My Symptoms'));
    });

    test('Symptom Clusters and Urgent Medical-Attention Flags evaluate correctly', () {
      final answers = <int, int>{
        0: 3, // Q1 Severe pain -> Pain cluster & Medical attention flag
        9: 2, // Q10 Deep pain sex -> Deep pelvic pain cluster
        14: 1, // Q15 Blood in stool -> Bowel cluster & Medical attention flag
        16: 1, // Q17 Blood in urine -> Urinary cluster & Medical attention flag
        22: 1, // Q23 Previous diagnosis -> Fertility/Clinical cluster
      };

      final result = EndometriosisAssessmentScoringService.calculateResult(answers);

      expect(result.painCluster, isTrue);
      expect(result.deepPelvicPainCluster, isTrue);
      expect(result.bowelCluster, isTrue);
      expect(result.urinaryCluster, isTrue);
      expect(result.fertilityClinicalCluster, isTrue);

      expect(result.hasMedicalAttentionFlags, isTrue);
      expect(result.medicalAttentionNotice, contains('Some of the symptoms you reported may need medical evaluation'));
    });
  });
}
