import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/doctor_dashboard/screens/doctor_availability_sheet.dart';

Widget _harness() {
  return const ProviderScope(
    child: MaterialApp(
      home: Scaffold(
        body: DoctorAvailabilitySheet(doctorId: 'doc_1'),
      ),
    ),
  );
}

void main() {
  testWidgets('sheet shows day, start/end time and consultation modes',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    expect(find.text('Add Availability'), findsOneWidget);
    // Day-of-week options.
    for (final day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
      expect(find.text(day), findsOneWidget);
    }
    // Time pickers.
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('End'), findsOneWidget);
    expect(find.text('09:00 AM'), findsOneWidget);
    expect(find.text('05:00 PM'), findsOneWidget);
    // Consultation modes.
    expect(find.text('Online'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Both'), findsOneWidget);
    expect(find.text('Save Availability'), findsOneWidget);
  });

  testWidgets('saving without a live backend fails gracefully with a message',
      (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save Availability'));
    await tester.pumpAndSettle();

    expect(
      find.text('Could not save availability. Please try again.'),
      findsOneWidget,
    );
  });
}
