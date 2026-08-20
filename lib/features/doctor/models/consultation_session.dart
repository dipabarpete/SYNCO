import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment.dart';
import 'doctor.dart';

/// Lifecycle of a live consultation session, shared by the doctor and the
/// patient for one appointment.
///
/// Mirrors the appointment status flow (Scheduled -> Waiting -> In Progress ->
/// Completed) while tracking which participant has joined the room.
enum ConsultationStatus {
  /// No session document has been created yet (appointment confirmed but the
  /// consultation window has not started).
  scheduled,

  /// At least one participant has entered the room, waiting for the other.
  waiting,

  /// Both participants have joined and the consultation is live.
  inProgress,

  /// The consultation was explicitly ended by the doctor.
  completed,
}

/// The communication mode the patient selected for a consultation.
///
/// Stored on the booking as `consultationType` when the patient picks a
/// specific mode; when the booking only carries the legacy `online`/`offline`
/// mode we derive a sensible kind (see [resolveConsultationKind]).
enum ConsultationKind {
  video,
  call,
  chat,
  clinic;

  /// Machine value stored on the booking / session document.
  String get storageValue => switch (this) {
        ConsultationKind.video => 'video',
        ConsultationKind.call => 'call',
        ConsultationKind.chat => 'chat',
        ConsultationKind.clinic => 'clinic',
      };

  String get label => switch (this) {
        ConsultationKind.video => 'Video Consultation',
        ConsultationKind.call => 'Call Consultation',
        ConsultationKind.chat => 'Chat Consultation',
        ConsultationKind.clinic => 'In-Person Consultation',
      };

  /// The exact action label shown on the Consultation Room primary button.
  String get actionLabel => switch (this) {
        ConsultationKind.video => 'Join Video Consultation',
        ConsultationKind.call => 'Start Call',
        ConsultationKind.chat => 'Open Chat',
        ConsultationKind.clinic => 'Open Chat',
      };
}

/// Resolves the communication mode selected by the patient for [appointment].
///
/// Prefers the explicit `consultationType` stored by the booking flow when
/// present. Legacy bookings only distinguish `online`/`offline`: online maps
/// to a video consultation (the existing UI already labels online
/// consultations "Video Consultation") and offline maps to the in-person
/// clinic kind, whose room still offers chat contact with the patient.
ConsultationKind resolveConsultationKind(Appointment appointment) {
  final stored = appointment.consultationType.trim().toLowerCase();
  switch (stored) {
    case 'video':
    case 'call':
    case 'chat':
    case 'clinic':
      return ConsultationKind.values.firstWhere(
        (k) => k.storageValue == stored,
      );
    default:
      return appointment.mode == ConsultationMode.online
          ? ConsultationKind.video
          : ConsultationKind.clinic;
  }
}

/// The session document shared by both participants for one appointment,
/// stored under `consultations/{appointmentId}`.
class ConsultationSession {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final ConsultationStatus status;
  final bool doctorJoined;
  final bool patientJoined;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const ConsultationSession({
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.status,
    required this.doctorJoined,
    required this.patientJoined,
    this.startedAt,
    this.completedAt,
  });

  factory ConsultationSession.fromMap(
    String appointmentId,
    Map<String, dynamic> data,
  ) {
    return ConsultationSession(
      appointmentId: appointmentId,
      doctorId: data['doctorId']?.toString() ?? '',
      patientId: data['patientId']?.toString() ?? '',
      status: _parseStatus(data['status']),
      doctorJoined: data['doctorJoined'] == true,
      patientJoined: data['patientJoined'] == true,
      startedAt: _parseDate(data['startedAt']),
      completedAt: _parseDate(data['completedAt']),
    );
  }

  static ConsultationStatus _parseStatus(dynamic value) {
    switch (value) {
      case 'waiting':
        return ConsultationStatus.waiting;
      case 'in_progress':
        return ConsultationStatus.inProgress;
      case 'completed':
        return ConsultationStatus.completed;
      case 'scheduled':
      default:
        return ConsultationStatus.scheduled;
    }
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }

  ConsultationSession copyWith({
    ConsultationStatus? status,
    bool? doctorJoined,
    bool? patientJoined,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ConsultationSession(
      appointmentId: appointmentId,
      doctorId: doctorId,
      patientId: patientId,
      status: status ?? this.status,
      doctorJoined: doctorJoined ?? this.doctorJoined,
      patientJoined: patientJoined ?? this.patientJoined,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// User-facing status label for the Consultation Room.
String consultationStatusLabel(ConsultationStatus status) {
  switch (status) {
    case ConsultationStatus.scheduled:
      return 'Waiting for consultation';
    case ConsultationStatus.waiting:
      return 'Waiting in room';
    case ConsultationStatus.inProgress:
      return 'Consultation in progress';
    case ConsultationStatus.completed:
      return 'Consultation completed';
  }
}

/// Whether the consultation window for [appointment] is active.
/// Requires status == confirmed and current time within [startDateTime, endDateTime].
bool isConsultationWindowActive(Appointment appointment) {
  return appointment.isWindowActive;
}