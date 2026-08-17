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

  /// Reason for consultation / health issue, when the booking provides one.
  final String issue;

  /// Patient age, when the booking provides one.
  final int? age;

  /// The communication mode selected by the patient for this consultation:
  /// 'video' | 'call' | 'chat'. Empty for legacy bookings that only stored
  /// `online`/`offline` (the room then derives the kind from [mode]).
  final String consultationType;

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
    this.issue = '',
    this.age,
    this.consultationType = '',
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
      issue: data['issue']?.toString() ??
          data['reason']?.toString() ??
          data['reasonForConsultation']?.toString() ??
          '',
      age: _parseAge(data['age']),
      consultationType:
          data['consultationType']?.toString() ?? data['type']?.toString() ?? '',
    );
  }

  static int? _parseAge(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
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
      issue: issue,
      age: age,
      consultationType: consultationType,
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

  /// The exact scheduled start of the consultation, combining [date] with
  /// the [slot] time. `null` when the slot value is not a valid time.
  DateTime? get startDateTime {
    return consultationSlotDateTime(date, slot);
  }
}

/// Combines an appointment [date] with a slot like "04:00 PM" into the exact
/// scheduled start time, or `null` when the slot is not a valid time.
DateTime? consultationSlotDateTime(DateTime date, String slot) {
  final minutes = consultationSlotToMinutes(slot);
  if (minutes == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    minutes ~/ 60,
    minutes % 60,
  );
}

/// Parses a slot like "04:00 PM" (or 24-hour "16:00") into minutes of the
/// day, or `null` when the value is not a valid time.
int? consultationSlotToMinutes(String slot) {
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})\s*(AM|PM)?$',
    caseSensitive: false,
  ).firstMatch(slot.trim());
  if (match == null) return null;
  var hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final meridian = match.group(3)?.toUpperCase();
  if (hour > 23 || minute > 59) return null;
  if (meridian == 'PM' && hour < 12) hour += 12;
  if (meridian == 'AM' && hour == 12) hour = 0;
  return hour * 60 + minute;
}
