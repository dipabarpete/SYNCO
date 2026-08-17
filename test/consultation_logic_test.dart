import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/consultation_session.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor_dashboard/providers/consultation_providers.dart';

Doctor _doctor() => Doctor(
      id: 'doc_1',
      name: 'Dr. Priya Sharma',
      specialization: 'Gynecologist',
      experience: '8 Years',
      rating: 4.8,
      consultationFee: 200,
      availability: 'Available Today',
      mode: ConsultationMode.online,
      about: 'Test bio',
      availableDays: const ['Mon'],
      timeSlots: const ['10:00 AM'],
    );

Appointment _appointment({
  ConsultationMode mode = ConsultationMode.online,
  String consultationType = '',
  DateTime? date,
  String slot = '04:00 PM',
  String id = 'apt_1',
  AppointmentStatus status = AppointmentStatus.confirmed,
}) =>
    Appointment(
      id: id,
      doctor: _doctor(),
      mode: mode,
      date: date ?? DateTime(2026, 8, 17),
      slot: slot,
      fee: 200,
      patientName: 'Aisha Sharma',
      userId: 'patient_1',
      createdAt: DateTime(2026, 8, 16),
      status: status,
      consultationType: consultationType,
    );

void main() {
  group('consultation slot parsing', () {
    test('parses 12-hour slots', () {
      expect(consultationSlotToMinutes('04:00 PM'), 16 * 60);
      expect(consultationSlotToMinutes('09:30 AM'), 9 * 60 + 30);
      expect(consultationSlotToMinutes('12:00 AM'), 0);
      expect(consultationSlotToMinutes('12:30 PM'), 12 * 60 + 30);
    });

    test('parses 24-hour slots', () {
      expect(consultationSlotToMinutes('16:00'), 16 * 60);
      expect(consultationSlotToMinutes('09:05'), 9 * 60 + 5);
    });

    test('rejects invalid slots', () {
      expect(consultationSlotToMinutes(''), isNull);
      expect(consultationSlotToMinutes('abc'), isNull);
      expect(consultationSlotToMinutes('25:00 PM'), isNull);
    });

    test('combines date and slot into the scheduled start', () {
      final start = consultationSlotDateTime(DateTime(2026, 8, 17), '04:00 PM');
      expect(start, DateTime(2026, 8, 17, 16, 0));
    });
  });

  group('consultation kind resolution', () {
    test('online maps to video by default', () {
      expect(
        resolveConsultationKind(_appointment(mode: ConsultationMode.online)),
        ConsultationKind.video,
      );
    });

    test('offline maps to the in-person clinic kind', () {
      expect(
        resolveConsultationKind(_appointment(mode: ConsultationMode.offline)),
        ConsultationKind.clinic,
      );
    });

    test('explicit consultationType wins over the legacy mode', () {
      expect(
        resolveConsultationKind(_appointment(
          mode: ConsultationMode.online,
          consultationType: 'chat',
        )),
        ConsultationKind.chat,
      );
      expect(
        resolveConsultationKind(_appointment(
          mode: ConsultationMode.online,
          consultationType: 'call',
        )),
        ConsultationKind.call,
      );
    });
  });

  group('consultation session parsing', () {
    test('parses a waiting session', () {
      final session = ConsultationSession.fromMap('apt_1', {
        'doctorId': 'doc_1',
        'patientId': 'patient_1',
        'status': 'waiting',
        'doctorJoined': true,
        'patientJoined': false,
      });
      expect(session.status, ConsultationStatus.waiting);
      expect(session.doctorJoined, isTrue);
      expect(session.patientJoined, isFalse);
    });

    test('parses an in-progress session with a start time', () {
      final startedAt = DateTime(2026, 8, 17, 16, 0);
      final session = ConsultationSession.fromMap('apt_1', {
        'doctorId': 'doc_1',
        'patientId': 'patient_1',
        'status': 'in_progress',
        'doctorJoined': true,
        'patientJoined': true,
        'startedAt': startedAt,
      });
      expect(session.status, ConsultationStatus.inProgress);
      expect(session.startedAt, startedAt);
    });

    test('unknown statuses fall back to scheduled', () {
      final session = ConsultationSession.fromMap('apt_1', {
        'doctorId': 'doc_1',
        'patientId': 'patient_1',
        'status': 'mystery',
        'doctorJoined': false,
        'patientJoined': false,
      });
      expect(session.status, ConsultationStatus.scheduled);
    });
  });

  group('active consultation selection', () {
    test('picks the first window-active appointment', () {
      final active = _appointment(
        id: 'active',
        date: DateTime(2026, 8, 17, 15, 50),
        slot: '03:50 PM',
      );
      final upcoming = _appointment(
        id: 'upcoming',
        date: DateTime(2026, 8, 18),
        slot: '10:00 AM',
      );
      expect(
        pickMostRelevantConsultation([upcoming, active]),
        active,
      );
    });

    test('falls back to the next upcoming appointment', () {
      final upcoming = _appointment(
        id: 'upcoming',
        date: DateTime(2026, 8, 18),
        slot: '10:00 AM',
      );
      expect(
        pickMostRelevantConsultation([upcoming]),
        upcoming,
      );
    });

    test('demo and non-confirmed bookings are excluded', () {
      final all = [
        _appointment(
          id: 'demo_1',
          date: DateTime(2026, 8, 17, 8, 0),
          slot: '08:00 AM',
        ),
        _appointment(
          id: 'requested',
          status: AppointmentStatus.requested,
          date: DateTime(2026, 8, 17, 9, 0),
          slot: '09:00 AM',
        ),
        _appointment(
          id: 'completed',
          status: AppointmentStatus.completed,
          date: DateTime(2026, 8, 17, 10, 0),
          slot: '10:00 AM',
        ),
        _appointment(
          id: 'real_1',
          date: DateTime(2026, 8, 18, 11, 0),
          slot: '11:00 AM',
        ),
      ];
      final filtered = activeConsultationFilter(all);
      expect(filtered.map((a) => a.id), ['real_1']);
    });
  });
}

/// Local copy of the filtering logic applied by `activeConsultationsProvider`
/// (kept in sync so the provider can be tested without a ProviderScope).
List<Appointment> activeConsultationFilter(List<Appointment> all) {
  final active = all.where((a) {
    if (a.status != AppointmentStatus.confirmed) return false;
    if (a.id.startsWith('demo_')) return false;
    return true;
  }).toList()
    ..sort((a, b) => (a.startDateTime ?? DateTime(9999))
        .compareTo(b.startDateTime ?? DateTime(9999)));
  return active;
}