import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor/models/appointment.dart';
import 'package:hersync/features/doctor/models/doctor.dart';
import 'package:hersync/features/doctor_dashboard/providers/doctor_provider.dart';
import 'package:hersync/features/doctor_dashboard/screens/doctor_profile_screen.dart';

Doctor _doctor({
  bool verified = false,
  String? gender,
  bool showGender = false,
  bool offerOffline = false,
  int reviewCount = 126,
  double rating = 4.8,
}) =>
    Doctor(
      id: 'doc_1',
      name: 'Dr. Priya Sharma',
      specialization: 'Gynecologist',
      specializations: const ['Gynecologist', 'Endometriosis'],
      experience: '8+ Years',
      rating: rating,
      reviewCount: reviewCount,
      consultationFee: 200,
      availability: 'Available Today',
      mode: offerOffline ? ConsultationMode.offline : ConsultationMode.online,
      about: 'A short professional bio about the doctor.',
      availableDays: const ['Mon'],
      timeSlots: const ['10:00 AM'],
      photoUrl: 'https://example.com/photo.jpg',
      qualifications: const ['MBBS', 'MD'],
      licenseId: 'MCI-84920-IND',
      isVerified: verified,
      gender: gender,
      showGender: showGender,
      consultationsCount: 1240,
      clinicName: 'Sunflower Women\u2019s Hospital',
      clinicLocation: 'Koramangala, Bengaluru',
      languages: const ['English', 'Hindi', 'Bengali'],
      availabilitySlots: const [
        {
          'day': 'Mon',
          'start': '09:00 AM',
          'end': '12:00 PM',
          'mode': 'both',
        },
      ],
    );

Widget _harness(Doctor doctor) {
  return ProviderScope(
    overrides: [
      currentDoctorProvider.overrideWith((ref) async => doctor),
      doctorAppointmentsProvider
          .overrideWith((ref) => Stream.value(<Appointment>[])),
    ],
    child: const MaterialApp(
      home: Scaffold(body: DoctorProfileScreen()),
    ),
  );
}

/// Uses a tall surface so every lazily-built profile section is laid out.
void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('header shows photo area, name, qualifications, license and a '
      'verified badge only for verified doctors', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(_doctor(verified: true)));
    await tester.pumpAndSettle();

    // Photo placeholder is the initials avatar (photo URL fails in tests).
    expect(find.text('PS'), findsOneWidget);
    expect(find.text('Dr. Priya Sharma'), findsOneWidget);
    expect(find.text('MBBS, MD'), findsOneWidget);
    expect(find.text('License: MCI-84920-IND'), findsOneWidget);
    expect(find.text('Verified Doctor'), findsOneWidget);
    expect(find.text('Profile Pending Verification'), findsNothing);
  });

  testWidgets('unverified doctors never show the verified badge',
      (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(_doctor(verified: false)));
    await tester.pumpAndSettle();

    expect(find.text('Verified Doctor'), findsNothing);
    expect(find.text('Profile Pending Verification'), findsOneWidget);
  });

  testWidgets('gender is shown only when the doctor enables it publicly',
      (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(
      _doctor(gender: 'Female', showGender: false),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Gender'), findsNothing);
    expect(find.text('Female'), findsNothing);

    // Reset the widget tree so the new provider state is fresh.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();

    await tester.pumpWidget(_harness(
      _doctor(gender: 'Female', showGender: true),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
  });

  testWidgets('specializations render as chips from the doctor data',
      (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(_doctor()));
    await tester.pumpAndSettle();

    expect(find.text('Specializations'), findsOneWidget);
    expect(find.text('Gynecologist'), findsOneWidget);
    expect(find.text('Endometriosis'), findsOneWidget);
  });

  testWidgets('experience and consultations use actual profile data',
      (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(_doctor()));
    await tester.pumpAndSettle();

    expect(find.text('Experience'), findsOneWidget);
    expect(find.text('8+ Years'), findsOneWidget);
    expect(find.text('1,240 Consultations'), findsOneWidget);
  });

  testWidgets('hospital/clinic section appears for offline consultation and '
      'shows clinic name and location', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(_doctor(offerOffline: true)));
    await tester.pumpAndSettle();

    expect(find.text('Hospital / Clinic'), findsOneWidget);
    expect(
      find.text('Sunflower Women\u2019s Hospital'),
      findsOneWidget,
    );
    expect(find.text('Koramangala, Bengaluru'), findsOneWidget);
    expect(
      find.text('Visit the clinic for offline consultations'),
      findsOneWidget,
    );
  });

  testWidgets('no misleading hospital section when offline is not offered',
      (tester) async {
    _useTallScreen(tester);
    final onlineOnly = _doctor(offerOffline: false).withOfflineRemoved();
    await tester.pumpWidget(_harness(onlineOnly));
    await tester.pumpAndSettle();

    expect(find.text('Hospital / Clinic'), findsNothing);
    expect(find.text('Sunflower Women\u2019s Hospital'), findsNothing);
  });

  testWidgets('bio, patient rating and languages are displayed',
      (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(_doctor()));
    await tester.pumpAndSettle();

    expect(find.text('About the Doctor'), findsOneWidget);
    expect(
      find.text('A short professional bio about the doctor.'),
      findsOneWidget,
    );

    expect(find.text('Patient Rating'), findsOneWidget);
    expect(find.text('4.8'), findsOneWidget);
    expect(find.text('126 patient ratings'), findsOneWidget);
    expect(find.text('Reviews'), findsNothing);

    expect(find.text('Languages'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Hindi'), findsOneWidget);
    expect(find.text('Bengali'), findsOneWidget);
  });

  testWidgets('no ratings yet is shown gracefully', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(
      _doctor(reviewCount: 0, rating: 0),
    ));
    await tester.pumpAndSettle();

    expect(find.text('No ratings yet'), findsOneWidget);
  });

  testWidgets('saved availability entries are shown and the Add Availability '
      'button is prominent', (tester) async {
    _useTallScreen(tester);
    await tester.pumpWidget(_harness(_doctor()));
    await tester.pumpAndSettle();

    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('09:00 AM – 12:00 PM'), findsOneWidget);
    expect(find.text('Online & Offline'), findsOneWidget);
    expect(find.text('Add Availability'), findsOneWidget);
  });

  testWidgets('profile fits on a narrow phone screen without overflow',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness(_doctor(
      verified: true,
      gender: 'Female',
      showGender: true,
      offerOffline: true,
    )));
    await tester.pumpAndSettle();

    // Scroll to the bottom to make sure every section lays out.
    await tester.scrollUntilVisible(
      find.text('Add Availability'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Add Availability'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

extension on Doctor {
  /// A copy without any offline signal (clinic, slots or offline mode), used
  /// to verify the Hospital/Clinic section is hidden when offline care is not
  /// offered.
  Doctor withOfflineRemoved() => Doctor(
        id: id,
        name: name,
        specialization: specialization,
        specializations: specializations,
        experience: experience,
        rating: rating,
        reviewCount: reviewCount,
        consultationFee: consultationFee,
        availability: availability,
        mode: mode == ConsultationMode.offline
            ? ConsultationMode.online
            : mode,
        about: about,
        availableDays: availableDays,
        timeSlots: timeSlots,
        photoUrl: photoUrl,
        qualifications: qualifications,
        licenseId: licenseId,
        isVerified: isVerified,
        gender: gender,
        showGender: showGender,
        consultationsCount: consultationsCount,
        languages: languages,
      );
}