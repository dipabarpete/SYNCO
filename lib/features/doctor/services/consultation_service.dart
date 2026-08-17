import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/backend.dart';
import '../models/consultation_session.dart';

/// Backend wiring for the Consultation Room.
///
/// A consultation session lives in `consultations/{appointmentId}` and is the
/// single shared room for the doctor and the patient of that appointment.
/// Both participants write their join state to the same document, so opening
/// the room from either side always enters the same session.
///
/// Authorization is enforced twice: client-side here (bookings/consultations
/// must belong to the participant) and server-side in `firestore.rules`.
class ConsultationService {
  FirebaseFirestore? get _firestore => Backend.firestore;

  DocumentReference<Map<String, dynamic>> _sessionDoc(String appointmentId) {
    return _firestore!.collection('consultations').doc(appointmentId);
  }

  /// Live state of the consultation session for [appointmentId]. Emits
  /// `null` while no session document exists yet (scheduled state).
  Stream<ConsultationSession?> streamConsultation(String appointmentId) {
    if (_firestore == null) {
      debugPrint('[ConsultationService] Firestore is null.');
      return Stream.value(null);
    }
    return _sessionDoc(appointmentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ConsultationSession.fromMap(doc.id, doc.data() ?? {});
    });
  }

  /// Fetches the raw booking document for [appointmentId].
  ///
  /// Used to authorize room access: the caller must be either the booking's
  /// patient or its doctor.
  Future<Map<String, dynamic>?> getBooking(String appointmentId) async {
    if (_firestore == null) return null;
    try {
      final doc = await _firestore!
          .collection('bookings')
          .doc(appointmentId)
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      debugPrint('[ConsultationService] Error loading booking: $e');
      return null;
    }
  }

  /// Whether [userId] is allowed to join the consultation for
  /// [appointmentId]: either the booking's patient or its doctor.
  Future<bool> canJoin(String appointmentId, String userId) async {
    final booking = await getBooking(appointmentId);
    if (booking == null) return false;
    return booking['userId'] == userId || booking['doctorId'] == userId;
  }

  /// Whether [userId] is the doctor assigned to [appointmentId].
  Future<bool> isAssignedDoctor(String appointmentId, String userId) async {
    final booking = await getBooking(appointmentId);
    if (booking == null) return false;
    return booking['doctorId'] == userId;
  }

  /// Whether [userId] is the patient of [appointmentId].
  Future<bool> isAssignedPatient(String appointmentId, String userId) async {
    final booking = await getBooking(appointmentId);
    if (booking == null) return false;
    return booking['userId'] == userId;
  }

  /// Creates the shared session document for a confirmed appointment (if it
  /// does not exist yet) and marks [userId] as joined.
  ///
  /// [role] is 'doctor' or 'patient'. When both participants have joined the
  /// status becomes `in_progress`. Unauthorized callers are rejected.
  Future<ConsultationSession> join({
    required String appointmentId,
    required String userId,
    required String role,
  }) async {
    if (_firestore == null) {
      throw StateError('Firestore is not available.');
    }

    final booking = await getBooking(appointmentId);
    if (booking == null) {
      throw ArgumentError('This appointment does not exist.');
    }
    final patientId = booking['userId']?.toString() ?? '';
    final doctorId = booking['doctorId']?.toString() ?? '';
    final isDoctor = role == 'doctor';
    if ((isDoctor && userId != doctorId) ||
        (!isDoctor && userId != patientId)) {
      throw ArgumentError('You are not part of this consultation.');
    }

    final docRef = _sessionDoc(appointmentId);
    final snapshot = await docRef.get();
    final existing = snapshot.data() ?? <String, dynamic>{};

    if (snapshot.exists) {
      final doctorJoined = (existing['doctorJoined'] == true) || isDoctor;
      final patientJoined = (existing['patientJoined'] == true) || !isDoctor;
      final update = <String, dynamic>{
        'doctorJoined': doctorJoined,
        'patientJoined': patientJoined,
        'status': (doctorJoined && patientJoined)
            ? 'in_progress'
            : (existing['status'] ?? 'waiting'),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (doctorJoined && patientJoined && existing['startedAt'] == null) {
        update['startedAt'] = FieldValue.serverTimestamp();
      }
      await docRef.update(update);
    } else {
      await docRef.set({
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'patientId': patientId,
        'doctorJoined': isDoctor,
        'patientJoined': !isDoctor,
        'status': 'waiting',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final updated = await docRef.get();
    return ConsultationSession.fromMap(appointmentId, updated.data() ?? {});
  }

  /// Marks the consultation as completed. Only the assigned doctor may end a
  /// consultation; the appointment itself is completed through the existing
  /// booking flow (which moves it into history and unlocks reviews).
  Future<void> markCompleted(String appointmentId, String doctorId) async {
    if (_firestore == null) return;
    final docRef = _sessionDoc(appointmentId);
    final snapshot = await docRef.get();
    if (snapshot.exists && snapshot.data()?['doctorId'] != doctorId) {
      throw ArgumentError('Only the assigned doctor can end this '
          'consultation.');
    }
    await docRef.set(
      {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}