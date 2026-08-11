class PeriodRecord {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime? endDate;
  final String? flowLevel;
  final int? painLevel;
  final String? mood;
  final List<String> symptoms;
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
    this.mood,
    this.symptoms = const [],
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory PeriodRecord.fromMap(Map<String, dynamic> map) {
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
      mood: map['mood']?.toString(),
      symptoms: (map['symptoms'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          const [],
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
}