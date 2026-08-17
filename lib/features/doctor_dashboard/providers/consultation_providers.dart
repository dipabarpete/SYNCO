import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/consultation_session.dart';
import '../../doctor/services/consultation_service.dart';
import '../providers/doctor_provider.dart';

/// Singleton service for consultation sessions.
final consultationServiceProvider = Provider<ConsultationService>((ref) {
  return ConsultationService();
});

/// Live state of the shared consultation session for an appointment.
///
/// `null` while no session document exists yet (scheduled state).
final consultationSessionProvider =
    StreamProvider.autoDispose.family<ConsultationSession?, String>((ref, id) {
  return ref.watch(consultationServiceProvider).streamConsultation(id);
});

/// Loads a single appointment by ID (with its doctor), used when opening the
/// Consultation Room directly from a notification.
final appointmentByIdProvider =
    FutureProvider.autoDispose.family<Appointment?, String>((ref, id) {
  return ref.watch(doctorServiceProvider).getAppointment(id);
});

/// The doctor's confirmed appointments that can still enter a consultation
/// room (not completed, not cancelled/declined), sorted by scheduled start.
///
/// Demo records (`demo_*`) are excluded: they have no backend booking and
/// must never open a real consultation room.
final activeConsultationsProvider = Provider<List<Appointment>>((ref) {
  final all = ref.watch(doctorAppointmentsProvider).value ?? [];
  final active = all.where((a) {
    if (a.status != AppointmentStatus.confirmed) return false;
    if (a.id.startsWith('demo_')) return false;
    return true;
  }).toList();
  active.sort((a, b) {
    final ta = a.startDateTime ?? DateTime(9999);
    final tb = b.startDateTime ?? DateTime(9999);
    return ta.compareTo(tb);
  });
  return active;
});

/// The most relevant consultation for the room tab: the earliest one whose
/// window is already active, otherwise the next upcoming one.
Appointment? pickMostRelevantConsultation(List<Appointment> appointments) {
  if (appointments.isEmpty) return null;
  for (final a in appointments) {
    if (isConsultationWindowActive(a)) return a;
  }
  return appointments.first;
}

/// Whether the logged-in doctor is the doctor assigned to [appointmentId].
/// Room access is denied for any other doctor.
final doctorConsultationAccessProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, appointmentId) async {
  final doctorId = ref.watch(currentDoctorIdProvider);
  if (doctorId == null) return false;
  return ref
      .watch(consultationServiceProvider)
      .isAssignedDoctor(appointmentId, doctorId);
});

/// Whether the logged-in user is the patient of [appointmentId]. Room access
/// is denied for any other user.
final patientConsultationAccessProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, appointmentId) async {
  final userId = ref.watch(authNotifierProvider).user?.id;
  if (userId == null) return false;
  return ref
      .watch(consultationServiceProvider)
      .isAssignedPatient(appointmentId, userId);
});