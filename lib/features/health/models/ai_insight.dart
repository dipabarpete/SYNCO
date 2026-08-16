/// AI pattern detection insight model.
///
/// Insights are always derived from the user's own stored health data by
/// [AiPatternService]. They use observational language and are never
/// diagnostic or prescriptive about medical treatment.
///
/// [suggestion] carries a supportive, non-diagnostic "How you can improve"
/// tip derived from the detected pattern.
library;

enum InsightKind {
  sleep,
  activity,
  hydration,
  nutrition,
  sugarCravings,
  mentalWellness,
  mood,
  weight,
  foodTags,
  lifestyle;

  String get label => switch (this) {
        sleep => 'Sleep',
        activity => 'Activity',
        hydration => 'Hydration',
        nutrition => 'Nutrition',
        sugarCravings => 'Sugar Cravings',
        mentalWellness => 'Mental Wellness',
        mood => 'Mood',
        weight => 'Weight',
        foodTags => 'Food Tags',
        lifestyle => 'Lifestyle',
      };
}

enum InsightTrend { up, down, neutral }

enum InsightCategory {
  observation,
  pattern,
  suggestion;

  String get label => switch (this) {
        observation => 'Observation',
        pattern => 'Possible pattern',
        suggestion => 'Suggestion',
      };
}

class AiInsight {
  final String id;
  final String title;
  final String summary;
  final String? detail;
  final String periodLabel; // e.g. "This week", "This month"
  final String basisLabel; // e.g. "Based on 6 days of data"
  final InsightKind kind;
  final InsightTrend trend;
  final InsightCategory category;
  final String? suggestion;

  const AiInsight({
    required this.id,
    required this.title,
    required this.summary,
    this.detail,
    required this.periodLabel,
    required this.basisLabel,
    required this.kind,
    this.trend = InsightTrend.neutral,
    this.category = InsightCategory.observation,
    this.suggestion,
  });

  /// Used internally to rank which insights to show when there are many.
  int get strength => (detail?.length ?? 0) + basisLabel.length;
}