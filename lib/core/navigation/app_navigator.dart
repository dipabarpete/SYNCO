import 'package:flutter/material.dart';
import '../../models/user_profile.dart';
import '../../features/doctor/screens/patient_consultation_screen.dart';
import '../../features/doctor_dashboard/screens/consultation_room_screen.dart';

/// Global navigation helpers for deep links that must work while the app is
/// not focused on a specific screen (e.g. notification taps).
class AppNavigator {
  AppNavigator._();

  /// Key attached to the root MaterialApp so context-less pushes are
  /// possible from notification handlers.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Opens the Consultation Room for [appointmentId], choosing the doctor
  /// portal room or the patient room based on [role]. Both sides enter the
  /// same session for that appointment.
  static void openConsultationRoom(String appointmentId, UserRole role) {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => role == UserRole.doctor
            ? DoctorConsultationRoomScreen(appointmentId: appointmentId)
            : PatientConsultationScreen(appointmentId: appointmentId),
      ),
    );
  }
}