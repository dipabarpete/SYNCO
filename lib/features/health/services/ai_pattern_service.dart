import '../../../core/services/api_service.dart';
import '../models/ai_insight.dart';

class AiPatternService {
  const AiPatternService();

  Future<List<AiInsight>> detect() async {
    try {
      final response = await ApiService.post('pattern-detection', {});
      final analysis = response['analysis'] as String?;
      
      if (analysis != null && analysis.isNotEmpty) {
        return [
          AiInsight(
            id: 'api-pattern-detection',
            title: 'AI Pattern Analysis',
            summary: 'Insights based on your recent 21-day history.',
            detail: analysis,
            periodLabel: 'Last 21 days',
            basisLabel: 'AI Detection',
            kind: InsightKind.lifestyle,
            category: InsightCategory.pattern,
          )
        ];
      }
      return [];
    } catch (e) {
      return [
        AiInsight(
          id: 'error',
          title: 'Analysis Unavailable',
          summary: 'Could not fetch your AI patterns right now.',
          detail: 'Error: $e',
          periodLabel: 'Now',
          basisLabel: 'System',
          kind: InsightKind.lifestyle,
          category: InsightCategory.observation,
        )
      ];
    }
  }
}