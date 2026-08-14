import 'package:cloud_firestore/cloud_firestore.dart';

class CycleLog {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final int periodLength;

  const CycleLog({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    required this.periodLength,
  });

  factory CycleLog.fromMap(String id, Map<String, dynamic> data) {
    return CycleLog(
      id: id,
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: data['end_date'] != null ? (data['end_date'] as Timestamp).toDate() : null,
      cycleLength: data['cycle_length'] ?? 28,
      periodLength: data['period_length'] ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'start_date': Timestamp.fromDate(startDate),
      'end_date': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'cycle_length': cycleLength,
      'period_length': periodLength,
    };
  }

  CycleLog copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
  }) {
    return CycleLog(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
    );
  }
}
