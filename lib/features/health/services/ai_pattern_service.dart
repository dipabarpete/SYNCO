import '../models/ai_insight.dart';
import '../models/health_entries.dart';
import 'health_analytics.dart';

/// Data-driven AI pattern detection.
///
/// Insights are generated from the user's own stored health data. Each rule
/// aggregates entries over a week or month, looks for a meaningful numeric
/// signal and only then produces an insight. No insights are generated when
/// there is not enough data, and language is always observational rather than
/// diagnostic.
class AiPatternService {
  const AiPatternService();

  static const int _minDataDays = 3;
  static const int _maxInsights = 6;

  /// Detects insights from [all] entries. Returns an empty list when there is
  /// insufficient data so the UI can show its "keep tracking" empty state.
  List<AiInsight> detect({
    required List<HealthEntry> all,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    if (HealthAnalytics.dataDaysLastDays(all, today, days: 30) < 1) {
      return const [];
    }

    final insights = <AiInsight>[
      ..._sleepWellnessInsights(all, today),
      ..._sleepTrendInsight(all, today),
      ..._sugarCravingInsight(all, today),
      ..._stepsTrendInsight(all, today),
      ..._hydrationTrendInsight(all, today),
      ..._nutritionTagInsight(all, today),
      ..._monthlySleepQualityInsight(all, today),
      ..._moodInsight(all, today),
      ..._weightInsight(all, today),
      ..._supplementConsistencyInsight(all, today),
    ];

    insights.sort((a, b) => b.strength.compareTo(a.strength));
    return insights.take(_maxInsights).toList();
  }

  static String _fmt1(double v) => v.toStringAsFixed(1);

  static String _kg(double v) => v.toStringAsFixed(1);

  // -------------------------------------------------------------------------
  // SLEEP <-> WELLNESS correlation (same-day)
  // -------------------------------------------------------------------------

  List<AiInsight> _sleepWellnessInsights(
    List<HealthEntry> all,
    DateTime today,
  ) {
    final start = HealthAnalytics.addDays(today, -6);
    final sleeps = all
        .whereType<SleepEntry>()
        .where((e) => !e.date.isBefore(start) && !e.date.isAfter(today))
        .toList();
    final wellnessByDay = <String, MentalWellnessEntry>{
      for (final w in all.whereType<MentalWellnessEntry>())
        healthDateKey(w.date): w,
    };

    final short = <int>[];
    final long = <int>[];
    double shortEnergySum = 0, longEnergySum = 0;
    double shortStressSum = 0, longStressSum = 0;

    for (final s in sleeps) {
      final w = wellnessByDay[healthDateKey(s.date)];
      if (w == null) continue;
      if (s.durationMinutes < 7 * 60) {
        short.add(s.durationMinutes);
        shortEnergySum += w.energyLevel;
        shortStressSum += w.stressLevel;
      } else {
        long.add(s.durationMinutes);
        longEnergySum += w.energyLevel;
        longStressSum += w.stressLevel;
      }
    }

    final totalDays = short.length + long.length;
    if (short.length < 2 || long.length < 2) return const [];

    final insights = <AiInsight>[];
    final shortEnergyAvg = shortEnergySum / short.length;
    final longEnergyAvg = longEnergySum / long.length;
    if (longEnergyAvg - shortEnergyAvg >= 0.5) {
      insights.add(AiInsight(
        id: 'sleep-energy',
        title: 'Sleep & Energy',
        summary:
            'Your energy was lower on the days when your sleep duration was shorter.',
        detail:
            'Your data shows that on days with under 7 hours of sleep, your '
            'average energy was ${_fmt1(shortEnergyAvg)}/5, compared with '
            '${_fmt1(longEnergyAvg)}/5 on days with more sleep. This is an '
            'observation of your own data, not a diagnosis.',
        periodLabel: 'This week',
        basisLabel: 'Based on $totalDays days of data',
        kind: InsightKind.sleep,
        category: InsightCategory.pattern,
      ));
    }

    final shortStressAvg = shortStressSum / short.length;
    final longStressAvg = longStressSum / long.length;
    if (shortStressAvg - longStressAvg >= 1.0) {
      insights.add(AiInsight(
        id: 'sleep-stress',
        title: 'Sleep & Stress',
        summary:
            'Your stress was higher on the days when you logged less sleep.',
        detail:
            'Your data shows that on days with under 7 hours of sleep, average '
            'stress was ${_fmt1(shortStressAvg)}/5 versus '
            '${_fmt1(longStressAvg)}/5 on longer-sleep days. Correlation does '
            'not imply causation - it may help to observe this over time.',
        periodLabel: 'This week',
        basisLabel: 'Based on $totalDays days of data',
        kind: InsightKind.sleep,
        category: InsightCategory.pattern,
      ));
    }

    return insights;
  }

  // -------------------------------------------------------------------------
  // SLEEP DURATION trend (week over week)
  // -------------------------------------------------------------------------

  List<AiInsight> _sleepTrendInsight(List<HealthEntry> all, DateTime today) {
    final thisW = HealthAnalytics.thisWeek(all, today);
    final lastW = HealthAnalytics.lastWeek(all, today);
    final avgThis = thisW.avgSleepMinutes;
    final avgLast = lastW.avgSleepMinutes;
    if (avgThis == null || avgLast == null) return const [];

    final diffMinutes = avgThis - avgLast;
    if (diffMinutes.abs() < 30) return const [];

    final increased = diffMinutes > 0;
    return [
      AiInsight(
        id: 'sleep-trend',
        title: 'Sleep Duration Trend',
        summary:
            'Your average sleep ${increased ? 'increased' : 'decreased'} from '
            '${formatDurationMinutes(avgLast.round())} last week to '
            '${formatDurationMinutes(avgThis.round())} this week.',
        detail:
            'Your data shows your weekly average sleep changed by '
            '${diffMinutes.abs().round()} minutes compared with the week '
            'before. Continue tracking to see how this aligns with your energy '
            'and stress.',
        periodLabel: 'This week',
        basisLabel: 'Based on ${thisW.daysWithData} days of data',
        kind: InsightKind.sleep,
        trend: increased ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // SUGAR CRAVINGS frequency
  // -------------------------------------------------------------------------

  List<AiInsight> _sugarCravingInsight(List<HealthEntry> all, DateTime today) {
    final thisW = HealthAnalytics.thisWeek(all, today);
    if (thisW.cravingDays < 1) return const [];

    final high = thisW.cravingLevelCounts['High'] ?? 0;
    final summary = high > 0
        ? 'You logged higher sugar cravings on ${thisW.cravingDays} of the '
            'last 7 days.'
        : 'You logged sugar cravings on ${thisW.cravingDays} of the last 7 '
            'days.';

    return [
      AiInsight(
        id: 'sugar-cravings',
        title: 'Sugar Cravings',
        summary: summary,
        detail:
            'Across the last 7 days you logged ${thisW.cravingCount} craving'
            '${thisW.cravingCount == 1 ? '' : 's'}'
            '${high > 0 ? ', $high of them marked as high intensity' : ''}. '
            'You may want to observe what situations or foods tend to '
            'surround them.',
        periodLabel: 'This week',
        basisLabel: 'Based on ${thisW.cravingDays} days of data',
        kind: InsightKind.sugarCravings,
        category: InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // ACTIVITY trend
  // -------------------------------------------------------------------------

  List<AiInsight> _stepsTrendInsight(List<HealthEntry> all, DateTime today) {
    final thisW = HealthAnalytics.thisWeek(all, today);
    final lastW = HealthAnalytics.lastWeek(all, today);
    final avgThis = thisW.avgSteps;
    final avgLast = lastW.avgSteps;
    if (avgThis == null || avgLast == null || avgLast == 0) return const [];

    final pct = ((avgThis - avgLast) / avgLast) * 100;
    if (pct.abs() < 10) return const [];

    final increased = pct > 0;
    return [
      AiInsight(
        id: 'steps-trend',
        title: 'Activity Trend',
        summary:
            'Your average step count ${increased ? 'increased' : 'decreased'} '
            'by ${pct.abs().round()}% this week compared with last week.',
        detail:
            'Your data shows an average of ${avgThis.round().toString()} steps '
            'a day this week versus ${avgLast.round().toString()} last week.',
        periodLabel: 'This week',
        basisLabel: 'Based on ${thisW.daysWithData} days of data',
        kind: InsightKind.activity,
        trend: increased ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // HYDRATION trend
  // -------------------------------------------------------------------------

  List<AiInsight> _hydrationTrendInsight(List<HealthEntry> all, DateTime today) {
    final thisW = HealthAnalytics.thisWeek(all, today);
    final lastW = HealthAnalytics.lastWeek(all, today);
    final avgThis = thisW.avgWaterFlOz;
    final avgLast = lastW.avgWaterFlOz;
    if (avgThis == null || avgLast == null || avgLast == 0) return const [];

    final pct = ((avgThis - avgLast) / avgLast) * 100;
    if (pct.abs() < 15) return const [];

    final increased = pct > 0;
    final cupsThis = avgThis / 8;
    return [
      AiInsight(
        id: 'hydration-trend',
        title: 'Hydration Trend',
        summary:
            'Your average water intake ${increased ? 'increased' : 'decreased'} '
            'by ${pct.abs().round()}% compared with last week.',
        detail:
            'Your data shows an average of ${_fmt1(cupsThis)} cups of water a '
            'day this week. Staying hydrated may support energy and focus.',
        periodLabel: 'This week',
        basisLabel: 'Based on ${thisW.daysWithData} days of data',
        kind: InsightKind.hydration,
        trend: increased ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // FOOD TAGS pattern
  // -------------------------------------------------------------------------

  List<AiInsight> _nutritionTagInsight(List<HealthEntry> all, DateTime today) {
    final thisW = HealthAnalytics.thisWeek(all, today);

    const riskyTags = [
      'Processed Food',
      'Sugar',
      'Fried',
      'Caffeine',
      'Alcohol',
    ];
    String? topTag;
    var topCount = 0;
    for (final tag in riskyTags) {
      final count = thisW.foodTagFrequency[tag] ?? 0;
      if (count > topCount) {
        topCount = count;
        topTag = tag;
      }
    }
    if (topTag == null || topCount < 1) return const [];

    final suggestsFollowUp = topTag == 'Processed Food' || topTag == 'Alcohol';
    return [
      AiInsight(
        id: 'food-tag-$topTag',
        title: 'Nutrition & Tags',
        summary: suggestsFollowUp
            ? 'You logged several meals tagged \'$topTag\' this week. You '
                'may want to explore whether this pattern coincides with any '
                'symptoms or changes you track.'
            : 'You logged meals tagged \'$topTag\' $topCount '
                '${topCount == 1 ? 'time' : 'times'} this week.',
        detail: suggestsFollowUp
            ? 'Consider discussing this with your healthcare professional if '
                'the pattern continues or concerns you. This is an '
                'observation of your logged data, not a diagnosis.'
            : 'You may want to observe how these meals make you feel over '
                'time. This is based on your own food logs only.',
        periodLabel: 'This week',
        basisLabel: 'Based on $topCount logged meals',
        kind: InsightKind.nutrition,
        category: suggestsFollowUp
            ? InsightCategory.suggestion
            : InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // MONTHLY SLEEP QUALITY distribution
  // -------------------------------------------------------------------------

  List<AiInsight> _monthlySleepQualityInsight(
    List<HealthEntry> all,
    DateTime today,
  ) {
    final thisM = HealthAnalytics.thisMonth(all, today);
    final lastM = HealthAnalytics.lastMonth(all, today);

    final goodThis = thisM.sleepQualityDistribution['Good'] ?? 0;
    final goodLast = lastM.sleepQualityDistribution['Good'] ?? 0;
    final sleepDaysThis = thisM.sleepQualityDistribution.values.fold(
          0,
          (a, b) => a + b,
        );

    if (sleepDaysThis < 2) return const [];

    final String summary;
    if (goodLast > 0 && goodThis > goodLast) {
      summary = 'Your sleep quality was marked as \'Good\' more frequently '
          'this month ($goodThis days) than last month ($goodLast days).';
    } else if (goodThis >= 2) {
      summary = 'Your sleep quality was marked as \'Good\' on $goodThis days '
          'this month.';
    } else {
      return const [];
    }

    return [
      AiInsight(
        id: 'monthly-sleep-quality',
        title: 'Sleep Quality',
        summary: summary,
        detail:
            'Out of $sleepDaysThis logged sleep entries this month, '
            '$goodThis were rated \'Good\'. Mood, energy and stress ratings '
            'alongside these days can help you see what works for you.',
        periodLabel: 'This month',
        basisLabel: 'Based on $sleepDaysThis days of data',
        kind: InsightKind.sleep,
        category: InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // MOOD distribution
  // -------------------------------------------------------------------------

  List<AiInsight> _moodInsight(List<HealthEntry> all, DateTime today) {
    final thisW = HealthAnalytics.thisWeek(all, today);
    if (thisW.moodDistribution.isEmpty) return const [];

    String? topMood;
    var topCount = 0;
    thisW.moodDistribution.forEach((mood, count) {
      if (count > topCount) {
        topMood = mood;
        topCount = count;
      }
    });

    if (topMood == null || topCount < 1) return const [];

    final total = thisW.moodDistribution.values
        .fold(0, (sum, count) => sum + count);
    return [
      AiInsight(
        id: 'mood-week',
        title: 'Mood',
        summary:
            'This week, your mood was most often marked as \'$topMood\' '
            '($topCount of $total days you checked in).',
        detail:
            'Mood can shift with many factors. Looking at how your mood '
            'lines up with sleep, stress and activity across weeks may reveal '
            'patterns that feel supportive to notice.',
        periodLabel: 'This week',
        basisLabel: 'Based on $total daily check-ins',
        kind: InsightKind.mood,
        category: InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // WEIGHT trend (observational only)
  // -------------------------------------------------------------------------

  List<AiInsight> _weightInsight(List<HealthEntry> all, DateTime today) {
    final thisM = HealthAnalytics.thisMonth(all, today);
    final change = thisM.weightChangeKg;
    if (change == null || change.abs() < 0.5) return const [];

    final first = thisM.firstWeight!;
    final last = thisM.lastWeight!;
    final sign = change > 0 ? '+' : '';
    return [
      AiInsight(
        id: 'weight-trend',
        title: 'Weight Trend',
        summary:
            'This month, your weight went from ${_kg(first.weight)} '
            '${first.unit} to ${_kg(last.weight)} ${last.unit} '
            '($sign${_kg(change)} kg).',
        detail:
            'Normal fluctuations in weight are expected. This is simply an '
            'observation of the days you logged; we do not label changes as '
            'good or bad.',
        periodLabel: 'This month',
        basisLabel: 'Based on ${thisM.daysWithData} days of data',
        kind: InsightKind.weight,
        trend: change > 0 ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // SUPPLEMENT consistency
  // -------------------------------------------------------------------------

  List<AiInsight> _supplementConsistencyInsight(
    List<HealthEntry> all,
    DateTime today,
  ) {
    final thisW = HealthAnalytics.thisWeek(all, today);
    if (thisW.supplementDays < 5) return const [];

    return [
      AiInsight(
        id: 'supplement-consistency',
        title: 'Supplement Routine',
        summary:
            'You stayed consistent with your supplements on '
            '${thisW.supplementDays} of the last 7 days.',
        detail:
            'This tracker simply records what you already take. It does not '
            'recommend supplements or dosages.',
        periodLabel: 'This week',
        basisLabel: 'Based on ${thisW.supplementDays} days of data',
        kind: InsightKind.lifestyle,
        category: InsightCategory.observation,
      ),
    ];
  }
}