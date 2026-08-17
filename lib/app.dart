import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_navigator.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/custom_bottom_nav_bar.dart';
import 'models/user_profile.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/welcome_login_screen.dart';

import 'features/onboarding/screens/role_selection_screen.dart';

import 'features/doctor_dashboard/screens/doctor_dashboard_screen.dart';
import 'features/home/home_dashboard_screen.dart';

import 'features/doctor/screens/find_doctor_screen.dart';
import 'features/whisper_room/whisper_room_screen.dart';
import 'features/pink_corner/pink_corner_screen.dart';
import 'features/health/health_tracking_screen.dart';
import 'core/services/notification_controller.dart';


// =============================================================================
// HERSYNC APP
// =============================================================================

class HerSyncApp extends ConsumerWidget {
  const HerSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'SYNCO',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      navigatorKey: AppNavigator.navigatorKey,

      home: const HerSyncAuthGateway(),
    );
  }
}


// =============================================================================
// AUTHENTICATION GATEWAY
// =============================================================================
//
// This widget decides which screen the user should see:
//
// 1. AuthStatus.initial
//       ↓
//    Splash screen while session is restored
//
// 2. AuthStatus.authenticated
//       ↓
//    Dashboard / Doctor Dashboard / Onboarding
//
// 3. AuthStatus.unauthenticated
//       ↓
//    Login screen
//
// =============================================================================

class HerSyncAuthGateway extends ConsumerStatefulWidget {
  const HerSyncAuthGateway({super.key});

  @override
  ConsumerState<HerSyncAuthGateway> createState() =>
      _HerSyncAuthGatewayState();
}

class _HerSyncAuthGatewayState
    extends ConsumerState<HerSyncAuthGateway> {

  bool _isSplashDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Deep-link handler for notification taps: opens the Consultation Room
    // of the appointment carried in the payload.
    NotificationService().onPayloadTap = _handleNotificationPayload;
  }

  void _handleNotificationPayload(String payload) {
    if (!payload.startsWith('consultation:')) return;
    final appointmentId = payload.split(':').last;
    if (appointmentId.isEmpty) return;
    final role = ref.read(authNotifierProvider).userProfile?.role ??
        UserRole.user;
    AppNavigator.openConsultationRoom(appointmentId, role);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    debugPrint(
      '[DIAGNOSTIC] HerSyncAuthGateway build: '
      'status=${authState.status}, '
      'splashDone=$_isSplashDone',
    );


    // -------------------------------------------------------------------------
    // STEP 1: AUTHENTICATION IS STILL BEING INITIALIZED
    // -------------------------------------------------------------------------
    //
    // AuthNotifier starts with AuthStatus.initial.
    //
    // During this period it checks:
    //
    //     Firebase Auth session
    //
    // If a previous session exists, AuthNotifier changes the state to:
    //
    //     AuthStatus.authenticated
    //
    // If there is no session, it changes to:
    //
    //     AuthStatus.unauthenticated
    //
    // We MUST NOT show LoginScreen while status is still "initial".
    // -------------------------------------------------------------------------

    if (authState.status == AuthStatus.initial) {
      return SplashScreen(
        onSplashComplete: () {
          if (!mounted) {
            return;
          }

          setState(() {
            _isSplashDone = true;
          });
        },
      );
    }


    // -------------------------------------------------------------------------
    // STEP 2: AUTH IS READY, BUT SPLASH IS STILL SHOWING
    // -------------------------------------------------------------------------
    //
    // Even after authentication has been restored, we allow your splash
    // screen to finish before showing the actual application.
    // -------------------------------------------------------------------------

    if (!_isSplashDone) {
      return SplashScreen(
        onSplashComplete: () {
          if (!mounted) {
            return;
          }

          setState(() {
            _isSplashDone = true;
          });
        },
      );
    }


    // -------------------------------------------------------------------------
    // STEP 3: USER IS AUTHENTICATED
    // -------------------------------------------------------------------------

    if (authState.status == AuthStatus.authenticated) {

      debugPrint(
        '[DIAGNOSTIC] Authenticated user: '
        '${authState.user?.id ?? "UNKNOWN"}',
      );


      // -----------------------------------------------------------------------
      // DOCTOR / CONSULTANT
      // -----------------------------------------------------------------------

      if (authState.userProfile?.role == UserRole.doctor) {
        debugPrint(
          '[DIAGNOSTIC] ROUTING TO DOCTOR DASHBOARD',
        );

        return const DoctorDashboardScreen();
      }


      // -----------------------------------------------------------------------
      // ONBOARDING NOT COMPLETED
      // -----------------------------------------------------------------------

      if (authState.userProfile?.onboardingCompleted == false) {
        debugPrint(
          '[DIAGNOSTIC] ROUTING TO ROLE SELECTION / ONBOARDING',
        );

        return const RoleSelectionScreen();
      }


      // -----------------------------------------------------------------------
      // NORMAL USER DASHBOARD
      // -----------------------------------------------------------------------

      debugPrint(
        '[DIAGNOSTIC] ROUTING TO USER DASHBOARD',
      );

      return const HerSyncMainLayout();
    }


    // -------------------------------------------------------------------------
    // STEP 4: AUTHENTICATION IS CURRENTLY HAPPENING
    // -------------------------------------------------------------------------
    //
    // For example, during email login / OTP verification.
    //
    // We don't want to show the LoginScreen while authentication is in
    // progress.
    // -------------------------------------------------------------------------

    if (authState.status == AuthStatus.authenticating) {
      return SplashScreen(
        onSplashComplete: () {
          if (!mounted) {
            return;
          }

          setState(() {
            _isSplashDone = true;
          });
        },
      );
    }


    // -------------------------------------------------------------------------
    // STEP 5: USER IS NOT AUTHENTICATED
    // -------------------------------------------------------------------------
    //
    // This is reached only after authentication initialization has completed
    // and backend confirmed that there is no active session.
    // -------------------------------------------------------------------------

    debugPrint(
      '[DIAGNOSTIC] ROUTING TO LOGIN. '
      'Status=${authState.status}',
    );

    return const WelcomeLoginScreen();
  }
}


// =============================================================================
// MAIN APPLICATION LAYOUT
// =============================================================================
//
// Bottom navigation:
//
// 0 → Home
// 1 → Whisper Room
// 2 → Find a Doctor / Consult
// 3 → Pink Corner
// 4 → Health Tracking
//
// =============================================================================

class HerSyncMainLayout extends ConsumerStatefulWidget {
  const HerSyncMainLayout({super.key});

  @override
  ConsumerState<HerSyncMainLayout> createState() =>
      _HerSyncMainLayoutState();
}

class _HerSyncMainLayoutState
    extends ConsumerState<HerSyncMainLayout> {

  int _currentIndex = 0;


  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    WhisperRoomScreen(),
    FindDoctorScreen(),
    PinkCornerScreen(),
    HealthTrackingScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    // Initialize notifications listener for the patient
    ref.read(notificationControllerProvider);

    return Scaffold(

      // -----------------------------------------------------------------------
      // CURRENT SCREEN
      // -----------------------------------------------------------------------

      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(
          _screens.length,
          (i) => TickerMode(
            enabled: i == _currentIndex,
            child: _screens[i],
          ),
        ),
      ),


      // -----------------------------------------------------------------------
      // BOTTOM NAVIGATION
      // -----------------------------------------------------------------------

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