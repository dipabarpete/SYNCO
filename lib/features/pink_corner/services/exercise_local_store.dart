import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A completed movement session recorded on this device.
///
/// Sessions are only ever created when the user actually completes a
/// movement session (guided workout or manually logged activity) — the
/// streak and achievements are always derived from these real records.
class ExerciseSession {
  final String id;
  final DateTime date;
  final String activityType;
  final int durationMinutes;
  final String? workoutId;
  final DateTime createdAt;

  const ExerciseSession({
    required this.id,
    required this.date,
    required this.activityType,
    required this.durationMinutes,
    this.workoutId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'activity_type': activityType,
        'duration_minutes': durationMinutes,
        'workout_id': workoutId,
        'created_at': createdAt.toIso8601String(),
      };

  factory ExerciseSession.fromJson(Map<String, dynamic> json) =>
      ExerciseSession(
        id: json['id'] as String? ?? '',
        date:
            DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        activityType: json['activity_type'] as String? ?? 'general',
        durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
        workoutId: json['workout_id'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// Current and best-ever streak, derived from completed sessions.
class ExerciseStreak {
  final int current;
  final int longest;

  const ExerciseStreak({required this.current, required this.longest});
}

/// Private, on-device storage for Exercise & Movement activity records and
/// unlocked achievements.
///
/// Records are scoped to the authenticated user (keys include the Firebase
/// uid) and never leave the device — they are not sent to Cloud, Firestore,
/// or any external service.
class ExerciseLocalStore {
  static const String _sessionsPrefix = 'exercise_movement_v1/session';
  static const String _achievementsPrefix = 'exercise_movement_v1/achievement';

  ExerciseLocalStore._();

  static String _scopedKey(String prefix) {
    String uid = 'guest';
    try {
      uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    } catch (_) {
      // Firebase may not be initialised (e.g. in widget tests) — fall back.
    }
    return '$prefix/$uid';
  }

  /// Returns saved movement sessions, newest first.
  static Future<List<ExerciseSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scopedKey(_sessionsPrefix));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final sessions = decoded
        .whereType<Map>()
        .map((m) => ExerciseSession.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    sessions.sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  /// Saves a newly completed movement session (private to the user).
  static Future<void> saveSession(ExerciseSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = [session, ...await loadSessions()];
    await prefs.setString(
      _scopedKey(_sessionsPrefix),
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );
  }

  /// Returns the set of achievement ids already unlocked.
  static Future<Set<String>> loadUnlockedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scopedKey(_achievementsPrefix));
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! List) return {};
    return decoded.whereType<String>().toSet();
  }

  /// Persists the full set of unlocked achievement ids.
  static Future<void> saveUnlockedAchievements(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scopedKey(_achievementsPrefix),
      jsonEncode(ids.toList()),
    );
  }

  /// Computes current and longest streaks from completed sessions.
  ///
  /// A streak counts consecutive calendar days with at least one completed
  /// session. The current streak stays alive if the user moved yesterday and
  /// is simply resting today — rest days never reset it with guilt.
  static ExerciseStreak computeStreak(List<ExerciseSession> sessions) {
    final days = sessions
        .map((s) => DateTime(s.date.year, s.date.month, s.date.day))
        .toSet()
        .toList()
      ..sort();

    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    int current = 0;
    if (days.contains(todayKey)) {
      current = 1;
      var day = todayKey.subtract(const Duration(days: 1));
      while (days.contains(day)) {
        current++;
        day = day.subtract(const Duration(days: 1));
      }
    } else if (days.contains(todayKey.subtract(const Duration(days: 1)))) {
      current = 1;
      var day = todayKey.subtract(const Duration(days: 2));
      while (days.contains(day)) {
        current++;
        day = day.subtract(const Duration(days: 1));
      }
    }

    int longest = 0;
    int run = 0;
    DateTime? previous;
    for (final day in days) {
      if (previous != null && day.difference(previous).inDays == 1) {
        run++;
      } else {
        run = 1;
      }
      if (run > longest) longest = run;
      previous = day;
    }

    return ExerciseStreak(current: current, longest: longest);
  }

  /// Strips a timestamp to its calendar day (local midnight).
  static DateTime dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}