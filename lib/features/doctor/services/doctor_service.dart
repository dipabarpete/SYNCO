import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import '../models/appointment.dart';
import '../../../core/services/ai_summary_service.dart';
import '../../../core/services/notification_service.dart';

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

  // Create a doctor profile (used during sign up)
  Future<void> createDoctorProfile(Doctor doctor) async {
    await _db.collection('doctors').doc(doctor.id).set(doctor.toMap(), SetOptions(merge: true));
  }

  // Update a doctor profile
  Future<void> updateDoctorProfile(String doctorId, Map<String, dynamic> data) async {
    await _db.collection('doctors').doc(doctorId).update(data);
  }

  // Book an appointment
  Future<void> bookAppointment({
    required String userId,
    required String doctorId,
    required String doctorName,
    required String date,
    required String time,
    required String mode,
    required int fee,
    required String patientName,
  }) async {
    final appointmentRef = _db.collection('bookings').doc();
    final appointmentId = appointmentRef.id;

    await appointmentRef.set({
      'userId': userId,
      'doctorId': doctorId,
      'date': date,
      'time': time,
      'mode': mode,
      'fee': fee,
      'patientName': patientName,
      'status': 'requested',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Generate and store the AI Health Summary
    final aiSummary = AISummaryService.generateMockSummary(
      patientName: patientName,
      doctorName: doctorName,
      reasonForVisit: 'General Consultation',
    );

    await _db
        .collection('users')
        .doc(userId)
        .collection('health_summaries')
        .doc(appointmentId)
        .set(aiSummary);

    // Create the secure Chat Document
    await _db.collection('chats').doc(appointmentId).set({
      'patientId': userId,
      'doctorId': doctorId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Notify the Doctor
    await NotificationService().saveAppNotification(
      userId: doctorId,
      title: 'New Appointment Request',
      subtitle: '$patientName requested an appointment.',
      iconCode: 0xe0b0, // calendar_today
      iconColorHex: 'FF2196F3',
    );
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status,
    });

    final bookingDoc = await _db.collection('bookings').doc(bookingId).get();
    if (bookingDoc.exists) {
      final data = bookingDoc.data();
      final userId = data?['userId'];
      final doctorId = data?['doctorId'];
      
      if (userId != null && doctorId != null) {
        final doctor = await getDoctor(doctorId);
        final doctorName = doctor?.name ?? 'Your Doctor';
        
        String title = '';
        String subtitle = '';
        int iconCode = 0xe88e; // info
        String iconColorHex = 'FF9C27B0';
        
        if (status == 'confirmed') {
          title = 'Appointment Confirmed!';
          subtitle = '$doctorName has accepted your consultation request.';
          iconCode = 0xe86c; // check_circle
          iconColorHex = 'FF45B69C'; // mintGreen
        } else if (status == 'declined') {
          title = 'Appointment Declined';
          subtitle = '$doctorName could not accept your request at this time.';
          iconCode = 0xe14c; // cancel
          iconColorHex = 'FFF44336';
        }
        
        if (title.isNotEmpty) {
           await NotificationService().saveAppNotification(
             userId: userId,
             title: title,
             subtitle: subtitle,
             iconCode: iconCode,
             iconColorHex: iconColorHex,
           );
        }
      }
    }
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
