import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor_dashboard/providers/doctor_provider.dart';

Doctor _doctor(String id) => Doctor(
      id: id,
      name: 'Dr. Test',
      specialization: 'General Physician',
      experience: '5 Years',
      rating: 4.5,
      consultationFee: 100,
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
      doctor: _doctor('doc_1'),
      mode: ConsultationMode.online,
      date: date,
      slot: slot,
      fee: 100,
      patientName: patientName,
      userId: userId,
      createdAt: DateTime(2026, 1, 1),
      status: status,
    );

DateTime _today() => DateTime.now();

DateTime _yesterday() => DateTime.now().subtract(const Duration(days: 1));

DateTime _tomorrow() => DateTime.now().add(const Duration(days: 1));

void main() {
  group('isSameDay & formatDoctorDisplayName', () {
    test('isSameDay compares calendar days only', () {
      expect(isSameDay(DateTime(2026, 8, 16, 1), DateTime(2026, 8, 16, 23)),
          isTrue);
      expect(isSameDay(DateTime(2026, 8, 16), DateTime(2026, 8, 17)), isFalse);
    });

    test('formatDoctorDisplayName avoids duplicated Dr. prefix', () {
      expect(formatDoctorDisplayName('Priya Sharma'), 'Dr. Priya Sharma');
      expect(formatDoctorDisplayName('Dr. Priya Sharma'), 'Dr. Priya Sharma');
      expect(formatDoctorDisplayName('Dr Priya'), 'Dr Priya');
      expect(formatDoctorDisplayName('  '), 'Doctor');
    });
  });

  group('Doctor dashboard providers', () {
    ProviderContainer makeContainer(List<Appointment> appointments) {
      final container = ProviderContainer(
        overrides: [
          doctorAppointmentsProvider
              .overrideWith((ref) => Stream.value(appointments)),
        ],
      );
      addTearDown(container.dispose);
      // Kick off the (lazy) stream subscription so values settle in tests.
      container.read(doctorAppointmentsProvider);
      return container;
    }

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 150));

    test('pendingRequestsProvider counts only requested appointments', () async {
      final now = _today();
      final container = makeContainer([
        _appointment(id: 'a1', date: now, status: AppointmentStatus.requested),
        _appointment(id: 'a2', date: now, status: AppointmentStatus.confirmed),
        _appointment(id: 'a3', date: now, status: AppointmentStatus.completed),
      ]);
      await settle();

      expect(container.read(pendingRequestsProvider), hasLength(1));
      expect(container.read(pendingRequestsProvider).single.id, 'a1');
    });

    test('todayAppointmentsProvider returns only confirmed appointments today',
        () async {
      final now = _today();
      final container = makeContainer([
        _appointment(id: 'today_confirmed', date: now,
            status: AppointmentStatus.confirmed),
        _appointment(id: 'today_requested', date: now,
            status: AppointmentStatus.requested),
        _appointment(id: 'yesterday_confirmed', date: _yesterday(),
            status: AppointmentStatus.confirmed),
        _appointment(id: 'tomorrow_confirmed', date: _tomorrow(),
            status: AppointmentStatus.confirmed),
      ]);
      await settle();

      expect(container.read(todayAppointmentsProvider), hasLength(1));
      expect(
          container.read(todayAppointmentsProvider).single.id,
          'today_confirmed');
    });

    test('upcomingAppointmentsProvider returns only confirmed future dates',
        () async {
      final now = _today();
      final container = makeContainer([
        _appointment(id: 'future', date: _tomorrow(),
            status: AppointmentStatus.confirmed),
        _appointment(id: 'today', date: now,
            status: AppointmentStatus.confirmed),
        _appointment(id: 'future_requested', date: _tomorrow(),
            status: AppointmentStatus.requested),
      ]);
      await settle();

      expect(container.read(upcomingAppointmentsProvider), hasLength(1));
      expect(container.read(upcomingAppointmentsProvider).single.id, 'future');
    });

    test('completedTodayAppointmentsProvider returns only completed today '
        'appointments', () async {
      final now = _today();
      final container = makeContainer([
        _appointment(id: 'completed_today', date: now,
            status: AppointmentStatus.completed),
        _appointment(id: 'completed_yesterday', date: _yesterday(),
            status: AppointmentStatus.completed),
        _appointment(id: 'confirmed_today', date: now,
            status: AppointmentStatus.confirmed),
      ]);
      await settle();

      expect(container.read(completedTodayAppointmentsProvider), hasLength(1));
      expect(
          container.read(completedTodayAppointmentsProvider).single.id,
          'completed_today');
    });

    test('doctorPatientsProvider groups unique patients from bookings',
        () async {
      final now = _today();
      final container = makeContainer([
        _appointment(id: 'b1', date: now, status: AppointmentStatus.completed,
            userId: 'p1', patientName: 'Priya'),
        _appointment(id: 'b2', date: _tomorrow(),
            status: AppointmentStatus.confirmed,
            userId: 'p1', patientName: 'Priya'),
        _appointment(id: 'b3', date: now, status: AppointmentStatus.requested,
            userId: 'p2', patientName: 'Ananya'),
        _appointment(id: 'b4', date: now, status: AppointmentStatus.requested,
            userId: '', patientName: 'NoId'),
      ]);
      await settle();

      final patients = container.read(doctorPatientsProvider);
      expect(patients, hasLength(2));
      final priya = patients.firstWhere((p) => p.userId == 'p1');
      final ananya = patients.firstWhere((p) => p.userId == 'p2');
      expect(priya.appointmentCount, 2);
      // Last appointment is the most recent one (tomorrow).
      expect(priya.lastAppointment.id, 'b2');
      expect(priya.lastAppointment.status, AppointmentStatus.confirmed);
      expect(ananya.appointmentCount, 1);
      expect(ananya.lastAppointment.status, AppointmentStatus.requested);
    });

    test('status changes flow through derived providers', () async {
      final controller = StreamController<List<Appointment>>();
      addTearDown(() => controller.close());
      final container = ProviderContainer(
        overrides: [
          doctorAppointmentsProvider
              .overrideWith((ref) => controller.stream),
        ],
      );
      addTearDown(container.dispose);
      container.read(doctorAppointmentsProvider);

      final now = _today();

      // Patient requests an appointment.
      controller.add([
        _appointment(id: 'a1', date: now, status: AppointmentStatus.requested),
      ]);
      await settle();
      expect(container.read(pendingRequestsProvider), hasLength(1));
      expect(container.read(todayAppointmentsProvider), isEmpty);

      // Doctor accepts -> request leaves "pending", becomes today's schedule.
      controller.add([
        _appointment(id: 'a1', date: now, status: AppointmentStatus.confirmed),
      ]);
      await settle();
      expect(container.read(pendingRequestsProvider), isEmpty);
      expect(container.read(todayAppointmentsProvider), hasLength(1));

      // Doctor completes -> moves into "Completed Today".
      controller.add([
        _appointment(id: 'a1', date: now, status: AppointmentStatus.completed),
      ]);
      await settle();
      expect(container.read(todayAppointmentsProvider), isEmpty);
      expect(container.read(completedTodayAppointmentsProvider), hasLength(1));
    });
  });
}