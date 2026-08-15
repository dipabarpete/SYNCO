import 'doctor.dart';

/// Lifecycle of a user's consultation appointment.
///
/// Immediately after booking an appointment becomes [AppointmentStatus.requested].
/// Only after the doctor accepts does it move to [AppointmentStatus.confirmed].
enum AppointmentStatus { requested, confirmed, declined, cancelled, completed }

class Appointment {
  final String id;
  final Doctor doctor;
  final ConsultationMode mode;
  final DateTime date;
  final String slot;
  final int fee;
  final String patientName;
  final String userId;
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
    required this.userId,
    required this.createdAt,
    this.status = AppointmentStatus.requested,
  });

  factory Appointment.fromMap(String id, Map<String, dynamic> data, Doctor doctor) {
    AppointmentStatus parsedStatus = AppointmentStatus.requested;
    switch (data['status']) {
      case 'confirmed':
        parsedStatus = AppointmentStatus.confirmed;
        break;
      case 'declined':
        parsedStatus = AppointmentStatus.declined;
        break;
      case 'cancelled':
        parsedStatus = AppointmentStatus.cancelled;
        break;
      case 'completed':
        parsedStatus = AppointmentStatus.completed;
        break;
      case 'requested':
      default:
        parsedStatus = AppointmentStatus.requested;
        break;
    }

    ConsultationMode parsedMode = data['mode'] == 'offline' 
        ? ConsultationMode.offline 
        : ConsultationMode.online;

    return Appointment(
      id: id,
      doctor: doctor,
      mode: parsedMode,
      date: data['date'] != null ? DateTime.tryParse(data['date']) ?? DateTime.now() : DateTime.now(),
      slot: data['time'] ?? data['slot'] ?? '',
      fee: data['fee'] ?? doctor.consultationFee,
      patientName: data['patientName'] ?? 'Unknown Patient',
      userId: data['userId'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
      status: parsedStatus,
    );
  }

  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      id: id,
      doctor: doctor,
      mode: mode,
      date: date,
      slot: slot,
      fee: fee,
      patientName: patientName,
      userId: userId,
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
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }
}
