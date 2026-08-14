import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/models/ai_insight.dart';
import 'package:hersync/features/health/models/health_entries.dart';
import 'package:hersync/features/health/services/ai_pattern_service.dart';

final now = DateTime(2026, 8, 14, 10, 30);

DateTime day(int daysAgo) =>
    dateOnly(now.subtract(Duration(days: daysAgo)));

SleepEntry sleepEntry(String id, int daysAgo, int minutes, String quality) {
  return SleepEntry(
    id: id,
    userId: 'u1',
    date: day(daysAgo),
    startMinutes: 1410,
    endMinutes: minutes,
    durationMinutes: minutes,
    quality: quality,
    factors: const [],
    createdAt: '2026-08-01T00:00:00.000',
    updatedAt: '2026-08-01T00:00:00.000',
  );
}

WaterEntry waterEntry(String id, int daysAgo, double cups) {
  return WaterEntry(
    id: id,
    userId: 'u1',
    date: day(daysAgo),
    quantity: cups,
    unit: 'cups',
    hydrationLevel: 'Good',
    createdAt: '',
    updatedAt: '',
  );
}

StepEntry stepEntry(String id, int daysAgo, int count) {
  return StepEntry(
    id: id,
    userId: 'u1',
    date: day(daysAgo),
    count: count,
    createdAt: '',
    updatedAt: '',
  );
}

MentalWellnessEntry wellnessEntry(
  String id,
  int daysAgo,
  int stress,
  int energy,
) {
  return MentalWellnessEntry(
    id: id,
    userId: 'u1',
    date: day(daysAgo),
    stressLevel: stress,
    anxietyLevel: stress,
    energyLevel: energy,
    sleepQuality: 'Okay',
    mood: 'Calm',
    createdAt: '',
    updatedAt: '',
  );
}

SugarCravingEntry cravingEntry(String id, int daysAgo, String level) {
  return SugarCravingEntry(
    id: id,
    userId: 'u1',
    date: day(daysAgo),
    craving: 'Chocolate',
    level: level,
    createdAt: '',
    updatedAt: '',
  );
}

FoodEntry mealEntry(String id, int daysAgo, String tag) {
  return FoodEntry(
    id: id,
    userId: 'u1',
    date: day(daysAgo),
    description: 'Meal with $tag',
    mealType: 'Dinner',
    tags: [tag],
    isFavorite: false,
    createdAt: '',
    updatedAt: '',
  );
}

WeightEntry weightEntry(String id, int daysAgo, double kg) {
  return WeightEntry(
    id: id,
    userId: 'u1',
    date: day(daysAgo),
    weight: kg,
    unit: 'kg',
    createdAt: '',
    updatedAt: '',
  );
}

