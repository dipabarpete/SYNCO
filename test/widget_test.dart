import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/home/home_dashboard_screen.dart';

void main() {
  testWidgets('HerSync Home Dashboard UI smoke test', (WidgetTester tester) async {
    // Build HomeDashboardScreen directly within ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );

    // Verify Home Dashboard header greeting and sections exist
    expect(find.textContaining('Good Morning,'), findsOneWidget);
    expect(find.textContaining('Health Score'), findsOneWidget);
    expect(find.text('Health Data Glance'), findsOneWidget);
    expect(find.text('Period Cycle Overview'), findsOneWidget);
    expect(find.text('My Daily Insights'), findsOneWidget);
    expect(find.text('Upcoming Reminders'), findsOneWidget);
  });
}
