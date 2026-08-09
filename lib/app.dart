import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/custom_bottom_nav_bar.dart';
import 'models/user_profile.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/welcome_login_screen.dart';
import 'features/onboarding/screens/role_selection_screen.dart';
import 'features/doctor/screens/doctor_dashboard_screen.dart';
import 'features/home/home_dashboard_screen.dart';
import 'features/whisper_room/whisper_room_screen.dart';
import 'features/kyra/kyra_ai_screen.dart';
import 'features/pink_corner/pink_corner_screen.dart';
import 'features/health/health_tracking_screen.dart';

class HerSyncApp extends ConsumerWidget {
  const HerSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SYNCO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Pastel light theme default matching Figma
      home: const HerSyncAuthGateway(),
    );
  }
}

/// Authentication Gateway directing users through Splash -> Login / Role Selection -> Main Dashboard
class HerSyncAuthGateway extends ConsumerStatefulWidget {
  const HerSyncAuthGateway({super.key});

  @override
  ConsumerState<HerSyncAuthGateway> createState() => _HerSyncAuthGatewayState();
}

class _HerSyncAuthGatewayState extends ConsumerState<HerSyncAuthGateway> {
  bool _isSplashDone = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    debugPrint('[DIAGNOSTIC] HerSyncAuthGateway build: status=${authState.status}, splashDone=$_isSplashDone (file: lib/app.dart)');

    // Show Splash Screen first
    if (!_isSplashDone || authState.status == AuthStatus.initial) {
      return SplashScreen(
        onSplashComplete: () {
          if (mounted) {
            setState(() {
              _isSplashDone = true;
            });
          }
        },
      );
    }

    // After Splash Screen check:
    if (authState.status == AuthStatus.authenticated) {
      // Check if logged in as Consultant / Doctor
      if (authState.userProfile?.role == UserRole.doctor) {
        debugPrint('[DIAGNOSTIC] lib/app.dart -> ROUTING TO DOCTOR DASHBOARD');
        return const DoctorDashboardScreen();
      }

      // If user onboarding is incomplete, route to Role Selection / Onboarding
      if (authState.userProfile?.onboardingCompleted == false) {
        debugPrint('[DIAGNOSTIC] lib/app.dart -> ROUTING TO ROLE SELECTION / ONBOARDING');
        return const RoleSelectionScreen();
      }

      debugPrint('[DIAGNOSTIC] lib/app.dart -> ROUTING TO USER DASHBOARD (HerSyncMainLayout)');
      return const HerSyncMainLayout();
    } else {
      debugPrint('[DIAGNOSTIC] lib/app.dart -> ROUTING TO LOGIN (WelcomeLoginScreen). Status: ${authState.status}');
      return const WelcomeLoginScreen();
    }
  }
}

/// Existing Main Application Layout with Bottom Navigation Bar
class HerSyncMainLayout extends ConsumerStatefulWidget {
  const HerSyncMainLayout({super.key});

  @override
  ConsumerState<HerSyncMainLayout> createState() => _HerSyncMainLayoutState();
}

class _HerSyncMainLayoutState extends ConsumerState<HerSyncMainLayout> {
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
    return Scaffold(
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
    );
  }
}
