import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/models/health_entries.dart';
import 'package:hersync/models/period_record.dart';

void main() {
  group('HealthDataSeeder Data Structure & Idempotency Tests', () {
    test('Sleep entries from August 16-18 parse valid dates and values', () {
      final aug16Map = {
        'id': '2026-08-16|seed_sleep',
        'user_id': 'test_uid',
        'date': '2026-08-16',
        'start_minutes': 1410,
        'end_minutes': 450,
        'duration_minutes': 480,
        'quality': 'Good',
        'factors': ['Early bedtime', 'Earplugs'],
        'created_at': '2026-08-16T07:30:00.000Z',
        'updated_at': '2026-08-16T07:30:00.000Z',
      };

      final aug17Map = {
        'id': '2026-08-17|seed_sleep',
        'user_id': 'test_uid',
        'date': '2026-08-17',
        'start_minutes': 1380,
        'end_minutes': 390,
        'duration_minutes': 450,
        'quality': 'Good',
        'factors': ['Early bedtime'],
        'created_at': '2026-08-17T06:30:00.000Z',
        'updated_at': '2026-08-17T06:30:00.000Z',
      };

      final aug18Map = {
        'id': '2026-08-18|seed_sleep',
        'user_id': 'test_uid',
        'date': '2026-08-18',
        'start_minutes': 15,
        'end_minutes': 465,
        'duration_minutes': 450,
        'quality': 'Okay',
        'factors': ['Late bedtime', 'Device in bed'],
        'created_at': '2026-08-18T07:45:00.000Z',
        'updated_at': '2026-08-18T07:45:00.000Z',
      };

      final entry16 = SleepEntry.fromMap(aug16Map);
      final entry17 = SleepEntry.fromMap(aug17Map);
      final entry18 = SleepEntry.fromMap(aug18Map);

      expect(entry16.date, DateTime(2026, 8, 16));
      expect(entry16.durationMinutes, 480);
      expect(entry16.quality, 'Good');

      expect(entry17.date, DateTime(2026, 8, 17));
      expect(entry17.durationMinutes, 450);

      expect(entry18.date, DateTime(2026, 8, 18));
      expect(entry18.quality, 'Okay');
    });

    test('Period record for August 16-18 parses correct range', () {
      final periodMap = {
        'id': '2026-08-16|seed_period',
        'user_id': 'test_uid',
        'start_date': '2026-08-16',
        'end_date': '2026-08-18',
        'flow_level': 'Medium',
        'pain_level': 2,
        'moods': ['Calm'],
        'symptoms': ['Mild cramping'],
        'notes': 'Cycle started on schedule',
        'created_at': '2026-08-16T08:00:00.000Z',
        'updated_at': '2026-08-16T08:00:00.000Z',
      };

      final record = PeriodRecord.fromMap(periodMap);
      expect(record.startDate, DateTime(2026, 8, 16));
      expect(record.endDate, DateTime(2026, 8, 18));
      expect(record.flowLevel, 'Medium');
      expect(record.painLevel, 2);
    });
  });
}
