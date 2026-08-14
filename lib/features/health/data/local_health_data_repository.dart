import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_entries.dart';

/// Storage contract for health tracker entries.
///
/// The UI layer only ever talks to this interface through
/// [healthRepositoryProvider], so the backing store can be swapped later
/// (e.g. a Firebase/backend repository) without changing any widget code.
abstract class HealthDataRepository {
  /// Returns all stored entries for [type], newest date first. Every map is
  /// a full stored record (includes `id`, `date`, `created_at`, `updated_at`).
  Future<List<Map<String, dynamic>>> fetch(HealthTrackerType type);

  /// Inserts a new entry. [payload] should contain the tracker fields plus
  /// `date`, `created_at` and `updated_at` (no `id`). Returns the full stored
  /// map including the generated `id`.
  Future<Map<String, dynamic>> create(
    HealthTrackerType type,
    Map<String, dynamic> payload,
  );

  /// Replaces the stored entry with [id] using [payload] (which carries the
  /// tracker fields and `updated_at`). Returns the full stored map.
  Future<Map<String, dynamic>> update(
    HealthTrackerType type,
    String id,
    Map<String, dynamic> payload,
  );

  /// Permanently removes the entry with [id].
  Future<void> delete(HealthTrackerType type, String id);
}

/// SharedPreferences-backed implementation of [HealthDataRepository].
///
/// Entries are persisted per tracker under the key `health_data_v1_<collection>`
/// as a JSON array of stored records. Each record keeps its own `date`
/// (yyyy-MM-dd), so logging a new day never overwrites previous days.
///
/// The record shape mirrors the fields the models already read/write
/// (`fromMap`/`toMap`), so migrating to a backend later only requires a new
/// [HealthDataRepository] implementation.
class LocalHealthDataRepository implements HealthDataRepository {
  static const String _storagePrefix = 'health_data_v1';

  static String _key(HealthTrackerType type) => '$_storagePrefix/${type.collection}';

  static String _newId() {
    final random = Random();
    return 'local_${DateTime.now().microsecondsSinceEpoch}_'
        '${random.nextInt(0xFFFF).toRadixString(16)}';
  }

  @override
  Future<List<Map<String, dynamic>>> fetch(HealthTrackerType type) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(type));
    if (raw == null || raw.isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    final rows = decoded
        .whereType<Map<String, dynamic>>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
    rows.sort((a, b) {
      final dateCmp = (b['date'] as String? ?? '').compareTo(a['date'] as String? ?? '');
      if (dateCmp != 0) return dateCmp;
      return (b['created_at'] as String? ?? '').compareTo(a['created_at'] as String? ?? '');
    });
    return rows;
  }

  @override
  Future<Map<String, dynamic>> create(
    HealthTrackerType type,
    Map<String, dynamic> payload,
  ) async {
    final stored = <String, dynamic>{
      'id': _newId(),
      'user_id': 'local',
      ...payload,
    };
    final rows = [...await fetch(type), stored];
    await _persist(type, rows);
    return stored;
  }

  @override
  Future<Map<String, dynamic>> update(
    HealthTrackerType type,
    String id,
    Map<String, dynamic> payload,
  ) async {
    final rows = [...await fetch(type)];
    final index = rows.indexWhere((m) => m['id'] == id);
    if (index == -1) {
      throw StateError('Unable to find the entry to update.');
    }
    final stored = <String, dynamic>{
      ...rows[index],
      ...payload,
      'id': id,
    };
    rows[index] = stored;
    await _persist(type, rows);
    return stored;
  }

  @override
  Future<void> delete(HealthTrackerType type, String id) async {
    final rows = [...await fetch(type)]..removeWhere((m) => m['id'] == id);
    await _persist(type, rows);
  }

  Future<void> _persist(
    HealthTrackerType type,
    List<Map<String, dynamic>> rows,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(type), jsonEncode(rows));
  }
}