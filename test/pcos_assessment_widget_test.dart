import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/onboarding/widgets/diagnosis_option_card.dart';
import 'package:hersync/features/symptoms_assessment/screens/pcos_assessment_screen.dart';

void main() {
  testWidgets('PcosAssessmentScreen interactive questionnaire and result flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PcosAssessmentScreen(),
        ),
      ),
    );

    // Verify initial screen state (Question 1 of 23)
    expect(find.text('Question 1 of 23'), findsOneWidget);
    expect(find.text('Menstrual Cycle'), findsOneWidget);
    expect(find.text('How old were you when you had your first period?'), findsOneWidget);
    expect(find.text('10–12'), findsOneWidget);

    // Next button should be disabled initially
    final nextBtnFinder = find.widgetWithText(ElevatedButton, 'Next');
    expect(tester.widget<ElevatedButton>(nextBtnFinder).enabled, isFalse);

    // Select an option ("10–12")
    await tester.tap(find.text('10–12'));
    await tester.pump();

    // Next button should now be enabled
    expect(tester.widget<ElevatedButton>(nextBtnFinder).enabled, isTrue);

    // Tap Next -> Question 2 of 23
    await tester.tap(nextBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 23'), findsOneWidget);
    expect(find.text('How often do your periods usually come?'), findsOneWidget);

    // Tap Back -> returns to Question 1 and preserves selected option "10–12"
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 23'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(nextBtnFinder).enabled, isTrue);

    // Fast-forward through all 23 questions to test completion
    for (int i = 1; i <= 23; i++) {
      // Tap first option for each question if not already selected
      final firstOption = find.byType(DiagnosisOptionCard).first;
      await tester.tap(firstOption);
      await tester.pump();

      final buttonText = (i == 23) ? 'View Screening Summary' : 'Next';
      final btnFinder = find.widgetWithText(ElevatedButton, buttonText);
      expect(tester.widget<ElevatedButton>(btnFinder).enabled, isTrue);

      await tester.tap(btnFinder);
      await tester.pumpAndSettle();
    }

    // Verify Result Screen is displayed with non-diagnostic level & disclaimer card
    expect(find.text('Your PCOS Screening Result'), findsOneWidget);
    expect(find.text('Low indication'), findsOneWidget);
    expect(find.text('Low indication of PCOS-associated features'), findsOneWidget);
    expect(find.text('Important: Screening result, not a diagnosis'), findsOneWidget);
    expect(find.text('Symptom Group Summary'), findsOneWidget);

    // Scroll to Share Summary With Doctor button
    final shareBtn = find.text('Share Summary With Doctor');
    await tester.dragUntilVisible(
      shareBtn,
      find.byType(SingleChildScrollView).last,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();

    expect(shareBtn, findsOneWidget);
    await tester.tap(shareBtn);
    await tester.pumpAndSettle();

    // Verify Doctor consultation summary sheet opens
    expect(find.text('PCOS Screening Summary for Doctor'), findsOneWidget);
  });
}
