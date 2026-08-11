import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/onboarding/widgets/diagnosis_option_card.dart';
import 'package:hersync/features/symptoms_assessment/screens/fibroids_assessment_screen.dart';

void main() {
  testWidgets('FibroidsAssessmentScreen interactive questionnaire and result flow',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FibroidsAssessmentScreen(),
        ),
      ),
    );

    // Verify initial screen state (Question 1 of 24)
    expect(find.text('Question 1 of 24'), findsOneWidget);
    expect(find.text('Menstrual Bleeding'), findsOneWidget);
    expect(find.text('How would you describe your menstrual bleeding?'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Very heavy'), findsOneWidget);

    // Next button should be disabled initially
    final nextBtnFinder = find.widgetWithText(ElevatedButton, 'Next');
    expect(tester.widget<ElevatedButton>(nextBtnFinder).enabled, isFalse);

    // Select an option ("Light")
    await tester.tap(find.text('Light'));
    await tester.pump();

    // Next button should now be enabled
    expect(tester.widget<ElevatedButton>(nextBtnFinder).enabled, isTrue);

    // Tap Next -> Question 2 of 24
    await tester.tap(nextBtnFinder);
    await tester.pumpAndSettle();

    expect(find.text('Question 2 of 24'), findsOneWidget);
    expect(
      find.text('How many days does your period usually last?'),
      findsOneWidget,
    );

    // Tap Back -> returns to Question 1 and preserves selected option
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Question 1 of 24'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(nextBtnFinder).enabled, isTrue);

    // Fast-forward through all 24 questions to test completion
    for (int i = 1; i <= 24; i++) {
      final firstOption = find.byType(DiagnosisOptionCard).first;
      await tester.tap(firstOption);
      await tester.pump();

      final buttonText = (i == 24) ? 'View Screening Summary' : 'Next';
      final btnFinder = find.widgetWithText(ElevatedButton, buttonText);
      expect(tester.widget<ElevatedButton>(btnFinder).enabled, isTrue);

      await tester.tap(btnFinder);
      await tester.pumpAndSettle();
    }

    // Verify Result Screen is displayed with non-diagnostic level & disclaimer card
    expect(find.text('Your Uterine Fibroids Screening Result'), findsOneWidget);
    expect(find.text('Low indication'), findsOneWidget);
    expect(
      find.text('Low indication of uterine-fibroid-associated features'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Important: This is a symptom screening result, not a diagnosis.'),
      findsOneWidget,
    );
    expect(find.textContaining('Continue Tracking'), findsWidgets);

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
    expect(find.text('Uterine Fibroids Symptom Screening Summary'), findsOneWidget);
    expect(
      find.textContaining('This summary is based on user-reported symptoms and is not a medical diagnosis.'),
      findsOneWidget,
    );
  });
}