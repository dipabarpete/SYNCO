import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/models/health_entries.dart';
import 'package:hersync/features/health/services/health_analytics.dart';

SleepEntry sleep(int daysAgo, int minutes, String quality) {
  final date = dateOnly(DateTime.now().subtract(Duration(days: daysAgo)));
  return SleepEntry(
    id: 'sl_$daysAgo',
    userId: 'u1',
    date: date,
    startMinutes: 1410,
    endMinutes: minutes,
    durationMinutes: minutes,
    quality: quality,
    factors: const [],
    createdAt: '',
    updatedAt: '',
  );
}

WaterEntry water(int daysAgo, double cups, String level) {
  return WaterEntry(
    id: 'w_$daysAgo',
    userId: 'u1',
    date: dateOnly(DateTime.now().subtract(Duration(days: daysAgo))),
    quantity: cups,
    unit: 'cups',
    hydrationLevel: level,
    createdAt: '',
    updatedAt: '',
  );
}

StepEntry steps(int daysAgo, int count) {
  return StepEntry(
    id: 'st_$daysAgo',
    userId: 'u1',
    date: dateOnly(DateTime.now().subtract(Duration(days: daysAgo))),
    count: count,
    createdAt: '',
    updatedAt: '',
  );
}

MentalWellnessEntry wellness(int daysAgo, int stress, int energy, String mood) {
  return MentalWellnessEntry(
    id: 'm_$daysAgo',
    userId: 'u1',
    date: dateOnly(DateTime.now().subtract(Duration(days: daysAgo))),
    stressLevel: stress,
    anxietyLevel: stress,
    energyLevel: energy,
    sleepQuality: 'Okay',
    mood: mood,
    createdAt: '',
    updatedAt: '',
  );
}

SugarCravingEntry craving(int daysAgo, String level) {
  return SugarCravingEntry(
    id: 'c_$daysAgo',
    userId: 'u1',
    date: dateOnly(DateTime.now().subtract(Duration(days: daysAgo))),
    craving: 'Chocolate',
    level: level,
    createdAt: '',
    updatedAt: '',
  );
}

FoodEntry meal(int daysAgo, String tag, String mealType) {
  return FoodEntry(
    id: 'f_$daysAgo',
    userId: 'u1',
    date: dateOnly(DateTime.now().subtract(Duration(days: daysAgo))),
    description: 'Sample meal',
    mealType: mealType,
    tags: [tag],
    isFavorite: false,
    createdAt: '',
    updatedAt: '',
  );
}

void main() {
  final now = DateTime.now();

  group('daily snapshot', () {
    test('aggregates a day and ignores other days', () {
      final all = <HealthEntry>[
        sleep(0, 450, 'Good'),
        water(0, 4, 'Good'),
        water(0, 2, 'Okay'),
        steps(0, 7800),
        wellness(0, 2, 4, 'Calm'),
        meal(0, 'Dairy', 'Lunch'),
        sleep(1, 400, 'Poor'),
      ];

      final snapshot = HealthAnalytics.daily(all: all, date: now);
      expect(snapshot.sleep?.durationMinutes, 450);
      expect(snapshot.totalWaterCups, 6);
      expect(snapshot.steps?.count, 7800);
      expect(snapshot.wellness?.stressLevel, 2);
      expect(snapshot.mealCount, 1);
      expect(snapshot.supplementCount, 0);
    });

    test('returns empty values for a day with no data', () {
      final snapshot = HealthAnalytics.daily(all: const [], date: now);
      expect(snapshot.sleep, isNull);
      expect(snapshot.steps, isNull);
      expect(snapshot.wellness, isNull);
      expect(snapshot.totalWaterCups, 0);
      expect(snapshot.mealCount, 0);
    });
  });

  group('period aggregation', () {
    test('this week computes averages and distributions', () {
      // Sleep this week (days 0,1,2): 300m + 360m + 420m on days 0/1/2
      final all = <HealthEntry>[
        sleep(0, 360, 'Good'),
        sleep(1, 300, 'Poor'),
        sleep(2, 420, 'Good'),
        water(0, 4, 'Good'),
        water(1, 8, 'Good'),
        steps(0, 7000),
        steps(1, 8000),
        wellness(0, 2, 4, 'Calm'),
        wellness(1, 5, 1, 'Angry'),
        craving(0, 'High'),
        craving(1, 'Medium'),
        meal(0, 'Processed Food', 'Dinner'),
        meal(0, 'Processed Food', 'Snack'),
      ];

      final week = HealthAnalytics.period(
        all: all,
        start: HealthAnalytics.addDays(now, -6),
        end: now,
      );

      expect(week.daysWithData, 3);
      expect(week.avgSleepMinutes, (360 + 300 + 420) / 3);
      expect(week.sleepQualityDistribution['Good'], 2);
      expect(week.sleepQualityDistribution['Poor'], 1);
      expect(week.avgWaterFlOz, (32 + 64) / 2);
      expect(week.avgSteps, 7500);
      expect(week.avgStress, 3.5);
      expect(week.moodDistribution['Calm'], 1);
      expect(week.moodDistribution['Angry'], 1);
      expect(week.cravingDays, 2);
      expect(week.cravingCount, 2);
      expect(week.cravingLevelCounts['High'], 1);
      expect(week.foodTagFrequency['Processed Food'], 2);
      expect(week.mealCount, 2);
    });
  });

  group('weight trend', () {
    test('weightChangeKg requires two distinct entries', () {
      final all = <HealthEntry>[
        WeightEntry(
          id: 'w1',
          userId: 'u1',
          date: dateOnly(now.subtract(const Duration(days: 5))),
          weight: 63.0,
          unit: 'kg',
          createdAt: '',
          updatedAt: '',
        ),
        WeightEntry(
          id: 'w2',
          userId: 'u1',
          date: today(now),
          weight: 62.4,
          unit: 'kg',
          createdAt: '',
          updatedAt: '',
        ),
      ];

      final period = HealthAnalytics.period(
        all: all,
        start: HealthAnalytics.addDays(now, -30),
        end: now,
      );

      expect(period.weightChangeKg, closeTo(-0.6, 0.0001));
      expect(period.firstWeight?.id, 'w1');
      expect(period.lastWeight?.id, 'w2');
    });
  });
}

DateTime today(DateTime now) => dateOnly(now);