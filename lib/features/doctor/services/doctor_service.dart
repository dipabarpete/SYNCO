import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';

class DoctorService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream all doctors
  Stream<List<Doctor>> streamDoctors() {
    return _db
        .collection('doctors')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList());
  }

  // Get a specific doctor by ID
  Future<Doctor?> getDoctor(String doctorId) async {
    final doc = await _db.collection('doctors').doc(doctorId).get();
    if (doc.exists) {
      return Doctor.fromFirestore(doc);
    }
    return null;
  }

  // Book an appointment
  Future<void> bookAppointment(String userId, String doctorId, String date, String time) async {
    await _db.collection('bookings').add({
      'userId': userId,
      'doctorId': doctorId,
      'date': date,
      'time': time,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Stream user's appointments
  Stream<List<Map<String, dynamic>>> streamUserAppointments(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  // Fallback seeder method to mock data if Firestore is empty
  Future<void> seedMockDoctors(List<Doctor> fallbackDoctors) async {
    final query = await _db.collection('doctors').limit(1).get();
    if (query.docs.isNotEmpty) return; // already seeded

    for (var doctor in fallbackDoctors) {
      await _db.collection('doctors').doc(doctor.id).set(doctor.toMap());
    }
  }
}
