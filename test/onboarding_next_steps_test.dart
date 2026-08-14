import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/onboarding/screens/management_profile_screens.dart';
import 'package:hersync/app.dart';

void main() {
  testWidgets('MainGoalScreen Q8 navigation leads to PersonalizedNextStepsScreen',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainGoalScreen(),
        ),
      ),
    );

    // Verify Q8 question appears
    expect(find.text('What is your main goal?'), findsOneWidget);
    expect(find.text('Better understand my PCOS'), findsOneWidget);

    // Tap a goal
    await tester.tap(find.text('Better understand my PCOS'));
    await tester.pump();

    // Tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify PersonalizedNextStepsScreen is displayed!
    expect(find.textContaining('You’re all set,'), findsOneWidget);
    expect(
      find.text('Based on what you shared, here’s how Synco can support you in your everyday wellness journey.'),
      findsOneWidget,
    );
    expect(find.text('Track your cycle & wellness'), findsOneWidget);
    expect(find.text('Get period reminders'), findsOneWidget);
    expect(find.text('Learn & move'), findsOneWidget);
    expect(find.text('Relax & sleep better'), findsOneWidget);
    expect(find.text('Understand your food'), findsOneWidget);
    expect(find.text('Understand your lab reports'), findsOneWidget);
    expect(find.text('See your health trends'), findsOneWidget);
    expect(find.text('Talk to a professional'), findsOneWidget);
    expect(
      find.text('Your journey starts here. Let’s take it one day at a time.'),
      findsOneWidget,
    );
    expect(find.text('Go to My Synco'), findsOneWidget);

    // Tap 'Go to My Synco'
    await tester.tap(find.text('Go to My Synco'));
    await tester.pumpAndSettle();

    // Verify navigating to HerSyncMainLayout
    expect(find.byType(HerSyncMainLayout), findsOneWidget);
  });
}
