import '../models/ai_insight.dart';
import '../models/health_entries.dart';
import 'health_analytics.dart';

/// Time window used for pattern detection.
enum PatternRange { week, month }

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

  /// Detects insights across both the weekly and monthly windows. Returns an
  /// empty list when there is insufficient data so the UI can show its
  /// "keep tracking" empty state.
  List<AiInsight> detect({
    required List<HealthEntry> all,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    if (HealthAnalytics.dataDaysLastDays(all, today, days: 30) < _minDataDays) {
      return const [];
    }

    final weekThis = HealthAnalytics.thisWeek(all, today);
    final weekLast = HealthAnalytics.lastWeek(all, today);
    final monthThis = HealthAnalytics.thisMonth(all, today);
    final monthLast = HealthAnalytics.lastMonth(all, today);

    final insights = <AiInsight>[
      ..._sleepWellnessInsights(all, today, days: 7, label: 'This week'),
      ..._sleepTrendInsight(
        weekThis,
        weekLast,
        label: 'This week',
        lastLabel: 'last week',
      ),
      ..._sugarCravingInsight(weekThis, label: 'This week', windowDays: 7),
      ..._stepsTrendInsight(
        weekThis,
        weekLast,
        label: 'This week',
        lastLabel: 'last week',
      ),
      ..._hydrationTrendInsight(
        weekThis,
        weekLast,
        label: 'This week',
        lastLabel: 'last week',
      ),
      ..._nutritionTagInsight(weekThis, label: 'This week'),
      ..._sleepQualityInsight(
        monthThis,
        monthLast,
        label: 'This month',
        lastLabel: 'last month',
      ),
      ..._moodInsight(weekThis, label: 'This week'),
      ..._weightInsight(monthThis, label: 'This month'),
      ..._supplementConsistencyInsight(
        weekThis,
        label: 'This week',
        windowDays: 7,
      ),
    ];

    insights.sort((a, b) => b.strength.compareTo(a.strength));
    return insights.take(_maxInsights).toList();
  }

  /// Detects insights using only the data inside a single time [range]
  /// (weekly or monthly). Returns an empty list when there is insufficient
  /// data.
  List<AiInsight> detectPeriod({
    required List<HealthEntry> all,
    required PatternRange range,
    DateTime? now,
  }) {
    final today = now ?? DateTime.now();

    if (HealthAnalytics.dataDaysLastDays(all, today, days: 30) < _minDataDays) {
      return const [];
    }

    final isWeek = range == PatternRange.week;
    final label = isWeek ? 'This week' : 'This month';
    final lastLabel = isWeek ? 'last week' : 'last month';
    final windowDays = isWeek ? 7 : 30;

    final thisP = isWeek
        ? HealthAnalytics.thisWeek(all, today)
        : HealthAnalytics.thisMonth(all, today);
    final lastP = isWeek
        ? HealthAnalytics.lastWeek(all, today)
        : HealthAnalytics.lastMonth(all, today);

    final insights = <AiInsight>[
      ..._sleepWellnessInsights(all, today, days: windowDays, label: label),
      ..._sleepTrendInsight(thisP, lastP, label: label, lastLabel: lastLabel),
      ..._sugarCravingInsight(thisP, label: label, windowDays: windowDays),
      ..._stepsTrendInsight(thisP, lastP, label: label, lastLabel: lastLabel),
      ..._hydrationTrendInsight(
        thisP,
        lastP,
        label: label,
        lastLabel: lastLabel,
      ),
      ..._nutritionTagInsight(thisP, label: label),
      ..._sleepQualityInsight(thisP, lastP, label: label, lastLabel: lastLabel),
      ..._moodInsight(thisP, label: label),
      ..._weightInsight(thisP, label: label),
      ..._supplementConsistencyInsight(
        thisP,
        label: label,
        windowDays: windowDays,
      ),
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
    DateTime today, {
    required int days,
    required String label,
  }) {
    final start = HealthAnalytics.addDays(today, -(days - 1));
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
        periodLabel: label,
        basisLabel: 'Based on $totalDays days of data',
        kind: InsightKind.sleep,
        category: InsightCategory.pattern,
        suggestion:
            'Try keeping a consistent sleep and wake time, then notice if '
            'your energy settles.',
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
        periodLabel: label,
        basisLabel: 'Based on $totalDays days of data',
        kind: InsightKind.sleep,
        category: InsightCategory.pattern,
        suggestion:
            'A calm wind-down routine before bed may help your evenings feel '
            'lighter.',
      ));
    }

    return insights;
  }

  // -------------------------------------------------------------------------
  // SLEEP DURATION trend (period over period)
  // -------------------------------------------------------------------------

  List<AiInsight> _sleepTrendInsight(
    PeriodStats thisP,
    PeriodStats lastP, {
    required String label,
    required String lastLabel,
  }) {
    final avgThis = thisP.avgSleepMinutes;
    final avgLast = lastP.avgSleepMinutes;
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
            '${formatDurationMinutes(avgLast.round())} $lastLabel to '
            '${formatDurationMinutes(avgThis.round())} '
            '${label.toLowerCase()}.',
        detail:
            'Your data shows your ${label.toLowerCase()} average sleep changed '
            'by ${diffMinutes.abs().round()} minutes compared with '
            '$lastLabel. Continue tracking to see how this aligns with your '
            'energy and stress.',
        periodLabel: label,
        basisLabel: 'Based on ${thisP.daysWithData} days of data',
        kind: InsightKind.sleep,
        trend: increased ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
        suggestion: increased
            ? 'Nice momentum - keep your new bedtime rhythm going.'
            : 'Try keeping a consistent sleep and wake time to steady your '
                'rhythm.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // SUGAR CRAVINGS frequency
  // -------------------------------------------------------------------------

  List<AiInsight> _sugarCravingInsight(
    PeriodStats stats, {
    required String label,
    required int windowDays,
  }) {
    if (stats.cravingDays < 1) return const [];

    final isWeek = windowDays == 7;
    final rangeText = isWeek ? 'the last 7 days' : 'this month';
    final high = stats.cravingLevelCounts['High'] ?? 0;
    final summary = high > 0
        ? 'You logged higher sugar cravings on ${stats.cravingDays} of '
            '$rangeText.'
        : 'You logged sugar cravings on ${stats.cravingDays} of $rangeText.';

    return [
      AiInsight(
        id: 'sugar-cravings',
        title: 'Sugar Cravings',
        summary: summary,
        detail:
            'Across $rangeText you logged ${stats.cravingCount} craving'
            '${stats.cravingCount == 1 ? '' : 's'}'
            '${high > 0 ? ', $high of them marked as high intensity' : ''}. '
            'You may want to observe what situations or foods tend to '
            'surround them.',
        periodLabel: label,
        basisLabel: 'Based on ${stats.cravingDays} days of data',
        kind: InsightKind.sugarCravings,
        category: InsightCategory.observation,
        suggestion:
            'Notice what situations surround your cravings, and try a glass '
            'of water or a short walk before deciding.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // ACTIVITY trend
  // -------------------------------------------------------------------------

  List<AiInsight> _stepsTrendInsight(
    PeriodStats thisP,
    PeriodStats lastP, {
    required String label,
    required String lastLabel,
  }) {
    final avgThis = thisP.avgSteps;
    final avgLast = lastP.avgSteps;
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
            'by ${pct.abs().round()}% ${label.toLowerCase()} compared with '
            '$lastLabel.',
        detail:
            'Your data shows an average of ${avgThis.round().toString()} steps '
            'a day ${label.toLowerCase()} versus '
            '${avgLast.round().toString()} $lastLabel.',
        periodLabel: label,
        basisLabel: 'Based on ${thisP.daysWithData} days of data',
        kind: InsightKind.activity,
        trend: increased ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
        suggestion: increased
            ? 'Keep it going - small daily walks add up.'
            : 'Adding regular daily movement may help you stay more active.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // HYDRATION trend
  // -------------------------------------------------------------------------

  List<AiInsight> _hydrationTrendInsight(
    PeriodStats thisP,
    PeriodStats lastP, {
    required String label,
    required String lastLabel,
  }) {
    final avgThis = thisP.avgWaterFlOz;
    final avgLast = lastP.avgWaterFlOz;
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
            'by ${pct.abs().round()}% ${label.toLowerCase()} compared with '
            '$lastLabel.',
        detail:
            'Your data shows an average of ${_fmt1(cupsThis)} cups of water a '
            'day ${label.toLowerCase()}. Staying hydrated may support energy '
            'and focus.',
        periodLabel: label,
        basisLabel: 'Based on ${thisP.daysWithData} days of data',
        kind: InsightKind.hydration,
        trend: increased ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
        suggestion: increased
            ? 'Keep your water nearby to hold this habit.'
            : 'Try keeping a bottle within reach and refilling it at set '
                'times.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // FOOD TAGS pattern
  // -------------------------------------------------------------------------

  List<AiInsight> _nutritionTagInsight(
    PeriodStats stats, {
    required String label,
  }) {
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
      final count = stats.foodTagFrequency[tag] ?? 0;
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
            ? 'You logged several meals tagged \'$topTag\' '
                '${label.toLowerCase()}. You may want to explore whether this '
                'pattern coincides with any symptoms or changes you track.'
            : 'You logged meals tagged \'$topTag\' $topCount '
                '${topCount == 1 ? 'time' : 'times'} '
                '${label.toLowerCase()}.',
        detail: suggestsFollowUp
            ? 'Consider discussing this with your healthcare professional if '
                'the pattern continues or concerns you. This is an '
                'observation of your logged data, not a diagnosis.'
            : 'You may want to observe how these meals make you feel over '
                'time. This is based on your own food logs only.',
        periodLabel: label,
        basisLabel: 'Based on $topCount logged meals',
        kind: InsightKind.nutrition,
        category: suggestsFollowUp
            ? InsightCategory.suggestion
            : InsightCategory.observation,
        suggestion: suggestsFollowUp
            ? 'Consider discussing recurring nutrition patterns with a '
                'qualified professional.'
            : 'Try noticing how meals like these make you feel over the '
                'coming days.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // SLEEP QUALITY distribution
  // -------------------------------------------------------------------------

  List<AiInsight> _sleepQualityInsight(
    PeriodStats thisP,
    PeriodStats lastP, {
    required String label,
    required String lastLabel,
  }) {
    final goodThis = thisP.sleepQualityDistribution['Good'] ?? 0;
    final goodLast = lastP.sleepQualityDistribution['Good'] ?? 0;
    final sleepDaysThis = thisP.sleepQualityDistribution.values.fold(
          0,
          (a, b) => a + b,
        );

    if (sleepDaysThis < 2) return const [];

    final String summary;
    if (goodLast > 0 && goodThis > goodLast) {
      summary = 'Your sleep quality was marked as \'Good\' more frequently '
          '${label.toLowerCase()} ($goodThis days) than $lastLabel '
          '($goodLast days).';
    } else if (goodThis >= 2) {
      summary = 'Your sleep quality was marked as \'Good\' on $goodThis days '
          '${label.toLowerCase()}.';
    } else {
      return const [];
    }

    return [
      AiInsight(
        id: 'monthly-sleep-quality',
        title: 'Sleep Quality',
        summary: summary,
        detail:
            'Out of $sleepDaysThis logged sleep entries '
            '${label.toLowerCase()}, $goodThis were rated \'Good\'. Mood, '
            'energy and stress ratings alongside these days can help you see '
            'what works for you.',
        periodLabel: label,
        basisLabel: 'Based on $sleepDaysThis days of data',
        kind: InsightKind.sleep,
        category: InsightCategory.observation,
        suggestion: goodLast > 0 && goodThis > goodLast
            ? 'Keep your current sleep routine going - it is working for you.'
            : 'Try keeping a consistent sleep and wake time to support '
                'quality.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // MOOD distribution
  // -------------------------------------------------------------------------

  List<AiInsight> _moodInsight(
    PeriodStats stats, {
    required String label,
  }) {
    if (stats.moodDistribution.isEmpty) return const [];

    String? topMood;
    var topCount = 0;
    stats.moodDistribution.forEach((mood, count) {
      if (count > topCount) {
        topMood = mood;
        topCount = count;
      }
    });

    if (topMood == null || topCount < 1) return const [];

    final total = stats.moodDistribution.values
        .fold(0, (sum, count) => sum + count);
    return [
      AiInsight(
        id: 'mood-week',
        title: 'Mood',
        summary:
            '$label, your mood was most often marked as \'$topMood\' '
            '($topCount of $total days you checked in).',
        detail:
            'Mood can shift with many factors. Looking at how your mood '
            'lines up with sleep, stress and activity across weeks may reveal '
            'patterns that feel supportive to notice.',
        periodLabel: label,
        basisLabel: 'Based on $total daily check-ins',
        kind: InsightKind.mood,
        category: InsightCategory.observation,
        suggestion:
            'Try noticing how your sleep, activity and stress line up with '
            'your mood.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // WEIGHT trend (observational only)
  // -------------------------------------------------------------------------

  List<AiInsight> _weightInsight(
    PeriodStats stats, {
    required String label,
  }) {
    final change = stats.weightChangeKg;
    if (change == null || change.abs() < 0.5) return const [];

    final first = stats.firstWeight!;
    final last = stats.lastWeight!;
    final sign = change > 0 ? '+' : '';
    return [
      AiInsight(
        id: 'weight-trend',
        title: 'Weight Trend',
        summary:
            '$label, your weight went from ${_kg(first.weight)} '
            '${first.unit} to ${_kg(last.weight)} ${last.unit} '
            '($sign${_kg(change)} kg).',
        detail:
            'Normal fluctuations in weight are expected. This is simply an '
            'observation of the days you logged; we do not label changes as '
            'good or bad.',
        periodLabel: label,
        basisLabel: 'Based on ${stats.daysWithData} days of data',
        kind: InsightKind.weight,
        trend: change > 0 ? InsightTrend.up : InsightTrend.down,
        category: InsightCategory.observation,
        suggestion:
            'Continue tracking regularly and look at the longer-term trend '
            'rather than single days.',
      ),
    ];
  }

  // -------------------------------------------------------------------------
  // SUPPLEMENT consistency
  // -------------------------------------------------------------------------

  List<AiInsight> _supplementConsistencyInsight(
    PeriodStats stats, {
    required String label,
    required int windowDays,
  }) {
    final minDays = windowDays == 7 ? 5 : 15;
    if (stats.supplementDays < minDays) return const [];

    final summary = windowDays == 7
        ? 'You stayed consistent with your supplements on '
            '${stats.supplementDays} of the last 7 days.'
        : 'You stayed consistent with your supplements on '
            '${stats.supplementDays} days this month.';

    return [
      AiInsight(
        id: 'supplement-consistency',
        title: 'Supplement Routine',
        summary: summary,
        detail:
            'This tracker simply records what you already take. It does not '
            'recommend supplements or dosages.',
        periodLabel: label,
        basisLabel: 'Based on ${stats.supplementDays} days of data',
        kind: InsightKind.lifestyle,
        category: InsightCategory.observation,
        suggestion:
            'Consistency is a great start - continue the routine you already '
            'follow with your professional.',
      ),
    ];
  }
}