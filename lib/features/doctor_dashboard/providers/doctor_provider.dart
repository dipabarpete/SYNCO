import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/doctor.dart';
import '../../doctor/services/doctor_service.dart';
import '../../../core/backend.dart';

// Provides the singleton service
final _dashboardDoctorServiceProvider = Provider<DoctorService>((ref) {
  return DoctorService();
});

/// The id of the currently logged-in user. For the doctor portal this id is
/// also the id of the doctor profile in `doctors/{doctorId}`.
final currentDoctorIdProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).user?.id;
});

/// The logged-in doctor's profile, loaded from `doctors/{doctorId}`.
///
/// Falls back to `null` while loading or when no doctor profile exists yet.
final currentDoctorProvider = FutureProvider<Doctor?>((ref) {
  final doctorId = ref.watch(currentDoctorIdProvider);
  if (doctorId == null) return Future.value(null);
  return ref.watch(_dashboardDoctorServiceProvider).getDoctor(doctorId);
});

// Provides all appointments for the currently logged in doctor
final doctorAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final doctorId = ref.watch(currentDoctorIdProvider);
  if (doctorId == null || Backend.firestore == null) {
    return Stream.value([]);
  }

  final service = ref.watch(_dashboardDoctorServiceProvider);
  return service.streamDoctorAppointments(doctorId);
});

/// Whether [a] and [b] fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Formats a doctor name for display, avoiding a duplicated "Dr." prefix.
String formatDoctorDisplayName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return 'Doctor';
  final lower = trimmed.toLowerCase();
  if (lower == 'dr' || lower.startsWith('dr.') || lower.startsWith('dr ')) {
    return trimmed;
  }
  return 'Dr. $trimmed';
}

// Derived: Pending Requests
final pendingRequestsProvider = Provider<List<Appointment>>((ref) {
  final all = ref.watch(doctorAppointmentsProvider).value ?? [];
  return all.where((a) => a.status == AppointmentStatus.requested).toList();
});

// Derived: Today's Appointments (Confirmed)
final todayAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final all = ref.watch(doctorAppointmentsProvider).value ?? [];
  final now = DateTime.now();
  return all.where((a) {
    if (a.status != AppointmentStatus.confirmed) return false;
    // Check if appointment is today.
    return isSameDay(a.date, now);
  }).toList();
});

// Derived: Upcoming Appointments (Confirmed, not today)
final upcomingAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final all = ref.watch(doctorAppointmentsProvider).value ?? [];
  final now = DateTime.now();
  return all.where((a) {
    if (a.status != AppointmentStatus.confirmed) return false;
    final aptDate = DateTime(a.date.year, a.date.month, a.date.day);
    final today = DateTime(now.year, now.month, now.day);
    return aptDate.isAfter(today);
  }).toList();
});

// Derived: Completed Appointments
final completedAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final all = ref.watch(doctorAppointmentsProvider).value ?? [];
  return all.where((a) => a.status == AppointmentStatus.completed).toList();
});

// Derived: Appointments completed by the doctor today.
final completedTodayAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final all = ref.watch(doctorAppointmentsProvider).value ?? [];
  final now = DateTime.now();
  return all.where((a) {
    if (a.status != AppointmentStatus.completed) return false;
    // Appointment happened today and was marked completed.
    return isSameDay(a.date, now);
  }).toList();
});

/// A patient of the logged-in doctor, derived from the doctor's bookings.
///
/// No separate patient storage is created - every patient is derived from
/// the existing `bookings` data.
class DoctorPatient {
  final String userId;
  final String patientName;
  final int appointmentCount;
  final Appointment lastAppointment;

  const DoctorPatient({
    required this.userId,
    required this.patientName,
    required this.appointmentCount,
    required this.lastAppointment,
  });
}

// Derived: Unique patients of the logged-in doctor (from bookings only).
final doctorPatientsProvider = Provider<List<DoctorPatient>>((ref) {
  final all = ref.watch(doctorAppointmentsProvider).value ?? [];
  final grouped = <String, List<Appointment>>{};
  for (final a in all) {
    if (a.userId.isEmpty) continue;
    grouped.putIfAbsent(a.userId, () => []).add(a);
  }
  final patients = grouped.entries.map((entry) {
    final appts = entry.value..sort((a, b) => b.date.compareTo(a.date));
    final last = appts.first;
    return DoctorPatient(
      userId: entry.key,
      patientName: last.patientName,
      appointmentCount: appts.length,
      lastAppointment: last,
    );
  }).toList();
  patients.sort((a, b) => b.lastAppointment.date.compareTo(a.lastAppointment.date));
  return patients;
});

class DoctorDashboardController {
  final Ref _ref;
  DoctorDashboardController(this._ref);

  Future<void> updateStatus(String bookingId, String status) async {
    final service = _ref.read(_dashboardDoctorServiceProvider);
    await service.updateAppointmentStatus(bookingId, status);
  }
}

final doctorDashboardControllerProvider = Provider<DoctorDashboardController>((ref) {
  return DoctorDashboardController(ref);
});
