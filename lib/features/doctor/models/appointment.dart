import 'doctor.dart';

/// Lifecycle of a user's consultation appointment.
///
/// Immediately after booking an appointment becomes [AppointmentStatus.requested].
/// Only after the doctor accepts does it move to [AppointmentStatus.confirmed].
enum AppointmentStatus { requested, confirmed, declined, cancelled }

class Appointment {
  final String id;
  final Doctor doctor;
  final ConsultationMode mode;
  final DateTime date;
  final String slot;
  final int fee;
  final String patientName;
  final DateTime createdAt;
  final AppointmentStatus status;

  const Appointment({
    required this.id,
    required this.doctor,
    required this.mode,
    required this.date,
    required this.slot,
    required this.fee,
    required this.patientName,
    required this.createdAt,
    this.status = AppointmentStatus.requested,
  });

  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      id: id,
      doctor: doctor,
      mode: mode,
      date: date,
      slot: slot,
      fee: fee,
      patientName: patientName,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  static const _fullMonths = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _shortMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  /// e.g. "20 August"
  String get formattedDate =>
      '${date.day} ${_fullMonths[date.month - 1]}';

  /// e.g. "20 Aug"
  String get formattedDateShort =>
      '${date.day} ${_shortMonths[date.month - 1]}';

  /// e.g. "Video Consultation"
  String get modeName => mode == ConsultationMode.online
      ? 'Video Consultation'
      : 'Offline Consultation';

  /// User-facing status label.
  String get statusLabel {
    switch (status) {
      case AppointmentStatus.requested:
        return 'Awaiting Doctor Confirmation';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.declined:
        return 'Request Declined';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }
}
