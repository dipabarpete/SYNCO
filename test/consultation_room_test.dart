import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/consultation_session.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor_dashboard/providers/consultation_providers.dart';
import 'package:hersync/features/doctor_dashboard/providers/doctor_provider.dart';
import 'package:hersync/features/doctor_dashboard/screens/consultation_room_screen.dart';

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

String _formatSlot(DateTime time) {
  final hour12 = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final meridian = time.hour < 12 ? 'AM' : 'PM';
  return '${hour12.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')} $meridian';
}

/// An appointment starting in the past (window active).
Appointment _activeAppointment({
  String id = 'apt_1',
  String patientName = 'Aisha Sharma',
  String userId = 'patient_1',
  int? age = 24,
  String consultationType = '',
}) {
  final start = DateTime.now().subtract(const Duration(minutes: 10));
  return Appointment(
    id: id,
    doctor: _doctor(),
    mode: ConsultationMode.online,
    date: start,
    slot: _formatSlot(start),
    fee: 200,
    patientName: patientName,
    userId: userId,
    age: age,
    consultationType: consultationType,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    status: AppointmentStatus.confirmed,
  );
}

/// An appointment in the future (window not active yet).
Appointment _futureAppointment() {
  final start = DateTime.now().add(const Duration(days: 1));
  return Appointment(
    id: 'apt_future',
    doctor: _doctor(),
    mode: ConsultationMode.online,
    date: start,
    slot: _formatSlot(start),
    fee: 200,
    patientName: 'Meera Nair',
    userId: 'patient_2',
    createdAt: DateTime.now(),
    status: AppointmentStatus.confirmed,
  );
}

Widget _roomHarness({
  required List<Appointment> appointments,
  ConsultationSession? session,
}) {
  return ProviderScope(
    overrides: [
      currentDoctorProvider.overrideWith((ref) async => _doctor()),
      doctorAppointmentsProvider
          .overrideWith((ref) => Stream.value(appointments)),
      consultationSessionProvider.overrideWith((ref, id) {
        return Stream.value(session);
      }),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DoctorConsultationRoomScreen(embedded: true),
      ),
    ),
  );
}

void main() {
  group('Doctor Consultation Room', () {
    testWidgets('shows empty state when there are no active consultations',
        (tester) async {
      await tester.pumpWidget(_roomHarness(appointments: []));
      await tester.pumpAndSettle();

      expect(find.text('No upcoming consultations'), findsOneWidget);
    });

    testWidgets('shows patient details and mode for the active appointment',
        (tester) async {
      await tester
          .pumpWidget(_roomHarness(appointments: [_activeAppointment()]));
      await tester.pumpAndSettle();

      expect(find.text('Aisha Sharma'), findsOneWidget);
      expect(find.textContaining('Age: 24'), findsOneWidget);
      expect(find.text('Video Consultation'), findsOneWidget);
    });

    testWidgets('shows not-started state before the scheduled time',
        (tester) async {
      await tester
          .pumpWidget(_roomHarness(appointments: [_futureAppointment()]));
      await tester.pumpAndSettle();

      expect(
        find.text('Consultation has not started yet'),
        findsOneWidget,
      );
      expect(find.text('Join Consultation'), findsNothing);
    });

    testWidgets('shows waiting room with Join button once the window is '
        'active and the doctor has not joined', (tester) async {
      await tester
          .pumpWidget(_roomHarness(appointments: [_activeAppointment()]));
      await tester.pumpAndSettle();

      expect(find.text('Waiting Room'), findsOneWidget);
      expect(find.text('Join Consultation'), findsOneWidget);
    });

    testWidgets('shows waiting-for-patient state after the doctor joins',
        (tester) async {
      final session = ConsultationSession(
        appointmentId: 'apt_1',
        doctorId: 'doc_1',
        patientId: 'patient_1',
        status: ConsultationStatus.waiting,
        doctorJoined: true,
        patientJoined: false,
      );
      await tester.pumpWidget(_roomHarness(
        appointments: [_activeAppointment()],
        session: session,
      ));
      // The waiting state contains an animated spinner, so pump with a
      // duration instead of pumpAndSettle.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Waiting for Aisha to join'), findsOneWidget);
      expect(find.text('Join Consultation'), findsNothing);
    });

    testWidgets('shows ready state with the video action when the patient '
        'has joined', (tester) async {
      final session = ConsultationSession(
        appointmentId: 'apt_1',
        doctorId: 'doc_1',
        patientId: 'patient_1',
        status: ConsultationStatus.waiting,
        doctorJoined: true,
        patientJoined: true,
      );
      await tester.pumpWidget(_roomHarness(
        appointments: [_activeAppointment()],
        session: session,
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Aisha has joined'), findsOneWidget);
      expect(find.text('Join Video Consultation'), findsOneWidget);
      expect(find.text('Join Consultation'), findsNothing);
    });

    testWidgets('shows in-progress state once the consultation started',
        (tester) async {
      final session = ConsultationSession(
        appointmentId: 'apt_1',
        doctorId: 'doc_1',
        patientId: 'patient_1',
        status: ConsultationStatus.inProgress,
        doctorJoined: true,
        patientJoined: true,
        startedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );
      await tester.pumpWidget(_roomHarness(
        appointments: [_activeAppointment()],
        session: session,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Consultation in progress'), findsOneWidget);
      expect(find.text('Rejoin Video Consultation'), findsOneWidget);
    });

    testWidgets('chat-type appointment shows Open Chat instead of video',
        (tester) async {
      final session = ConsultationSession(
        appointmentId: 'apt_1',
        doctorId: 'doc_1',
        patientId: 'patient_1',
        status: ConsultationStatus.waiting,
        doctorJoined: true,
        patientJoined: true,
      );
      await tester.pumpWidget(_roomHarness(
        appointments: [
          _activeAppointment(consultationType: 'chat'),
        ],
        session: session,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Chat Consultation'), findsOneWidget);
      expect(find.text('Open Chat'), findsOneWidget);
      expect(find.text('Join Video Consultation'), findsNothing);
    });

    testWidgets('completed appointment shows closed room (pinned view)',
        (tester) async {
      final completed = _activeAppointment().copyWith(
        status: AppointmentStatus.completed,
      );
      // Completed bookings are filtered out of the tab's active list, so this
      // is exercised through the deep-linked pinned room instead.
      await tester.pumpWidget(ProviderScope(
        overrides: [
          appointmentByIdProvider.overrideWith((ref, id) async => completed),
          doctorConsultationAccessProvider
              .overrideWith((ref, id) async => true),
          consultationSessionProvider.overrideWith((ref, id) {
            return Stream.value(null);
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: DoctorConsultationRoomScreen(
              appointmentId: 'apt_1',
              embedded: true,
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Consultation completed'), findsOneWidget);
      expect(find.text('Join Consultation'), findsNothing);
    });
  });
}