import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/onboarding/screens/onboarding_pcos_screen.dart';
import 'package:hersync/features/onboarding/providers/onboarding_provider.dart';

Widget _wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: child));
}

Future<void> _tapContinue(WidgetTester tester) async {
  await _tap(tester, 'Continue');
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, String label) async {
  final finder = find.text(label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
}

Future<void> _tapOption(WidgetTester tester, String label) async {
  await _tap(tester, label);
  await _tapContinue(tester);
}

/// Enters the Early Risk Assessment branch (diagnosis = No).
Future<void> _enterBranch(WidgetTester tester) async {
  await tester.pumpWidget(_wrap(const OnboardingPcosScreen()));
  expect(
    find.text('Have you been diagnosed with PCOS, PCOD, or PMOS?'),
    findsOneWidget,
  );
  await _tap(tester, 'No');
  await tester.pump();
  await _tapContinue(tester);
  expect(find.text('What is your age?'), findsOneWidget);
}

/// Answers Q1-Q3 (basic information).
Future<void> _answerBasicInfo(WidgetTester tester) async {
  await _tap(tester, '18–24');
  await tester.pump();
  await _tapContinue(tester);

  expect(find.text('How tall are you?'), findsOneWidget);
  final continueDisabled = tester
      .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Continue'))
      .onPressed;
  expect(continueDisabled, isNull);
  await tester.enterText(find.byType(TextField), '165');
  await tester.pump();
  await _tapContinue(tester);

  expect(find.text('What is your current weight?'), findsOneWidget);
  await tester.enterText(find.byType(TextField), '60');
  await tester.pump();
  await _tapContinue(tester);
}

/// Answers Q4-Q7 (menstrual cycle).
Future<void> _answerCycleQuestions(WidgetTester tester) async {
  expect(find.text('How regular are your periods?'), findsOneWidget);
  await _tap(tester, 'Regular');
  await tester.pump();
  await _tapContinue(tester);

  expect(
    find.text('Approximately how long is your typical cycle?'),
    findsOneWidget,
  );
  await _tap(tester, '21–35 days');
  await tester.pump();
  await _tapContinue(tester);

  expect(
    find.text('Have you ever gone 90 days or more without a period?'),
    findsOneWidget,
  );
  await _tap(tester, 'No');
  await tester.pump();
  await _tapContinue(tester);

  expect(
    find.text(
      'Have your periods changed significantly compared with the past?',
    ),
    findsOneWidget,
  );
  await _tap(tester, 'No');
  await tester.pump();
  await _tapContinue(tester);
}

/// Answers Q8-Q10 (symptoms).
Future<void> _answerSymptomQuestions(WidgetTester tester) async {
  expect(
    find.text(
      'Do you experience unusual or increased facial/body hair growth?',
    ),
    findsOneWidget,
  );
  await _tap(tester, 'Mild');
  await tester.pump();
  await _tapContinue(tester);

  expect(
    find.text('Do you experience persistent or severe acne?'),
    findsOneWidget,
  );
  await _tap(tester, 'No');
  await tester.pump();
  await _tapContinue(tester);

  expect(
    find.text('Have you noticed thinning of hair on your scalp?'),
    findsOneWidget,
  );
  await _tap(tester, 'No');
  await tester.pump();
  await _tapContinue(tester);
}

/// Answers Q11-Q16 (metabolic, lifestyle and stress).
Future<void> _answerMetabolicAndLifestyle(WidgetTester tester) async {
  expect(
    find.text('Has your weight changed significantly recently?'),
    findsOneWidget,
  );
  await _tapOption(tester, 'Weight gain');

  expect(
    find.text('Does anyone in your immediate family have:'),
    findsOneWidget,
  );
  await _tap(tester, 'PCOS');
  await tester.pump();
  await _tapContinue(tester);

  expect(
    find.text('Have you ever been told by a doctor that you have:'),
    findsOneWidget,
  );
  await _tap(tester, 'High blood pressure');
  await tester.pump();
  await _tapContinue(tester);

  expect(find.text('How physically active are you?'), findsOneWidget);
  await _tapOption(tester, 'Moderate activity');

  expect(find.text('How many hours do you usually sleep?'), findsOneWidget);
  await _tapOption(tester, '7–9');

  expect(
    find.text('How would you describe your stress level?'),
    findsOneWidget,
  );
  await _tap(tester, '3');
  await tester.pump();
  await _tapContinue(tester);
}

void main() {
  testWidgets('NO -> full Q1-Q17 flow, Q17=No branch, all answers saved', (
    tester,
  ) async {
    await _enterBranch(tester);

    await _answerBasicInfo(tester);
    await _answerCycleQuestions(tester);
    await _answerSymptomQuestions(tester);
    await _answerMetabolicAndLifestyle(tester);

    // Q17 — select No
    expect(
      find.text('Are you currently pregnant or could you be pregnant?'),
      findsOneWidget,
    );
    await _tapOption(tester, 'No');

    // Q18 — reproductive context (multi-select)
    expect(
      find.text('Have any of these situations applied to you recently?'),
      findsOneWidget,
    );
    await _tap(tester, 'Recently stopped hormonal contraception');
    await tester.pump();
    await _tap(tester, 'Currently breastfeeding');
    await tester.pump();
    await _tapContinue(tester);

    // Q19 — known medical condition; stays answered with No
    expect(
      find.text(
        'Do you have any known medical condition that affects your menstrual cycle?',
      ),
      findsOneWidget,
    );
    await _tapOption(tester, 'No');

    // Standard result stage
    expect(find.textContaining('Thank you,'), findsOneWidget);
    expect(
      find.textContaining('these answers cannot diagnose PCOS'),
      findsOneWidget,
    );
    expect(
      find.textContaining('can affect menstrual patterns on their own'),
      findsOneWidget,
    );

    // Verify all Q1-Q19 answers captured in state
    final context = tester.element(find.textContaining('Thank you,'));
    final container = ProviderScope.containerOf(context);
    final state = container.read(onboardingProvider);
    expect(state.ageRange, '18–24');
    expect(state.heightCm, greaterThanOrEqualTo(100));
    expect(state.weightKg, greaterThanOrEqualTo(30));
    expect(state.bmi, isNotNull);
    expect(state.periodRegularityRisk, 'Regular');
    expect(state.typicalCycleLength, '21–35 days');
    expect(state.periodGap90Days, 'No');
    expect(state.periodChangeHistory, 'No');
    expect(state.facialBodyHairGrowth, 'Mild');
    expect(state.acneSeverity, 'No');
    expect(state.scalpHairThinning, 'No');
    expect(state.recentWeightChange, 'Weight gain');
    expect(state.familyConditions, ['PCOS']);
    expect(state.diagnosedMetabolicConditions, ['High blood pressure']);
    expect(state.physicalActivity, 'Moderate activity');
    expect(state.sleepDuration, '7–9');
    expect(state.stressLevel, 3);
    expect(state.pregnancyStatus, 'No');
    expect(state.reproductiveContext, [
      'Recently stopped hormonal contraception',
      'Currently breastfeeding',
    ]);
    expect(state.menstrualAffectingCondition, 'No');
  });

  testWidgets('PREFER NOT TO SAY -> Early Risk Assessment Q1', (tester) async {
    await tester.pumpWidget(_wrap(const OnboardingPcosScreen()));

    await _tap(tester, 'Prefer not to say');
    await tester.pump();
    await _tapContinue(tester);

    expect(find.text('What is your age?'), findsOneWidget);
  });

  testWidgets('YES -> existing Management Profile (DiagnosedByScreen)', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const OnboardingPcosScreen()));

    await _tap(tester, 'Yes, I have PCOS, PCOD, or PMOS');
    await tester.pump();
    await _tapContinue(tester);

    expect(find.text('Who diagnosed you?'), findsOneWidget);
  });

  testWidgets('Q17 = Yes -> pregnancy-aware outcome, no standard screening', (
    tester,
  ) async {
    await _enterBranch(tester);
    await _answerBasicInfo(tester);
    await _answerCycleQuestions(tester);
    await _answerSymptomQuestions(tester);
    await _answerMetabolicAndLifestyle(tester);

    expect(
      find.text('Are you currently pregnant or could you be pregnant?'),
      findsOneWidget,
    );
    await _tapOption(tester, 'Yes');

    expect(find.textContaining('Thank you,'), findsOneWidget);
    expect(
      find.textContaining('standard PCOS screening interpretation'),
      findsOneWidget,
    );
    expect(find.textContaining('we haven’t generated one'), findsOneWidget);
    final container = ProviderScope.containerOf(
      tester.element(find.textContaining('Thank you,')),
    );
    expect(container.read(onboardingProvider).pregnancyStatus, 'Yes');
  });

  testWidgets(
    'Q17 = Not sure -> pregnancy-aware outcome, no standard screening',
    (tester) async {
      await _enterBranch(tester);
      await _answerBasicInfo(tester);
      await _answerCycleQuestions(tester);
      await _answerSymptomQuestions(tester);
      await _answerMetabolicAndLifestyle(tester);

      expect(
        find.text('Are you currently pregnant or could you be pregnant?'),
        findsOneWidget,
      );
      await _tapOption(tester, 'Not sure');

      expect(find.textContaining('Thank you,'), findsOneWidget);
      expect(
        find.textContaining('standard PCOS screening interpretation'),
        findsOneWidget,
      );
      final container = ProviderScope.containerOf(
        tester.element(find.textContaining('Thank you,')),
      );
      expect(container.read(onboardingProvider).pregnancyStatus, 'Not sure');
    },
  );

  testWidgets("Q12 multi-select: None/Don't know are mutually exclusive", (
    tester,
  ) async {
    await _enterBranch(tester);
    await _answerBasicInfo(tester);
    await _answerCycleQuestions(tester);
    await _answerSymptomQuestions(tester);

    // Q11
    await _tapOption(tester, 'Weight gain');

    // Q12
    expect(
      find.text('Does anyone in your immediate family have:'),
      findsOneWidget,
    );
    await _tap(tester, 'PCOS');
    await tester.pump();
    await _tap(tester, 'Type 2 diabetes');
    await tester.pump();

    var container = ProviderScope.containerOf(
      tester.element(find.text('Does anyone in your immediate family have:')),
    );
    expect(container.read(onboardingProvider).familyConditions, [
      'PCOS',
      'Type 2 diabetes',
    ]);

    // Selecting None clears everything else.
    await _tap(tester, 'None');
    await tester.pump();
    container = ProviderScope.containerOf(
      tester.element(find.text('Does anyone in your immediate family have:')),
    );
    expect(container.read(onboardingProvider).familyConditions, ['None']);

    // Selecting a condition clears None.
    await _tap(tester, 'PCOS');
    await tester.pump();
    container = ProviderScope.containerOf(
      tester.element(find.text('Does anyone in your immediate family have:')),
    );
    expect(container.read(onboardingProvider).familyConditions, ['PCOS']);
  });

  testWidgets('Q13 multi-select: healthy conditions combine, exclude None', (
    tester,
  ) async {
    await _enterBranch(tester);
    await _answerBasicInfo(tester);
    await _answerCycleQuestions(tester);
    await _answerSymptomQuestions(tester);

    await _tapOption(tester, 'Weight gain');
    await _tap(tester, 'PCOS');
    await tester.pump();
    await _tapContinue(tester);

    // Q13
    expect(
      find.text('Have you ever been told by a doctor that you have:'),
      findsOneWidget,
    );
    await _tap(tester, 'High blood sugar');
    await tester.pump();
    await _tap(tester, 'High blood pressure');
    await tester.pump();
    await _tap(tester, "Don't know");
    await tester.pump();

    var container = ProviderScope.containerOf(
      tester.element(
        find.text('Have you ever been told by a doctor that you have:'),
      ),
    );
    expect(container.read(onboardingProvider).diagnosedMetabolicConditions, [
      "Don't know",
    ]);

    await _tap(tester, 'High cholesterol');
    await tester.pump();
    container = ProviderScope.containerOf(
      tester.element(
        find.text('Have you ever been told by a doctor that you have:'),
      ),
    );
    expect(container.read(onboardingProvider).diagnosedMetabolicConditions, [
      'High cholesterol',
    ]);
  });

  testWidgets('Q18 reproductive context: exclusive None of these / Not sure', (
    tester,
  ) async {
    await _enterBranch(tester);
    await _answerBasicInfo(tester);
    await _answerCycleQuestions(tester);
    await _answerSymptomQuestions(tester);
    await _answerMetabolicAndLifestyle(tester);

    // Q17 = No
    await _tapOption(tester, 'No');

    // Q18
    expect(
      find.text('Have any of these situations applied to you recently?'),
      findsOneWidget,
    );
    await _tap(tester, 'Currently breastfeeding');
    await tester.pump();
    await _tap(tester, 'Recently gave birth / postpartum');
    await tester.pump();

    var container = ProviderScope.containerOf(
      tester.element(
        find.text('Have any of these situations applied to you recently?'),
      ),
    );
    expect(container.read(onboardingProvider).reproductiveContext, [
      'Currently breastfeeding',
      'Recently gave birth / postpartum',
    ]);

    // Not sure clears everything else.
    await _tap(tester, 'Not sure');
    await tester.pump();
    container = ProviderScope.containerOf(
      tester.element(
        find.text('Have any of these situations applied to you recently?'),
      ),
    );
    expect(container.read(onboardingProvider).reproductiveContext, [
      'Not sure',
    ]);
  });

  testWidgets('Back navigation preserves Q11-Q16 answers', (tester) async {
    await _enterBranch(tester);
    await _answerBasicInfo(tester);
    await _answerCycleQuestions(tester);
    await _answerSymptomQuestions(tester);
    await _answerMetabolicAndLifestyle(tester);

    // On Q17 now. Go back to Q16.
    expect(
      find.text('Are you currently pregnant or could you be pregnant?'),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text('How would you describe your stress level?'),
      findsOneWidget,
    );
    var container = ProviderScope.containerOf(
      tester.element(find.text('How would you describe your stress level?')),
    );
    expect(container.read(onboardingProvider).stressLevel, 3);
    expect(container.read(onboardingProvider).sleepDuration, '7–9');

    // Change the answer and continue forward again.
    await _tap(tester, '5');
    await tester.pump();
    container = ProviderScope.containerOf(
      tester.element(find.text('How would you describe your stress level?')),
    );
    expect(container.read(onboardingProvider).stressLevel, 5);
    await _tapContinue(tester);

    expect(
      find.text('Are you currently pregnant or could you be pregnant?'),
      findsOneWidget,
    );
  });
}
