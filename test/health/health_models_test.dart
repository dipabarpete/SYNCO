import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/models/health_entries.dart';

void main() {
  group('date helpers', () {
    test('healthDateKey renders zero-padded yyyy-MM-dd', () {
      expect(healthDateKey(DateTime(2026, 8, 3)), '2026-08-03');
      expect(healthDateKey(DateTime(2026, 12, 31)), '2026-12-31');
    });

    test('parseHealthDate round-trips', () {
      expect(parseHealthDate('2026-08-03'), DateTime(2026, 8, 3));
    });

    test('dateOnly strips time', () {
      final d = dateOnly(DateTime(2026, 8, 14, 22, 45, 30));
      expect(d, DateTime(2026, 8, 14));
    });

    test('formatDurationMinutes renders 7h 30m style labels', () {
      expect(formatDurationMinutes(450), '7h 30m');
      expect(formatDurationMinutes(420), '7h');
      expect(formatDurationMinutes(35), '35m');
    });
  });

  group('SleepEntry', () {
    test('computeDurationMinutes handles cross-midnight sleep', () {
      expect(SleepEntry.computeDurationMinutes(23 * 60 + 30, 7 * 60), 450);
    });

    test('computeDurationMinutes handles same-day sleeps', () {
      expect(SleepEntry.computeDurationMinutes(22 * 60, 6 * 60), 480);
    });

    test('computeDurationMinutes rejects impossible durations', () {
      expect(SleepEntry.computeDurationMinutes(7 * 60, 7 * 60), 0);
      expect(SleepEntry.computeDurationMinutes(0, 0), 0);
      // 11:00 -> 12:00 would be 60 minutes, valid; a 20h span is invalid.
      expect(SleepEntry.computeDurationMinutes(6 * 60, 2 * 60), 0);
    });

    test('toMap/fromMap round-trip preserves all fields', () {
      final entry = SleepEntry(
        id: 's1',
        userId: 'u1',
        date: DateTime(2026, 8, 13),
        startMinutes: 1410,
        endMinutes: 420,
        durationMinutes: 450,
        quality: 'Good',
        factors: const ['Early bedtime'],
        createdAt: '2026-08-13T10:00:00.000',
        updatedAt: '2026-08-13T10:00:00.000',
      );
      final restored = SleepEntry.fromMap({'id': 's1', ...entry.toMap()});
      expect(restored.id, 's1');
      expect(restored.date, DateTime(2026, 8, 13));
      expect(restored.durationMinutes, 450);
      expect(restored.quality, 'Good');
      expect(restored.factors, ['Early bedtime']);
    });
  });

  group('WaterEntry', () {
    test('converts cups <-> fl oz', () {
      final cups = WaterEntry(
        id: 'w1',
        userId: 'u1',
        date: DateTime(2026, 8, 13),
        quantity: 6.0,
        unit: 'cups',
        hydrationLevel: 'Okay',
        createdAt: '',
        updatedAt: '',
      );
      // 6 cups = 48 fl oz
      expect(cups.quantityFlOz, 48);
      expect(cups.quantityCups, 6);
    });

    test('toMap/fromMap round-trips optional time of day', () {
      final entry = WaterEntry(
        id: 'w2',
        userId: 'u1',
        date: DateTime(2026, 8, 13),
        quantity: 1.0,
        unit: 'cups',
        hydrationLevel: 'Good',
        timeMinutes: 540,
        createdAt: '',
        updatedAt: '',
      );
      final map = entry.toMap();
      expect(map['time_minutes'], 540);
      final restored = WaterEntry.fromMap({'id': 'w2', ...map});
      expect(restored.timeMinutes, 540);
      final withoutTime = WaterEntry.fromMap({'id': 'w2', ...map, 'time_minutes': null});
      expect(withoutTime.timeMinutes, isNull);
    });
  });

  group('WeightEntry', () {
    test('converts lb to kg for trend math', () {
      final entry = WeightEntry(
        id: 'w1',
        userId: 'u1',
        date: DateTime(2026, 8, 1),
        weight: 132,
        unit: 'lb',
        createdAt: '',
        updatedAt: '',
      );
      expect(entry.weightKg, closeTo(59.874, 0.001));
    });
  });

  group('HealthTrackerType metadata', () {
    test('every tracker exposes a collection, label and save label', () {
      for (final type in HealthTrackerType.values) {
        expect(type.collection, isNotEmpty);
        expect(type.label, isNotEmpty);
        expect(type.saveLabel, isNotEmpty);
      }
    });

    test('all eight tracker collections exist', () {
      final collections = HealthTrackerType.values.map((t) => t.collection);
      expect(collections, containsAll(const [
        'sleep_entries',
        'water_entries',
        'step_entries',
        'sugar_craving_entries',
        'supplement_entries',
        'mental_wellness_entries',
        'food_entries',
        'weight_entries',
      ]));
    });
  });
}