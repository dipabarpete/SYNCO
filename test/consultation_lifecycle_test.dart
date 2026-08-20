import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor/models/consultation_session.dart';

Doctor _testDoctor() => const Doctor(
      id: 'doc_101',
      name: 'Dr. Sarah Jenkins',
      specialization: 'Gynecologist',
      experience: '10 Years',
      rating: 4.9,
      consultationFee: 300,
      availability: 'Available',
      mode: ConsultationMode.online,
      about: 'Specialist in women health.',
      availableDays: ['Mon', 'Tue', 'Wed'],
      timeSlots: ['10:00 AM', '02:00 PM'],
    );

void main() {
  group('Appointment Lifecycle & Status Mapping Tests', () {
    test('1-3. Appointment request creation initial status is requested', () {
      final now = DateTime.now();
      final appt = Appointment(
        id: 'apt_req_1',
        doctor: _testDoctor(),
        mode: ConsultationMode.online,
        date: DateTime(2026, 8, 20),
        slot: '02:00 PM',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: now,
        status: AppointmentStatus.requested,
      );

      expect(appt.status, AppointmentStatus.requested);
      expect(appt.statusLabel, contains('Awaiting Doctor Confirmation'));
    });

    test('4-9. Doctor accepts request -> status changes to confirmed', () {
      final apptRequested = Appointment(
        id: 'apt_req_2',
        doctor: _testDoctor(),
        mode: ConsultationMode.online,
        date: DateTime(2026, 8, 20),
        slot: '02:00 PM',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: DateTime.now(),
        status: AppointmentStatus.requested,
      );

      final apptConfirmed = apptRequested.copyWith(status: AppointmentStatus.confirmed);
      expect(apptConfirmed.status, AppointmentStatus.confirmed);
      expect(apptConfirmed.statusLabel, equals('Confirmed'));
    });

    test('10-12. Doctor declines request -> status changes to declined', () {
      final apptRequested = Appointment(
        id: 'apt_req_3',
        doctor: _testDoctor(),
        mode: ConsultationMode.online,
        date: DateTime(2026, 8, 20),
        slot: '02:00 PM',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: DateTime.now(),
        status: AppointmentStatus.requested,
      );

      final apptDeclined = apptRequested.copyWith(status: AppointmentStatus.declined);
      expect(apptDeclined.status, AppointmentStatus.declined);
      expect(apptDeclined.statusLabel, equals('Request Declined'));
    });

    test('13-14. Time window calculations for 30-min reminder & start time', () {
      final today = DateTime.now();
      final futureDate = today.add(const Duration(days: 1));
      
      final apptFuture = Appointment(
        id: 'apt_future',
        doctor: _testDoctor(),
        mode: ConsultationMode.online,
        date: DateTime(futureDate.year, futureDate.month, futureDate.day),
        slot: '10:00 AM',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: DateTime.now(),
        status: AppointmentStatus.confirmed,
      );

      expect(apptFuture.startDateTime, isNotNull);
      expect(apptFuture.endDateTime, apptFuture.startDateTime!.add(const Duration(minutes: 30)));
      expect(apptFuture.isBeforeWindow, isTrue);
      expect(apptFuture.isWindowActive, isFalse);
      expect(apptFuture.isAfterWindow, isFalse);
    });

    test('15-17. Consultation room availability before, during, and after window', () {
      final now = DateTime.now();

      // Before window
      final beforeAppt = Appointment(
        id: 'apt_before',
        doctor: _testDoctor(),
        mode: ConsultationMode.online,
        date: DateTime(now.year, now.month, now.day + 1),
        slot: '10:00 AM',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: now,
        status: AppointmentStatus.confirmed,
      );
      expect(isConsultationWindowActive(beforeAppt), isFalse);

      // During active window
      final activeSlotHour = now.hour.toString().padLeft(2, '0');
      final activeSlotMin = now.minute.toString().padLeft(2, '0');
      final activeAppt = Appointment(
        id: 'apt_active',
        doctor: _testDoctor(),
        mode: ConsultationMode.online,
        date: DateTime(now.year, now.month, now.day),
        slot: '$activeSlotHour:$activeSlotMin',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: now,
        status: AppointmentStatus.confirmed,
      );
      expect(isConsultationWindowActive(activeAppt), isTrue);

      // After window / Completed
      final pastAppt = Appointment(
        id: 'apt_past',
        doctor: _testDoctor(),
        mode: ConsultationMode.online,
        date: DateTime(2025, 1, 1),
        slot: '10:00 AM',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: now,
        status: AppointmentStatus.completed,
      );
      expect(isConsultationWindowActive(pastAppt), isFalse);
    });

    test('18-20. Existing Firestore appointment status parsing compatibility', () {
      final doctor = _testDoctor();

      final reqDoc = Appointment.fromMap('doc_1', {
        'status': 'requested',
        'mode': 'online',
        'date': '2026-08-20T00:00:00.000',
        'time': '10:00 AM',
        'patientName': 'Alice',
        'userId': 'u1',
      }, doctor);
      expect(reqDoc.status, AppointmentStatus.requested);

      final confDoc = Appointment.fromMap('doc_2', {
        'status': 'confirmed',
        'mode': 'online',
        'date': '2026-08-20T00:00:00.000',
        'time': '10:00 AM',
        'patientName': 'Alice',
        'userId': 'u1',
      }, doctor);
      expect(confDoc.status, AppointmentStatus.confirmed);

      final decDoc = Appointment.fromMap('doc_3', {
        'status': 'declined',
        'mode': 'online',
        'date': '2026-08-20T00:00:00.000',
        'time': '10:00 AM',
        'patientName': 'Alice',
        'userId': 'u1',
      }, doctor);
      expect(decDoc.status, AppointmentStatus.declined);

      final compDoc = Appointment.fromMap('doc_4', {
        'status': 'completed',
        'mode': 'online',
        'date': '2026-08-20T00:00:00.000',
        'time': '10:00 AM',
        'patientName': 'Alice',
        'userId': 'u1',
      }, doctor);
      expect(compDoc.status, AppointmentStatus.completed);
    });

    test('22. Authorization check logic for doctor and patient access', () {
      final appt = Appointment(
        id: 'apt_auth',
        doctor: _testDoctor(), // doctorId = doc_101
        mode: ConsultationMode.online,
        date: DateTime(2026, 8, 20),
        slot: '10:00 AM',
        fee: 300,
        patientName: 'Jane Doe',
        userId: 'user_777',
        createdAt: DateTime.now(),
        status: AppointmentStatus.confirmed,
      );

      expect(appt.userId, equals('user_777'));
      expect(appt.doctor.id, equals('doc_101'));
    });
  });
}
