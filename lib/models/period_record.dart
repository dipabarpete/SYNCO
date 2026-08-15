import 'period_day_log.dart';

/// A persisted period entry for the signed-in user.
///
/// Every record is scoped to `users/{userId}/period_logs` in Firestore and
/// carries the period dates plus all health observations (moods, symptoms,
/// discharge, digestion, other factors) together with per-day logs that are
/// linked to each date inside the period range.
class PeriodRecord {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final String? flowLevel;
  final int? painLevel;
  final List<String> moods;
  final List<String> symptoms;
  final String? discharge;
  final List<String> digestion;
  final List<String> otherFactors;

  /// Daily logs keyed by `yyyy-MM-dd`, connected to the period through date.
  final Map<String, PeriodDayLog> dailyLogs;

  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PeriodRecord({
    required this.id,
    required this.userId,
    required this.startDate,
    this.endDate,
    this.flowLevel,
    this.painLevel,
    this.moods = const [],
    this.symptoms = const [],
    this.discharge,
    this.digestion = const [],
    this.otherFactors = const [],
    this.dailyLogs = const {},
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PeriodRecord.fromMap(Map<String, dynamic> map) {
    final dailyLogsRaw = map['daily_logs'];
    final dailyLogs = <String, PeriodDayLog>{};
    if (dailyLogsRaw is Map) {
      dailyLogsRaw.forEach((key, value) {
        if (value is Map) {
          dailyLogs[key.toString()] = PeriodDayLog.fromMap(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    final parsedMoods = _toStringList(map['moods']);
    final legacyMood = map['mood']?.toString();

    return PeriodRecord(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      startDate: DateTime.tryParse(map['start_date']?.toString() ?? '') ??
          DateTime.now(),
      endDate: map['end_date'] != null
          ? DateTime.tryParse(map['end_date'].toString())
          : null,
      flowLevel: map['flow_level']?.toString(),
      painLevel: map['pain_level'] != null
          ? int.tryParse(map['pain_level'].toString())
          : null,
      moods: parsedMoods.isNotEmpty || legacyMood == null
          ? parsedMoods
          : [legacyMood],
      symptoms: _toStringList(map['symptoms']),
      discharge: map['discharge']?.toString(),
      digestion: _toStringList(map['digestion']),
      otherFactors: _toStringList(map['other_factors']),
      dailyLogs: dailyLogs,
      notes: map['notes']?.toString(),
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  String? get flowLevelDisplay {
    final flow = flowLevel;
    if (flow == null || flow.isEmpty) return null;
    return flow[0].toUpperCase() + flow.substring(1);
  }

  /// First mood for backwards compatibility with older call sites.
  String? get mood => moods.isNotEmpty ? moods.first : null;

  /// All dates covered by this period entry (start..end inclusive).
  List<DateTime> get periodDates {
    final dates = <DateTime>[];
    var day = DateTime(startDate.year, startDate.month, startDate.day);
    final end = endDate ?? startDate;
    final lastDay = DateTime(end.year, end.month, end.day);
    while (!day.isAfter(lastDay)) {
      dates.add(day);
      day = day.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Returns the log for [date] if one exists.
  PeriodDayLog? logForDate(DateTime date) {
    return dailyLogs[PeriodDayLog.formatDateKey(date)];
  }

  static List<String> _toStringList(Object? value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value];
    }
    return const [];
  }
}
