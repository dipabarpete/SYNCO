import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';

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
  Future<void> bookAppointment({
    required String userId, 
    required String doctorId, 
    required String date, 
    required String time,
    required String mode,
    required int fee,
    required String patientName,
  }) async {
    await _db.collection('bookings').add({
      'userId': userId,
      'doctorId': doctorId,
      'date': date,
      'time': time,
      'mode': mode,
      'fee': fee,
      'patientName': patientName,
      'status': 'requested', // Starts as requested
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status,
    });
  }

  // Stream user's appointments
  Stream<List<Appointment>> streamUserAppointments(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<Appointment> appointments = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final doctorId = data['doctorId'] as String?;
        if (doctorId != null) {
          final doctor = await getDoctor(doctorId);
          if (doctor != null) {
            appointments.add(Appointment.fromMap(doc.id, data, doctor));
          }
        }
      }
      appointments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return appointments;
    });
  }

  // Stream doctor's appointments
  Stream<List<Appointment>> streamDoctorAppointments(String doctorId) {
    return _db
        .collection('bookings')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .asyncMap((snapshot) async {
      final doctor = await getDoctor(doctorId);
      if (doctor == null) return [];
      
      var list = snapshot.docs.map((doc) {
        return Appointment.fromMap(doc.id, doc.data(), doctor);
      }).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Fallback seeder method to mock data if Firestore is empty
  Future<void> seedMockDoctors(List<Doctor> fallbackDoctors) async {
    try {
      debugPrint('[DoctorService] Forcibly seeding ${fallbackDoctors.length} mock doctors...');
      for (var doctor in fallbackDoctors) {
        await _db.collection('doctors').doc(doctor.id).set(doctor.toMap());
      }
      debugPrint('[DoctorService] Seeding complete.');
    } catch (e) {
      debugPrint('[DoctorService] Error seeding mock doctors: $e');
      rethrow;
    }
  }
}
