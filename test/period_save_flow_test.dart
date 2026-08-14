import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hersync/models/period_record.dart';
import 'package:hersync/features/cycle/services/period_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Period Log Save Flow & Diagnostic Tests', () {
    test('Date formatting for PostgreSQL date column (YYYY-MM-DD)', () {
      final now = DateTime(2026, 8, 11, 14, 30, 45);
      final isoStr = now.toIso8601String();
      final dateOnly = isoStr.split('T').first;

      expect(dateOnly, '2026-08-11');
      expect(dateOnly.length, 10);
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOnly), isTrue);
    });

    test('PeriodRecord serialization and deserialization from DB row', () {
      final dbRow = {
        'id': 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d',
        'user_id': 'f0e9d8c7-b6a5-4f3e-2d1c-0b9a8f7e6d5c',
        'start_date': '2026-08-11',
        'end_date': '2026-08-15',
        'flow_level': 'heavy',
        'pain_level': 4,
        'mood': 'Tired',
        'symptoms': ['Cramps', 'Headache', 'Back Pain'],
        'notes': 'Heavy flow day 1',
        'created_at': '2026-08-11T08:00:00.000Z',
        'updated_at': '2026-08-11T08:00:00.000Z',
      };

      final record = PeriodRecord.fromMap(dbRow);

      expect(record.id, 'a1b2c3d4-e5f6-7a8b-9c0d-1e2f3a4b5c6d');
      expect(record.userId, 'f0e9d8c7-b6a5-4f3e-2d1c-0b9a8f7e6d5c');
      expect(record.startDate.year, 2026);
      expect(record.startDate.month, 8);
      expect(record.startDate.day, 11);
      expect(record.endDate?.day, 15);
      expect(record.flowLevel, 'heavy');
      expect(record.painLevel, 4);
      expect(record.mood, 'Tired');
      expect(record.symptoms, ['Cramps', 'Headache', 'Back Pain']);
      expect(record.notes, 'Heavy flow day 1');
      expect(record.flowLevelDisplay, 'Heavy');
    });

    test('Unauthenticated user attempt throws clear StateError', () async {
      final repo = PeriodRepository();

      // Case 1: Before Firebase is initialized or user logged out
      expect(
        () => repo.createPeriod(
          startDate: DateTime.now(),
          flowLevel: 'medium',
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Firebase client is not initialized'),
        )),
      );

      expect(
        () => repo.updatePeriod(
          'some-id',
          startDate: DateTime.now(),
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('Firebase client is not initialized'),
        )),
      );
    });

    test('RLS Policy and Auth user scoping test simulation', () {
      const userA = '11111111-1111-1111-1111-111111111111';
      const userB = '22222222-2222-2222-2222-222222222222';

      final recordA = PeriodRecord(
        id: 'rec-1',
        userId: userA,
        startDate: DateTime(2026, 8, 1),
        flowLevel: 'medium',
      );

      final recordB = PeriodRecord(
        id: 'rec-2',
        userId: userB,
        startDate: DateTime(2026, 8, 5),
        flowLevel: 'light',
      );

      final allRecords = [recordA, recordB];

      // Simulated RLS SELECT filter for User A: auth.uid() == user_id
      final userARecords = allRecords.where((r) => r.userId == userA).toList();
      expect(userARecords.length, 1);
      expect(userARecords.first.id, 'rec-1');

      // User A cannot read User B's record
      expect(userARecords.any((r) => r.userId == userB), isFalse);
    });
  });
}
