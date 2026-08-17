import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor/models/patient_health_summary.dart';
import 'package:hersync/features/doctor_dashboard/providers/doctor_provider.dart';
import 'package:hersync/features/doctor_dashboard/screens/patient_health_summary_screen.dart';
import 'package:hersync/features/doctor_dashboard/widgets/doctor_appointment_card.dart';

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

Appointment _confirmedAppointment({
  String id = 'apt_1',
  String userId = 'patient_1',
  String patientName = 'Neha Gupta',
}) =>
    Appointment(
      id: id,
      doctor: _doctor(),
      mode: ConsultationMode.online,
      date: DateTime.now().add(const Duration(days: 1)),
      slot: '10:00 AM',
      fee: 200,
      patientName: patientName,
      userId: userId,
      createdAt: DateTime(2026, 1, 1),
      status: AppointmentStatus.confirmed,
    );

/// Records the status updates a controller is asked to perform, without
/// touching Firebase.
class _FakeDashboardController extends DoctorDashboardController {
  final List<(String, String)> calls;

  _FakeDashboardController(super.ref, this.calls);

  @override
  Future<void> updateStatus(String bookingId, String status) async {
    calls.add((bookingId, status));
  }
}

Widget _cardHarness({
  required Appointment appointment,
  required List<(String, String)> calls,
  bool allowCancel = true,
}) {
  return ProviderScope(
    overrides: [
      doctorDashboardControllerProvider.overrideWith(
        (ref) => _FakeDashboardController(ref, calls),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: DoctorAppointmentCard(
            appointment: appointment,
            showStatus: true,
            allowCancel: allowCancel,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('DoctorAppointmentCard - cancel confirmed appointment', () {
    testWidgets('tapping Confirmed opens the cancel action sheet',
        (tester) async {
      final calls = <(String, String)>[];
      await tester.pumpWidget(
        _cardHarness(
          appointment: _confirmedAppointment(),
          calls: calls,
        ),
      );

      await tester.tap(find.text('Confirmed'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Appointment'), findsOneWidget);
      expect(find.text('The patient will be notified.'), findsOneWidget);
    });

    testWidgets('Keep Appointment dismisses without cancelling',
        (tester) async {
      final calls = <(String, String)>[];
      await tester.pumpWidget(
        _cardHarness(
          appointment: _confirmedAppointment(),
          calls: calls,
        ),
      );

      await tester.tap(find.text('Confirmed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Appointment'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel this appointment?'), findsOneWidget);
      expect(find.text('Keep Appointment'), findsOneWidget);

      await tester.tap(find.text('Keep Appointment'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel this appointment?'), findsNothing);
      expect(calls, isEmpty);
    });

    testWidgets('confirming cancellation updates the appointment status',
        (tester) async {
      final calls = <(String, String)>[];
      await tester.pumpWidget(
        _cardHarness(
          appointment: _confirmedAppointment(),
          calls: calls,
        ),
      );

      await tester.tap(find.text('Confirmed'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Appointment'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel this appointment?'), findsOneWidget);

      await tester.tap(find.text('Cancel Appointment'));
      await tester.pumpAndSettle();

      expect(calls, [('apt_1', 'cancelled')]);
    });

    testWidgets('Confirmed tag is inert when allowCancel is false (demo)',
        (tester) async {
      final calls = <(String, String)>[];
      await tester.pumpWidget(
        _cardHarness(
          appointment: _confirmedAppointment(),
          calls: calls,
          allowCancel: false,
        ),
      );

      await tester.tap(find.text('Confirmed'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel Appointment'), findsNothing);
      expect(calls, isEmpty);
    });
  });

  group('PatientHealthSummaryScreen', () {
    PatientHealthSummary fullSummary() => const PatientHealthSummary(
          authorized: true,
          patientName: 'Neha Gupta',
          hasCycleHistory: true,
          averageCycleLength: 28,
          averagePeriodDuration: 5,
          currentPhaseLabel: 'Luteal Phase',
          lastPeriodStartLabel: '2 Aug',
          recentSymptoms: ['Severe cramps', 'Spotting', 'Fatigue'],
          screeningIndicators: [
            PatientScreeningIndicator(
              name: 'PCOS',
              levelLabel: 'Moderate indicators',
            ),
            PatientScreeningIndicator(
              name: 'Endometriosis',
              levelLabel: 'Low indicators',
            ),
          ],
          healthScore: 78,
          reports: [
            PatientReport(
              name: 'CBC',
              uploadedAt: '2026-08-01T10:00:00.000',
            ),
          ],
          concern:
              'My periods have become more painful over the last 3 months.',
        );

    Widget screenHarness(PatientHealthSummary? summary) {
      return ProviderScope(
        overrides: [
          patientHealthSummaryProvider.overrideWith(
            (ref, args) async => summary,
          ),
        ],
        child: const MaterialApp(
          home: PatientHealthSummaryScreen(
            userId: 'patient_1',
            appointmentId: 'apt_1',
            patientName: 'Neha Gupta',
          ),
        ),
      );
    }

    testWidgets("renders the patient's real data sections", (tester) async {
      await tester.pumpWidget(screenHarness(fullSummary()));
      await tester.pumpAndSettle();

      expect(find.text('Patient Health Summary'), findsOneWidget);
      expect(find.text('Neha Gupta'), findsWidgets);

      // Cycle
      expect(find.text('Cycle'), findsOneWidget);
      expect(find.text('28-day average'), findsOneWidget);
      expect(find.text('Currently: Luteal Phase'), findsOneWidget);

      // Symptoms
      expect(find.text('Recent Symptoms'), findsOneWidget);
      expect(find.text('Severe cramps'), findsOneWidget);
      expect(find.text('Spotting'), findsOneWidget);
      expect(find.text('Fatigue'), findsOneWidget);

      // Screening indicators
      await tester.scrollUntilVisible(
        find.text('Health Score'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('PCOS — Moderate indicators', findRichText: true),
        findsOneWidget,
      );
      expect(
        find.text('Endometriosis — Low indicators', findRichText: true),
        findsOneWidget,
      );
      expect(find.textContaining('not a diagnosis'), findsOneWidget);

      // Health Score
      expect(find.text('78 / 100'), findsOneWidget);

      // Reports
      await tester.scrollUntilVisible(
        find.text('Recent Reports'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('CBC'), findsOneWidget);
      expect(find.text('Uploaded · 1 Aug 2026'), findsOneWidget);

      // Concern
      await tester.scrollUntilVisible(
        find.textContaining('more painful'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining('My periods have become more painful'),
        findsOneWidget,
      );
    });

    testWidgets('shows empty states for missing sections', (tester) async {
      const summary = PatientHealthSummary(
        authorized: true,
        patientName: 'Neha Gupta',
        hasCycleHistory: true,
        averageCycleLength: 28,
        currentPhaseLabel: 'Follicular Phase',
        concern: 'Irregular cycles',
      );
      await tester.pumpWidget(screenHarness(summary));
      await tester.pumpAndSettle();

      expect(find.text('No recent symptoms logged'), findsOneWidget);
      expect(find.text('No screening results available'), findsOneWidget);
      expect(find.text('No health score available'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('No recent reports uploaded'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('No recent reports uploaded'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.textContaining('Irregular cycles'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('Irregular cycles'), findsOneWidget);
    });

    testWidgets('completely empty summary shows the no-data state',
        (tester) async {
      await tester.pumpWidget(
        screenHarness(
          const PatientHealthSummary(authorized: true, patientName: 'Neha'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No health data yet'), findsOneWidget);
    });

    testWidgets('unauthorized (no appointment) shows unavailable state',
        (tester) async {
      await tester.pumpWidget(screenHarness(null));
      await tester.pumpAndSettle();

      expect(find.text('Health summary unavailable'), findsOneWidget);
      expect(
        find.textContaining('only view summaries for your own appointments'),
        findsOneWidget,
      );
    });
  });
}