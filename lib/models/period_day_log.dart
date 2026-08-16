/// A single day's health log attached to a period record.
///
/// Daily logs are stored inside the period entry (keyed by `yyyy-MM-dd`) so
/// symptoms, moods and other observations stay connected to their date and
/// to the period they belong to. Nothing here lives in widget memory; every
/// value round-trips through Firestore.
class PeriodDayLog {
  final DateTime date;
  final String? flowLevel;
  final int? painLevel;
  final List<String> moods;
  final List<String> symptoms;
  final String? discharge;
  final List<String> digestion;
  final List<String> otherFactors;
  final String? notes;

  const PeriodDayLog({
    required this.date,
    this.flowLevel,
    this.painLevel,
    this.moods = const [],
    this.symptoms = const [],
    this.discharge,
    this.digestion = const [],
    this.otherFactors = const [],
    this.notes,
  });

  static String formatDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime? parseDateKey(String key) => DateTime.tryParse(key);

  factory PeriodDayLog.fromMap(Map<String, dynamic> map) {
    return PeriodDayLog(
      date: DateTime.tryParse(map['date']?.toString() ?? '') ??
          DateTime(1970),
      flowLevel: map['flow_level']?.toString(),
      painLevel: map['pain_level'] != null
          ? int.tryParse(map['pain_level'].toString())
          : null,
      moods: _toStringList(map['moods']),
      symptoms: _toStringList(map['symptoms']),
      discharge: map['discharge']?.toString(),
      digestion: _toStringList(map['digestion']),
      otherFactors: _toStringList(map['other_factors']),
      notes: map['notes']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': formatDateKey(date),
      'flow_level': flowLevel,
      'pain_level': painLevel,
      'moods': moods,
      'symptoms': symptoms,
      'discharge': discharge,
      'digestion': digestion,
      'other_factors': otherFactors,
      'notes': notes,
    };
  }

  PeriodDayLog copyWith({
    String? flowLevel,
    int? painLevel,
    List<String>? moods,
    List<String>? symptoms,
    String? discharge,
    List<String>? digestion,
    List<String>? otherFactors,
    String? notes,
    bool clearPain = false,
    bool clearDischarge = false,
    bool clearNotes = false,
  }) {
    return PeriodDayLog(
      date: date,
      flowLevel: flowLevel ?? this.flowLevel,
      painLevel: clearPain ? null : (painLevel ?? this.painLevel),
      moods: moods ?? this.moods,
      symptoms: symptoms ?? this.symptoms,
      discharge: clearDischarge ? null : (discharge ?? this.discharge),
      digestion: digestion ?? this.digestion,
      otherFactors: otherFactors ?? this.otherFactors,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
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
