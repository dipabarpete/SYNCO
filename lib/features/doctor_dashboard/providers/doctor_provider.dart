import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/services/doctor_service.dart';
import '../../../core/backend.dart';

// Provides the singleton service
final _dashboardDoctorServiceProvider = Provider<DoctorService>((ref) {
  return DoctorService();
});

// Provides all appointments for the currently logged in doctor
final doctorAppointmentsProvider = StreamProvider<List<Appointment>>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null || Backend.firestore == null) {
    return Stream.value([]);
  }

  final doctorId = user.id; // Assume user.id is the doctorId
  final service = ref.watch(_dashboardDoctorServiceProvider);
  return service.streamDoctorAppointments(doctorId);
});

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
    return a.date.year == now.year && a.date.month == now.month && a.date.day == now.day; 
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
