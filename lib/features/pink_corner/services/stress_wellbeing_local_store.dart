import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A private journal entry saved on the device.
class StressJournalEntry {
  final String id;
  final DateTime date;
  final String prompt;
  final String text;

  const StressJournalEntry({
    required this.id,
    required this.date,
    required this.prompt,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'prompt': prompt,
        'text': text,
      };

  factory StressJournalEntry.fromJson(Map<String, dynamic> json) =>
      StressJournalEntry(
        id: json['id'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        prompt: json['prompt'] as String? ?? '',
        text: json['text'] as String? ?? '',
      );
}

/// A private stress check-in saved on the device.
class StressCheckInRecord {
  final String id;
  final DateTime date;
  final String level;
  final List<String> factors;

  const StressCheckInRecord({
    required this.id,
    required this.date,
    required this.level,
    required this.factors,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'level': level,
        'factors': factors,
      };

  factory StressCheckInRecord.fromJson(Map<String, dynamic> json) =>
      StressCheckInRecord(
        id: json['id'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        level: json['level'] as String? ?? '',
        factors: (json['factors'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toList(),
      );
}

/// Private, on-device storage for Stress & Well-being journal entries and
/// check-ins.
///
/// Entries are scoped to the authenticated user (keys include the Firebase
/// uid) and never leave the device — they are not sent to Cloud, Firestore,
/// or any external AI service.
class StressWellbeingLocalStore {
  static const String _journalPrefix = 'stress_wellbeing_v1/journal';
  static const String _checkinPrefix = 'stress_wellbeing_v1/checkin';

  StressWellbeingLocalStore._();

  static String _scopedKey(String prefix) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    return '$prefix/$uid';
  }

  /// Returns saved journal entries, newest first.
  static Future<List<StressJournalEntry>> loadJournals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scopedKey(_journalPrefix));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final entries = decoded
        .whereType<Map>()
        .map((m) => StressJournalEntry.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  /// Saves a new journal entry (private to the signed-in user).
  static Future<void> saveJournal(StressJournalEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await loadJournals();
    await prefs.setString(
      _scopedKey(_journalPrefix),
      jsonEncode(
        [entry.toJson(), ...entries.map((e) => e.toJson())],
      ),
    );
  }

  /// Returns saved check-ins, newest first.
  static Future<List<StressCheckInRecord>> loadCheckIns() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scopedKey(_checkinPrefix));
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    final records = decoded
        .whereType<Map>()
        .map((m) => StressCheckInRecord.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  /// Saves a new check-in (private to the signed-in user).
  static Future<void> saveCheckIn(StressCheckInRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await loadCheckIns();
    await prefs.setString(
      _scopedKey(_checkinPrefix),
      jsonEncode(
        [record.toJson(), ...records.map((e) => e.toJson())],
      ),
    );
  }

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// Human-friendly date label, e.g. "17 Aug · 3:40 PM".
  static String friendlyDate(DateTime d) {
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${_months[d.month - 1]} \u00b7 $hour12:$minute $amPm';
  }
}