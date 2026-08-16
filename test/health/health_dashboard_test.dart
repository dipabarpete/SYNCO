import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/health/health_tracking_screen.dart';
import 'package:hersync/features/health/models/health_entries.dart';
import 'package:hersync/features/health/providers/health_data_provider.dart';
import 'package:hersync/features/health/screens/health_history_screen.dart';
import 'package:hersync/features/health/widgets/health_dashboard_widgets.dart';
import 'package:hersync/features/health/widgets/sleep_tracker_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hersync/features/health/data/local_health_data_repository.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpScreen(WidgetTester tester, ProviderContainer container) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HealthTrackingScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        healthRepositoryProvider.overrideWithValue(LocalHealthDataRepository()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  testWidgets('shows Kyra AI header, section titles and all 8 grid cards',
      (tester) async {
    final container = createContainer();
    await pumpScreen(tester, container);

    expect(find.text('Kyra AI'), findsWidgets);
    expect(find.text('SYNCO AI'), findsNothing);
    expect(find.text('Health Trackers'), findsOneWidget);
    expect(find.byType(TrackerGridCard), findsNWidgets(8));

    for (final label in const [
      'Sleep',
      'Water Intake',
      'Step Count',
      'Sugar Cravings',
      'Supplements',
      'Mental Wellness',
      'Food & Nutrition',
      'Weight',
    ]) {
      expect(
        find.descendant(
          of: find.byType(TrackerGridCard),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('empty cards show Not logged placeholders', (tester) async {
    final container = createContainer();
    await pumpScreen(tester, container);

    for (final card in find.byType(TrackerGridCard).evaluate()) {
      expect(
        find.descendant(
          of: find.byWidget(card.widget),
          matching: find.text('Not logged'),
        ),
        findsWidgets,
      );
    }
  });

  testWidgets('tapping a card opens its tracker sheet', (tester) async {
    final container = createContainer();
    await pumpScreen(tester, container);

    await tester.tap(
      find.descendant(
        of: find.byType(TrackerGridCard).first,
        matching: find.text('Sleep'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SleepSheet), findsOneWidget);
  });

  testWidgets('card reflects values saved through the provider', (tester) async {
    final container = createContainer();
    await pumpScreen(tester, container);

    final notifier = container.read(healthDataProvider.notifier);
    final today = dateOnly(DateTime.now());
    final err = await notifier.saveSleep(
      date: today,
      startMinutes: 23 * 60,
      endMinutes: 6 * 60 + 30,
      durationMinutes: 450,
      quality: 'Good',
      factors: const ['Early bedtime'],
    );
    expect(err, isNull);
    await tester.pumpAndSettle();

    final sleepCard = find.descendant(
      of: find.byType(TrackerGridCard).first,
      matching: find.text('Sleep'),
    );
    expect(sleepCard, findsOneWidget);
    expect(find.text('7h 30m'), findsWidgets);
    expect(find.text('Good'), findsWidgets);
  });

  testWidgets('History button navigates to history screen', (tester) async {
    final container = createContainer();
    await pumpScreen(tester, container);

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    expect(find.byType(HealthHistoryScreen), findsOneWidget);
  });
}
