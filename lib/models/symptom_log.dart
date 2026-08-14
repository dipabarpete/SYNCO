import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomLog {
  final String id;
  final DateTime date;
  final Map<String, dynamic> symptoms;
  final String? note;

  const SymptomLog({
    required this.id,
    required this.date,
    required this.symptoms,
    this.note,
  });

  factory SymptomLog.fromMap(String id, Map<String, dynamic> data) {
    return SymptomLog(
      id: id,
      date: (data['date'] as Timestamp).toDate(),
      symptoms: data['symptoms'] ?? {},
      note: data['note'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'symptoms': symptoms,
      'note': note,
    };
  }

  SymptomLog copyWith({
    String? id,
    DateTime? date,
    Map<String, dynamic>? symptoms,
    String? note,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      note: note ?? this.note,
    );
  }
}