void main() {
  const service = AiPatternService();

  group('insufficient data', () {
    test('no insights when there is no data at all', () {
      expect(service.detect(all: const [], now: now), isEmpty);
    });

    test('no insights with fewer than 3 days of data', () {
      final all = <HealthEntry>[
        sleepEntry('a', 0, 450, 'Good'),
        sleepEntry('b', 1, 420, 'Good'),
      ];
      expect(service.detect(all: all, now: now), isEmpty);
    });
  });

  group('sufficient data', () {
    test('detects sleep vs energy correlation', () {
      // 3 short-sleep days with low energy, 3 long-sleep days with high energy.
      final all = <HealthEntry>[
        sleepEntry('s0', 0, 360, 'Poor'),
        wellnessEntry('w0', 0, 4, 2),
        sleepEntry('s1', 1, 330, 'Poor'),
        wellnessEntry('w1', 1, 5, 1),
        sleepEntry('s2', 2, 345, 'Poor'),
        wellnessEntry('w2', 2, 4, 2),
        sleepEntry('s3', 3, 480, 'Good'),
        wellnessEntry('w3', 3, 2, 4),
        sleepEntry('s4', 4, 500, 'Good'),
        wellnessEntry('w4', 4, 1, 5),
        sleepEntry('s5', 5, 490, 'Good'),
        wellnessEntry('w5', 5, 2, 4),
      ];

      final insights = service.detect(all: all, now: now);
      final sleepEnergy =
          insights.where((i) => i.id == 'sleep-energy').firstOrNull;

      expect(sleepEnergy, isNotNull, reason: 'expected sleep-energy insight');
      expect(
        sleepEnergy!.summary,
        contains('energy was lower'),
      );
      expect(sleepEnergy.category, InsightCategory.pattern);
      expect(sleepEnergy.basisLabel, contains('6 days'));
    });

    test('detects sugar craving frequency', () {
      final all = <HealthEntry>[
        for (var i = 0; i < 7; i++) sleepEntry('s$i', i, 450, 'Good'),
        cravingEntry('c0', 0, 'High'),
        cravingEntry('c1', 1, 'High'),
        cravingEntry('c2', 2, 'Medium'),
      ];

      final insights = service.detect(all: all, now: now);
      final craving = insights.where((i) => i.id == 'sugar-cravings').firstOrNull;

      expect(craving, isNotNull);
      expect(craving!.summary, contains('3 of the last 7 days'));
      expect(craving.kind, InsightKind.sugarCravings);
    });

    test('detects step count increase week over week', () {
      final all = <HealthEntry>[
        // This week (days 0-2): high steps
        stepEntry('a0', 0, 9000),
        stepEntry('a1', 1, 9500),
        stepEntry('a2', 2, 8800),
        // Last week (days 7-9): low steps
        stepEntry('b0', 7, 5000),
        stepEntry('b1', 8, 4800),
        stepEntry('b2', 9, 5200),
      ];

      final insights = service.detect(all: all, now: now);
      final activity =
          insights.where((i) => i.id == 'steps-trend').firstOrNull;

      expect(activity, isNotNull);
      expect(activity!.trend, InsightTrend.up);
      expect(activity.summary, contains('increased'));
    });

    test('detects processed food tag pattern', () {
      final all = <HealthEntry>[
        for (var i = 0; i < 7; i++) sleepEntry('s$i', i, 450, 'Good'),
        mealEntry('f0', 0, 'Processed Food'),
        mealEntry('f1', 1, 'Processed Food'),
        mealEntry('f2', 2, 'Processed Food'),
      ];

      final insights = service.detect(all: all, now: now);
      final nutrition =
          insights.where((i) => i.id == 'food-tag-Processed Food').firstOrNull;

      expect(nutrition, isNotNull);
      expect(nutrition!.category, InsightCategory.suggestion);
      expect(nutrition.summary, contains('Processed Food'));
    });

    test('detects monthly weight trend without good/bad labelling', () {
      final all = <HealthEntry>[
        weightEntry('w0', 12, 63.5),
        weightEntry('w1', 10, 63.2),
        weightEntry('w2', 0, 62.6),
      ];

      final insights = service.detect(all: all, now: now);
      final weight = insights.where((i) => i.id == 'weight-trend').firstOrNull;

      expect(weight, isNotNull);
      expect(weight!.trend, InsightTrend.down);
      expect(weight.summary, contains('from 63.5 kg'));
      expect(weight.summary, contains('to 62.6 kg'));
      expect(weight.summary.toLowerCase(), isNot(contains('good')));
      expect(weight.summary.toLowerCase(), isNot(contains('bad')));
    });

    test('insights never claim medical causation', () {
      // Deliberately confusing data: short sleep WITH high energy and low
      // stress so any "would-be" causal claim is impossible.
      final all = <HealthEntry>[
        sleepEntry('s0', 0, 360, 'Poor'),
        wellnessEntry('w0', 0, 1, 5),
        sleepEntry('s1', 1, 330, 'Poor'),
        wellnessEntry('w1', 1, 1, 5),
        sleepEntry('s2', 2, 450, 'Good'),
        wellnessEntry('w2', 2, 4, 1),
        sleepEntry('s3', 3, 480, 'Good'),
        wellnessEntry('w3', 3, 4, 1),
        sleepEntry('s4', 4, 460, 'Good'),
        wellnessEntry('w4', 4, 4, 1),
      ];

      final insights = service.detect(all: all, now: now);
      for (final insight in insights) {
        final text = '${insight.title} ${insight.summary} '
            '${insight.detail ?? ''}';
        expect(text.toLowerCase(), isNot(contains('caus')),
            reason: 'must never claim causation: $text');
        expect(text.toLowerCase(), isNot(contains('diagnos')),
            reason: 'must never claim diagnosis: $text');
        expect(text.toLowerCase(), isNot(contains('cure')),
            reason: 'must never promise a cure: $text');
      }
    });
  });
}
