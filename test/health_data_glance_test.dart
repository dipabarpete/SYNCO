import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hersync/features/home/home_dashboard_screen.dart';

void main() {
  testWidgets('Health Data Glance grid renders without overflow on 360x640 screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Health Data Glance'), findsOneWidget);
    expect(find.text('Weight Progress'), findsOneWidget);
  });

  testWidgets('Health Data Glance grid renders without overflow on 390x844 screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Health Data Glance'), findsOneWidget);
  });
}
