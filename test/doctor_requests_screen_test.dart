import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor_dashboard/providers/doctor_provider.dart';
import 'package:hersync/features/doctor_dashboard/screens/doctor_requests_screen.dart';

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

Appointment _requested({
  required String id,
  required DateTime date,
  String userId = 'patient_1',
  String patientName = 'Ananya',
  String slot = '10:30 AM',
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
      status: AppointmentStatus.requested,
    );

class _FakeController implements DoctorDashboardController {
  final calls = <(String, String)>[];

  @override
  Future<void> updateStatus(String bookingId, String status) async {
    calls.add((bookingId, status));
  }
}

Widget _harness({
  required List<Appointment> appointments,
  required DoctorDashboardController controller,
}) {
  return ProviderScope(
    overrides: [
      currentDoctorProvider.overrideWith((ref) async => _doctor()),
      doctorAppointmentsProvider
          .overrideWith((ref) => Stream.value(appointments)),
      doctorDashboardControllerProvider.overrideWithValue(controller),
    ],
    child: const MaterialApp(
      home: Scaffold(body: DoctorRequestsScreen()),
    ),
  );
}

void main() {
  testWidgets('dummy requests show name, age, date, issue and type',
      (tester) async {
    await tester.pumpWidget(
      _harness(appointments: [], controller: _FakeController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Priya Sharma, 29'), findsOneWidget);
    expect(find.textContaining('Appointment: '), findsWidgets);
    expect(find.text('Issue: Irregular periods'), findsOneWidget);
    // Online / Offline type pills are visible.
    expect(find.text('Online'), findsWidgets);
    expect(find.text('Offline'), findsWidgets);
    // Accept and Decline actions are present.
    expect(find.text('Accept'), findsWidgets);
    expect(find.text('Decline'), findsWidgets);
  });

  testWidgets('accepting a dummy request removes it locally', (tester) async {
    final controller = _FakeController();
    await tester.pumpWidget(
      _harness(appointments: [], controller: controller),
    );
    await tester.pumpAndSettle();

    expect(find.text('Priya Sharma, 29'), findsOneWidget);
    await tester.tap(find.text('Accept').first);
    await tester.pumpAndSettle();

    expect(find.text('Priya Sharma, 29'), findsNothing);
    // Demo data never touches the real booking system.
    expect(controller.calls, isEmpty);
  });

  testWidgets('declining a dummy request removes it locally', (tester) async {
    await tester.pumpWidget(
      _harness(appointments: [], controller: _FakeController()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Priya Sharma, 29'), findsOneWidget);
    await tester.tap(find.text('Decline').first);
    await tester.pumpAndSettle();

    expect(find.text('Priya Sharma, 29'), findsNothing);
  });

  testWidgets('accepting a real request updates the booking via controller',
      (tester) async {
    final controller = _FakeController();
    await tester.pumpWidget(
      _harness(
        // Sorts before the dummy requests (today vs next days), so the first
        // Accept button belongs to this real request.
        appointments: [
          _requested(
            id: 'real_1',
            date: DateTime.now(),
            patientName: 'Ananya Nair',
          ),
        ],
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ananya Nair'), findsOneWidget);
    await tester.tap(find.text('Accept').first);
    await tester.pumpAndSettle();

    expect(controller.calls, [('real_1', 'confirmed')]);
  });

  testWidgets('declining a real request updates the booking via controller',
      (tester) async {
    final controller = _FakeController();
    await tester.pumpWidget(
      _harness(
        appointments: [
          _requested(
            id: 'real_2',
            date: DateTime.now(),
            patientName: 'Sara Ali',
          ),
        ],
        controller: controller,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sara Ali'), findsOneWidget);
    await tester.tap(find.text('Decline').first);
    await tester.pumpAndSettle();

    expect(controller.calls, [('real_2', 'declined')]);
  });

  testWidgets('shows empty state when nothing is left to review',
      (tester) async {
    await tester.pumpWidget(
      _harness(appointments: [], controller: _FakeController()),
    );
    await tester.pumpAndSettle();

    // Resolve every visible dummy request.
    while (tester.any(find.text('Accept'))) {
      await tester.tap(find.text('Accept').first);
      await tester.pumpAndSettle();
    }

    expect(find.text('No new requests'), findsOneWidget);
  });
}