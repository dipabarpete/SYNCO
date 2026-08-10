import '../models/pcos_assessment_result.dart';
import 'pcos_assessment_scoring_service.dart';

class PcosAssessmentCalculator {
  static PcosAssessmentResult calculateResult(Map<int, int> answers) {
    return PcosAssessmentScoringService.calculateResult(answers);
  }
}
