import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorReview {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String appointmentId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const DoctorReview({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.appointmentId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory DoctorReview.fromMap(String id, Map<String, dynamic> data) {
    return DoctorReview(
      id: id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? 'Anonymous',
      appointmentId: data['appointmentId'] ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 5,
      comment: data['comment'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'appointmentId': appointmentId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
