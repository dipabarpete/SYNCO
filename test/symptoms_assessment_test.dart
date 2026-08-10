import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/home/home_dashboard_screen.dart';
import 'package:hersync/features/home/widgets/symptoms_assessment_card.dart';
import 'package:hersync/features/symptoms_assessment/screens/symptoms_assessment_screen.dart';
import 'package:hersync/features/symptoms_assessment/screens/pcos_assessment_screen.dart';
import 'package:hersync/features/symptoms_assessment/screens/endometriosis_assessment_screen.dart';
import 'package:hersync/features/symptoms_assessment/screens/fibroids_assessment_screen.dart';

void main() {
  testWidgets('Symptoms Assessment card appears on Dashboard and navigates to assessment options',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );

    // Scroll to Symptoms Assessment Card on Home Dashboard
    await tester.dragUntilVisible(
      find.byType(SymptomsAssessmentCard),
      find.byType(SingleChildScrollView),
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    // Verify Symptoms Assessment Card is present on Home Dashboard
    expect(find.byType(SymptomsAssessmentCard), findsOneWidget);
    expect(find.text('Symptoms Assessment'), findsOneWidget);
    expect(
      find.text('Check your symptoms and understand what they may indicate.'),
      findsOneWidget,
    );

    // Tap Symptoms Assessment Card
    await tester.tap(find.byType(SymptomsAssessmentCard));
    await tester.pumpAndSettle();

    // Verify SymptomsAssessmentScreen is displayed
    expect(find.byType(SymptomsAssessmentScreen), findsOneWidget);
    expect(find.text('Choose an assessment'), findsOneWidget);
    expect(find.text('PCOS'), findsOneWidget);
    expect(find.text('Endometriosis'), findsOneWidget);
    expect(find.text('Uterine Fibroids'), findsOneWidget);

    // Tap PCOS Option
    await tester.tap(find.text('PCOS'));
    await tester.pumpAndSettle();

    // Verify PcosAssessmentScreen is displayed
    expect(find.byType(PcosAssessmentScreen), findsOneWidget);
    expect(find.text('Question 1 of 23'), findsOneWidget);

    // Pop back to SymptomsAssessmentScreen
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Tap Endometriosis Option
    await tester.tap(find.text('Endometriosis'));
    await tester.pumpAndSettle();

    // Verify EndometriosisAssessmentScreen is displayed
    expect(find.byType(EndometriosisAssessmentScreen), findsOneWidget);
    expect(find.text('Question 1 of 24'), findsOneWidget);

    // Pop back to SymptomsAssessmentScreen
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    // Tap Uterine Fibroids Option
    await tester.tap(find.text('Uterine Fibroids'));
    await tester.pumpAndSettle();

    // Verify FibroidsAssessmentScreen is displayed
    expect(find.byType(FibroidsAssessmentScreen), findsOneWidget);
    expect(find.text('Uterine Fibroids Screening'), findsOneWidget);
  });
}
