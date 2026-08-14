import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/data/local_health_data_repository.dart';
import 'package:hersync/features/health/models/health_entries.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Map<String, dynamic> sleepRow(String date) => {
        'date': date,
        'start_minutes': 1320,
        'end_minutes': 420,
        'duration_minutes': 450,
        'quality': 'Good',
        'factors': ['Early bedtime'],
        'created_at': 't1',
        'updated_at': 't1',
      };

  Map<String, dynamic> waterRow(String date, double quantity) => {
        'date': date,
        'quantity': quantity,
        'unit': 'cups',
        'hydration_level': 'Okay',
        'time_minutes': 540,
        'created_at': 't1',
        'updated_at': 't1',
      };

  test('create returns a stored record with id and persists it', () async {
    final repo = LocalHealthDataRepository();

    final stored =
        await repo.create(HealthTrackerType.sleep, sleepRow('2026-08-14'));

    expect(stored['id'], isNotNull);
    expect(stored['user_id'], 'local');
    expect(stored['date'], '2026-08-14');

    final rows = await repo.fetch(HealthTrackerType.sleep);
    expect(rows, hasLength(1));
    expect(rows.single['id'], stored['id']);
    expect(rows.single['quality'], 'Good');
  });

  test('trackers are stored separately', () async {
    final repo = LocalHealthDataRepository();

    await repo.create(HealthTrackerType.water, waterRow('2026-08-14', 6));
    await repo.create(HealthTrackerType.sleep, sleepRow('2026-08-14'));

    final water = await repo.fetch(HealthTrackerType.water);
    final sleep = await repo.fetch(HealthTrackerType.sleep);

    expect(water, hasLength(1));
    expect(sleep, hasLength(1));
    expect(water.single['quantity'], 6);
  });

  test('different dates never overwrite each other; newest date sorts first',
      () async {
    final repo = LocalHealthDataRepository();

    await repo.create(HealthTrackerType.water, waterRow('2026-08-14', 6));
    await repo.create(HealthTrackerType.water, waterRow('2026-08-15', 8));
    await repo.create(HealthTrackerType.water, waterRow('2026-08-13', 4));

    final rows = await repo.fetch(HealthTrackerType.water);
    expect(rows, hasLength(3));
    expect(
      rows.map((m) => m['date']).toList(),
      ['2026-08-15', '2026-08-14', '2026-08-13'],
    );
  });

  test('update replaces fields while preserving id and date', () async {
    final repo = LocalHealthDataRepository();
    final stored =
        await repo.create(HealthTrackerType.steps, {'date': '2026-08-14', 'count': 5000, 'source': 'manual', 'created_at': 't1', 'updated_at': 't1'});

    final updated = await repo.update(
      HealthTrackerType.steps,
      stored['id'] as String,
      {'count': 9000, 'updated_at': 't2'},
    );

    expect(updated['id'], stored['id']);
    expect(updated['date'], '2026-08-14');
    expect(updated['count'], 9000);

    final rows = await repo.fetch(HealthTrackerType.steps);
    expect(rows, hasLength(1));
    expect(rows.single['count'], 9000);
  });

  test('update with an unknown id throws StateError', () async {
    final repo = LocalHealthDataRepository();
    expect(
      () => repo.update(
        HealthTrackerType.sleep,
        'missing-id',
        {'quality': 'Poor'},
      ),
      throwsStateError,
    );
  });

  test('delete removes only the requested entry', () async {
    final repo = LocalHealthDataRepository();
    final first = await repo.create(
      HealthTrackerType.sugarCravings,
      {'date': '2026-08-14', 'craving': 'Chocolate', 'level': 'High', 'created_at': 't1', 'updated_at': 't1'},
    );
    final second = await repo.create(
      HealthTrackerType.sugarCravings,
      {'date': '2026-08-14', 'craving': 'Chips', 'level': 'Low', 'created_at': 't2', 'updated_at': 't2'},
    );

    await repo.delete(HealthTrackerType.sugarCravings, first['id'] as String);

    final rows = await repo.fetch(HealthTrackerType.sugarCravings);
    expect(rows, hasLength(1));
    expect(rows.single['id'], second['id']);
  });

  test('data survives repository re-creation (app reopen)', () async {
    final first = LocalHealthDataRepository();
    await first.create(HealthTrackerType.weight, {'date': '2026-08-14', 'weight': 62.4, 'unit': 'kg', 'created_at': 't1', 'updated_at': 't1'});

    final second = LocalHealthDataRepository();
    final rows = await second.fetch(HealthTrackerType.weight);
    expect(rows, hasLength(1));
    expect(rows.single['weight'], 62.4);
  });

  test('time of day is preserved through create and fetch', () async {
    final repo = LocalHealthDataRepository();
    await repo.create(HealthTrackerType.water, waterRow('2026-08-14', 6));

    final rows = await repo.fetch(HealthTrackerType.water);
    expect(rows.single['time_minutes'], 540);
  });
}
