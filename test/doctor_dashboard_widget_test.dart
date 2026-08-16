import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor_dashboard/providers/doctor_provider.dart';
import 'package:hersync/features/doctor_dashboard/screens/doctor_home_screen.dart';
import 'package:hersync/features/doctor_dashboard/widgets/doctor_bottom_nav_bar.dart';

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
  required String id,
  required DateTime date,
  required AppointmentStatus status,
  String userId = 'patient_1',
  String patientName = 'Priya',
  String slot = '10:00 AM',
}) =>
    Appointment(
      id: id,
      doctor: _doctor(),
      mode: ConsultationMode.online,
      date: date,
      slot: slot,
      fee: 200,
      patientName: patientName,
      userId: userId,
      createdAt: DateTime(2026, 1, 1),
      status: status,
    );

DateTime _today() => DateTime.now();

DateTime _yesterday() => DateTime.now().subtract(const Duration(days: 1));

Widget _homeHarness({
  required List<Appointment> appointments,
  VoidCallback? onOpenRequests,
}) {
  return ProviderScope(
    overrides: [
      currentDoctorProvider.overrideWith((ref) async => _doctor()),
      doctorAppointmentsProvider
          .overrideWith((ref) => Stream.value(appointments)),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: DoctorHomeScreen(
          onOpenRequests: onOpenRequests ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('greeting shows the logged-in doctor name', (tester) async {
    await tester.pumpWidget(_homeHarness(appointments: []));
    await tester.pumpAndSettle();

    expect(find.textContaining('Dr. Priya Sharma'), findsOneWidget);
    expect(find.textContaining('👋'), findsOneWidget);
  });

  testWidgets('zero pending requests shows empty state and no green badge',
      (tester) async {
    await tester.pumpWidget(_homeHarness(appointments: []));
    await tester.pumpAndSettle();

    expect(find.text('New Requests'), findsOneWidget);
    expect(find.text('No new appointment requests'), findsOneWidget);
    // No green count badge when there are zero pending requests.
    expect(find.text('0'), findsNothing);
  });

  testWidgets('multiple pending requests show green badge and tap opens '
      'appointments', (tester) async {
    var openedRequests = false;
    await tester.pumpWidget(_homeHarness(
      appointments: [
        _appointment(
            id: 'r1',
            date: _today(),
            status: AppointmentStatus.requested,
            patientName: 'Ananya'),
        _appointment(
            id: 'r2',
            date: _today(),
            status: AppointmentStatus.requested,
            patientName: 'Riya'),
        _appointment(
            id: 'r3',
            date: _today(),
            status: AppointmentStatus.requested,
            patientName: 'Sara'),
      ],
      onOpenRequests: () => openedRequests = true,
    ));
    await tester.pumpAndSettle();

    expect(find.text('3 new appointment requests'), findsOneWidget);
    // Green circular badge with the count.
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('New Requests'));
    expect(openedRequests, isTrue);
  });

  testWidgets('one pending request renders a singular message',
      (tester) async {
    await tester.pumpWidget(_homeHarness(
      appointments: [
        _appointment(
            id: 'r1',
            date: _today(),
            status: AppointmentStatus.requested),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('1 new appointment request'), findsOneWidget);
  });

  testWidgets('today and completed sections render real appointments and do '
      'not mix', (tester) async {
    await tester.pumpWidget(_homeHarness(
      appointments: [
        _appointment(
            id: 't1',
            date: _today(),
            status: AppointmentStatus.confirmed,
            patientName: 'Neha',
            slot: '02:00 PM'),
        _appointment(
            id: 'c1',
            date: _today(),
            status: AppointmentStatus.completed,
            patientName: 'Kavya',
            slot: '09:00 AM'),
        // Requested appointments must NOT appear in these sections.
        _appointment(
            id: 'r1',
            date: _today(),
            status: AppointmentStatus.requested,
            patientName: 'RequestedPatient'),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text("Today's Appointments"), findsOneWidget);
    expect(find.text('Completed Today'), findsOneWidget);

    expect(find.text('Neha'), findsOneWidget);
    expect(find.text('02:00 PM • Video Consultation'), findsOneWidget);
    expect(find.text('Kavya'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    // Requested patients are not listed on the dashboard sections.
    expect(find.text('RequestedPatient'), findsNothing);

    // Empty states are not shown for non-empty sections.
    expect(find.text('No appointments scheduled for today'), findsNothing);
    expect(find.text('No completed appointments today'), findsNothing);
  });

  testWidgets('no appointments today shows empty states', (tester) async {
    await tester.pumpWidget(_homeHarness(
      appointments: [
        _appointment(
            id: 'u1',
            date: _yesterday(),
            status: AppointmentStatus.completed,
            patientName: 'OldPatient'),
      ],
    ));
    await tester.pumpAndSettle();

    expect(find.text('No appointments scheduled for today'), findsOneWidget);
    expect(find.text('No completed appointments today'), findsOneWidget);
    expect(find.text('OldPatient'), findsNothing);
  });

  testWidgets('DoctorBottomNavBar has exactly four sections and switches',
      (tester) async {
    final tapped = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox(),
          bottomNavigationBar: DoctorBottomNavBar(
            currentIndex: 0,
            onTap: (i) => tapped.add(i),
          ),
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Patients'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Appointments'));
    expect(tapped, [1]);

    await tester.tap(find.text('Patients'));
    expect(tapped, [1, 2]);

    await tester.tap(find.text('Profile'));
    expect(tapped, [1, 2, 3]);

    await tester.tap(find.text('Dashboard'));
    expect(tapped, [1, 2, 3, 0]);
  });
}