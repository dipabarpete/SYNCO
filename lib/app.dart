import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/custom_bottom_nav_bar.dart';
import 'features/home/home_dashboard_screen.dart';
import 'features/whisper_room/whisper_room_screen.dart';
import 'features/kyra/kyra_ai_screen.dart';
import 'features/pink_corner/pink_corner_screen.dart';
import 'features/health/health_tracking_screen.dart';

class HerSyncApp extends ConsumerStatefulWidget {
  const HerSyncApp({super.key});

  @override
  ConsumerState<HerSyncApp> createState() => _HerSyncAppState();
}

class _HerSyncAppState extends ConsumerState<HerSyncApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    WhisperRoomScreen(),
    KyraAiScreen(),
    PinkCornerScreen(),
    HealthTrackingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HerSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Pastel light theme default matching Figma
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
