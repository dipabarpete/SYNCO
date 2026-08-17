import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import '../models/doctor_review.dart';
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

  /// Loads a single appointment (booking) by ID together with its doctor.
  /// Returns `null` when the booking or its doctor does not exist.
  Future<Appointment?> getAppointment(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    if (!doc.exists) return null;
    final data = doc.data() ?? {};
    final doctorId = data['doctorId'] as String?;
    if (doctorId == null) return null;
    final doctor = await getDoctor(doctorId);
    if (doctor == null) return null;
    return Appointment.fromMap(doc.id, data, doctor);
  }

  // Create a doctor profile (used during sign up)
  Future<void> createDoctorProfile(Doctor doctor) async {
    await _db.collection('doctors').doc(doctor.id).set(doctor.toMap(), SetOptions(merge: true));
  }

  // Update a doctor profile
  Future<void> updateDoctorProfile(String doctorId, Map<String, dynamic> data) async {
    await _db.collection('doctors').doc(doctorId).update(data);
  }

  /// Adds a weekly availability slot for the doctor and makes it usable by the
  /// existing patient booking flow.
  ///
  /// The availability is written into the existing doctor document fields the
  /// booking flow already reads (`availableDays` + `timeSlots`), so no
  /// separate/duplicate backend system is created. Each entry is additionally
  /// recorded in the structured `availabilitySlots` list (with the
  /// consultation mode) so the portal can display what was saved.
  ///
  /// [start] and [end] use "h:mm AM/PM" formatting. [mode] is one of
  /// 'online', 'offline' or 'both'.
  ///
  /// Throws an [ArgumentError] when the end time is not after the start time.
  Future<void> addAvailability({
    required String doctorId,
    required String day,
    required String start,
    required String end,
    required String mode,
  }) async {
    final slots = _hourlySlots(start, end);
    if (slots.isEmpty) {
      throw ArgumentError('End time must be after start time.');
    }
    await _db.collection('doctors').doc(doctorId).update({
      'availableDays': FieldValue.arrayUnion([day]),
      'timeSlots': FieldValue.arrayUnion(slots),
      'availabilitySlots': FieldValue.arrayUnion([
        {
          'day': day,
          'start': start,
          'end': end,
          'mode': mode,
          'updatedAt': DateTime.now().toIso8601String(),
        }
      ]),
    });
  }

  /// Generates hourly time slots between [start] and [end] (exclusive of the
  /// end time), formatted like the existing slots, e.g. "09:00 AM".
  static List<String> _hourlySlots(String start, String end) {
    final startMinutes = _timeToMinutes(start);
    final endMinutes = _timeToMinutes(end);
    if (startMinutes == null || endMinutes == null || endMinutes <= startMinutes) {
      return const [];
    }
    final slots = <String>[];
    for (var minutes = startMinutes; minutes < endMinutes; minutes += 60) {
      final hour12 = (minutes ~/ 60) % 12;
      final displayHour = hour12 == 0 ? 12 : hour12;
      final meridian = minutes ~/ 60 < 12 ? 'AM' : 'PM';
      slots.add('${displayHour.toString().padLeft(2, '0')}:'
          '${(minutes % 60).toString().padLeft(2, '0')} $meridian');
    }
    return slots;
  }

  /// Parses "h:mm AM/PM" (also accepts 24-hour "hh:mm") into minutes of the
  /// day, or `null` when the value is not a valid time.
  static int? _timeToMinutes(String value) {
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    final meridian = match.group(3)?.toUpperCase();
    if (hour > 23 || minute > 59) return null;
    if (meridian == 'PM' && hour < 12) hour += 12;
    if (meridian == 'AM' && hour == 12) hour = 0;
    return hour * 60 + minute;
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
        } else if (status == 'cancelled') {
          title = 'Appointment Cancelled';
          subtitle = 'Your appointment with $doctorName has been cancelled.';
          iconCode = 0xe14c; // cancel
          iconColorHex = 'FF9E93A8';
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

  // ---------------------------------------------------------------------------
  // DOCTOR REVIEWS
  // ---------------------------------------------------------------------------

  /// Streams the public reviews for a doctor (newest first).
  ///
  /// Reviews live under `doctors/{doctorId}/reviews/{consultationId}`.
  Stream<List<DoctorReview>> streamDoctorReviews(String doctorId) {
    return _db
        .collection('doctors')
        .doc(doctorId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(DoctorReview.fromFirestore).toList());
  }

  /// Returns the review attached to a consultation, or `null` when the user
  /// has not reviewed that completed consultation yet.
  Future<DoctorReview?> getReviewForConsultation(
    String doctorId,
    String consultationId,
  ) async {
    final doc = await _db
        .collection('doctors')
        .doc(doctorId)
        .collection('reviews')
        .doc(consultationId)
        .get();
    if (!doc.exists) return null;
    return DoctorReview.fromFirestore(doc);
  }

  /// Submits a review for a completed consultation and updates the doctor's
  /// overall rating.
  ///
  /// Validations enforced here (and mirrored in `firestore.rules`):
  /// - Rating must be between 1 and 5.
  /// - The consultation must exist and be `completed`.
  /// - The consultation must belong to [userId] and [doctorId].
  /// - Only one review per consultation (the review document ID is the
  ///   consultation ID).
  ///
  /// Throws an [ArgumentError] with a user-facing message when validation
  /// fails.
  Future<void> submitDoctorReview({
    required String doctorId,
    required String consultationId,
    required String userId,
    required int rating,
    required String text,
    required String reviewerName,
  }) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError('Please select a rating between 1 and 5 stars.');
    }

    // The review can only exist for a completed consultation with this user.
    final bookingDoc =
        await _db.collection('bookings').doc(consultationId).get();
    if (!bookingDoc.exists) {
      throw ArgumentError('This consultation could not be found.');
    }
    final booking = bookingDoc.data() ?? {};
    if (booking['status'] != 'completed') {
      throw ArgumentError(
        'You can review a doctor only after the consultation is completed.',
      );
    }
    if (booking['userId'] != userId) {
      throw ArgumentError('This consultation does not belong to you.');
    }
    if (booking['doctorId'] != doctorId) {
      throw ArgumentError('This consultation is not with this doctor.');
    }

    // One review per consultation.
    final reviewRef = _db
        .collection('doctors')
        .doc(doctorId)
        .collection('reviews')
        .doc(consultationId);
    if ((await reviewRef.get()).exists) {
      throw ArgumentError('You have already submitted a review for this '
          'consultation.');
    }

    // Transactionally save the review and recompute the doctor's rating from
    // the real submitted ratings.
    await _db.runTransaction((txn) async {
      final doctorDoc = await txn.get(_db.collection('doctors').doc(doctorId));
      if (!doctorDoc.exists) {
        throw ArgumentError('This doctor could not be found.');
      }
      final doctorData = doctorDoc.data() ?? {};
      final reviewCount = (doctorData['reviewCount'] is num)
          ? (doctorData['reviewCount'] as num).toInt()
          : 0;
      final ratingSum = (doctorData['ratingSum'] is num)
          ? (doctorData['ratingSum'] as num).toDouble()
          : 0.0;

      final newCount = reviewCount + 1;
      final newSum = ratingSum + rating;
      final newAverage = double.parse((newSum / newCount).toStringAsFixed(1));

      txn.set(reviewRef, {
        'doctorId': doctorId,
        'userId': userId,
        'consultationId': consultationId,
        'rating': rating,
        'text': text,
        'reviewerName': reviewerName,
        'createdAt': FieldValue.serverTimestamp(),
      });
      txn.update(_db.collection('doctors').doc(doctorId), {
        'rating': newAverage,
        'ratingSum': newSum,
        'reviewCount': newCount,
      });
    });
  }
}
