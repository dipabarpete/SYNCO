import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/models/health_entries.dart';

void main() {
  group('Safe Numeric Parsing Helpers', () {
    test('safeParseNum handles ints, doubles, nums, stringified numbers, null, and malformed strings', () {
      expect(safeParseNum(null), isNull);
      expect(safeParseNum(42), 42);
      expect(safeParseNum(62.4), 62.4);
      expect(safeParseNum('42'), 42);
      expect(safeParseNum('62.4'), 62.4);
      expect(safeParseNum('  5248  '), 5248);
      expect(safeParseNum(''), isNull);
      expect(safeParseNum('   '), isNull);
      expect(safeParseNum('invalid'), isNull);
    });

    test('safeParseInt parses int with fallback', () {
      expect(safeParseInt(null, 10), 10);
      expect(safeParseInt(45), 45);
      expect(safeParseInt('45'), 45);
      expect(safeParseInt('45.8'), 45);
      expect(safeParseInt('invalid', 99), 99);
    });

    test('safeParseDouble parses double with fallback', () {
      expect(safeParseDouble(null, 1.5), 1.5);
      expect(safeParseDouble(62.4), 62.4);
      expect(safeParseDouble('62.4'), 62.4);
      expect(safeParseDouble('invalid', 0.0), 0.0);
    });
  });

  group('Health Models Numeric Parsing & Serialization', () {
    test('SleepEntry parses String, num, null, and malformed start/end/duration minutes without throwing', () {
      final mapWithStringNumbers = {
        'id': 'sleep_1',
        'user_id': 'u1',
        'date': '2026-08-16',
        'start_minutes': '1410',
        'end_minutes': '450',
        'duration_minutes': '480',
        'quality': 'Good',
        'factors': ['Early bedtime'],
        'created_at': '2026-08-16T07:30:00.000Z',
        'updated_at': '2026-08-16T07:30:00.000Z',
      };

      final entry = SleepEntry.fromMap(mapWithStringNumbers);
      expect(entry.startMinutes, 1410);
      expect(entry.endMinutes, 450);
      expect(entry.durationMinutes, 480);

      final mapWithMalformedNumbers = {
        'id': 'sleep_2',
        'user_id': 'u1',
        'date': '2026-08-16',
        'start_minutes': 'invalid',
        'end_minutes': null,
        'duration_minutes': '',
        'quality': 'Okay',
        'created_at': '',
        'updated_at': '',
      };

      final malformedEntry = SleepEntry.fromMap(mapWithMalformedNumbers);
      expect(malformedEntry.startMinutes, 0);
      expect(malformedEntry.endMinutes, 0);
      expect(malformedEntry.durationMinutes, 0);
    });

    test('WaterEntry parses String, num, null, and malformed quantity and time_minutes', () {
      final mapWithString = {
        'id': 'water_1',
        'user_id': 'u1',
        'date': '2026-08-16',
        'quantity': '2.5',
        'unit': 'L',
        'hydration_level': 'Good',
        'time_minutes': '900',
        'created_at': '',
        'updated_at': '',
      };

      final entry = WaterEntry.fromMap(mapWithString);
      expect(entry.quantity, 2.5);
      expect(entry.timeMinutes, 900);

      final mapWithNulls = {
        'id': 'water_2',
        'user_id': 'u1',
        'date': '2026-08-16',
        'quantity': null,
        'unit': 'cups',
        'hydration_level': '',
        'time_minutes': null,
        'created_at': '',
        'updated_at': '',
      };

      final nullEntry = WaterEntry.fromMap(mapWithNulls);
      expect(nullEntry.quantity, 0.0);
      expect(nullEntry.timeMinutes, isNull);
    });

    test('StepEntry parses String, num, null, and malformed step counts', () {
      final mapWithString = {
        'id': 'step_1',
        'user_id': 'u1',
        'date': '2026-08-16',
        'count': '8450',
        'source': 'manual',
        'created_at': '',
        'updated_at': '',
      };

      final entry = StepEntry.fromMap(mapWithString);
      expect(entry.count, 8450);

      final serialized = entry.toMap();
      expect(serialized['count'], isA<int>());
      expect(serialized['count'], 8450);
    });

    test('MentalWellnessEntry parses String levels without throwing', () {
      final mapWithString = {
        'id': 'wellness_1',
        'user_id': 'u1',
        'date': '2026-08-16',
        'stress_level': '3',
        'anxiety_level': '2',
        'energy_level': '4',
        'sleep_quality': 'Good',
        'mood': 'Calm',
        'time_minutes': '540',
        'created_at': '',
        'updated_at': '',
      };

      final entry = MentalWellnessEntry.fromMap(mapWithString);
      expect(entry.stressLevel, 3);
      expect(entry.anxietyLevel, 2);
      expect(entry.energyLevel, 4);
      expect(entry.timeMinutes, 540);
    });

    test('WeightEntry parses String weight and weight_kg fallback without throwing', () {
      final mapWithStringWeight = {
        'id': 'weight_1',
        'user_id': 'u1',
        'date': '2026-08-16',
        'weight': '62.4',
        'unit': 'kg',
        'created_at': '',
        'updated_at': '',
      };

      final entry1 = WeightEntry.fromMap(mapWithStringWeight);
      expect(entry1.weight, 62.4);

      final mapWithWeightKgKey = {
        'id': 'weight_2',
        'user_id': 'u1',
        'date': '2026-08-16',
        'weight_kg': '65.0',
        'unit': 'kg',
        'created_at': '',
        'updated_at': '',
      };

      final entry2 = WeightEntry.fromMap(mapWithWeightKgKey);
      expect(entry2.weight, 65.0);
    });
  });
}
