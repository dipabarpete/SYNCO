import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/app_user.dart';
import '../../../models/user_profile.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final UserProfile? userProfile;
  final String? errorMessage;
  final String? infoNoticeMessage;

  const AuthState({
    required this.status,
    this.user,
    this.userProfile,
    this.errorMessage,
    this.infoNoticeMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      status: AuthStatus.initial,
    );
  }

  factory AuthState.unauthenticated() {
    return const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  factory AuthState.authenticating() {
    return const AuthState(
      status: AuthStatus.authenticating,
    );
  }

  factory AuthState.authenticated({
    AppUser? user,
    UserProfile? userProfile,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      userProfile: userProfile,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    UserProfile? userProfile,
    String? errorMessage,
    String? infoNoticeMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage,
      infoNoticeMessage: infoNoticeMessage,
    );
  }

  bool get isOnboardingCompleted =>
      userProfile?.onboardingCompleted ?? true;
}


// -----------------------------------------------------------------------------
// PROVIDERS
// -----------------------------------------------------------------------------

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);

  return AuthNotifier(authService);
});


// -----------------------------------------------------------------------------
// AUTH NOTIFIER
// -----------------------------------------------------------------------------

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  StreamSubscription<AppUser?>? _authSubscription;

  AuthNotifier(this._authService)
      : super(AuthState.initial()) {
    debugPrint(
      '[AUTH] AuthNotifier created.',
    );

    _initialize();
  }


  // ---------------------------------------------------------------------------
  // INITIAL AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<void> _initialize() async {
    debugPrint(
      '[AUTH] Starting authentication initialization...',
    );

    try {
      // ---------------------------------------------------------
      // STEP 1:
      // Check the session that was persisted on device.
      // ---------------------------------------------------------

      final user = _authService.currentUser;

      debugPrint(
        '[AUTH] Persisted session: '
        '${user != null ? "EXISTS" : "NULL"}',
      );

      if (user != null) {
        debugPrint(
          '[AUTH] Restored user ID: ${user.id}',
        );

        // We have a valid persisted session.
        // Immediately mark the user as authenticated.
        await _setAuthenticatedState(user);
      } else {
        // No previous login exists.
        state = AuthState.unauthenticated();

        debugPrint(
          '[AUTH] No persisted session. User is unauthenticated.',
        );
      }

      // ---------------------------------------------------------
      // STEP 2:
      // Listen for future authentication changes.
      // ---------------------------------------------------------

      _authSubscription =
          _authService.authStateChanges.listen((user) {
        debugPrint(
          '[AUTH] Auth event user: '
          '${user?.id ?? "NONE"}',
        );

        _handleAuthStateChange(user);
      });

      debugPrint(
        '[AUTH] Authentication initialization completed.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '[AUTH] Authentication initialization ERROR: $e',
      );

      debugPrint(
        '[AUTH] Stack trace: $stackTrace',
      );

      if (mounted) {
        state = AuthState.unauthenticated().copyWith(
          errorMessage: 'Unable to restore authentication session.',
        );
      }
    }
  }


  // ---------------------------------------------------------------------------
  // HANDLE AUTH EVENTS
  // ---------------------------------------------------------------------------

  void _handleAuthStateChange(
    AppUser? user,
  ) {
    debugPrint(
      '[AUTH] Handling auth state change.',
    );

    if (user != null) {
      debugPrint(
        '[AUTH] Valid session detected for user: '
        '${user.id}',
      );

      _setAuthenticatedState(user);

      return;
    }

    debugPrint(
      '[AUTH] User signed out or session is null.',
    );

    if (mounted && state.status != AuthStatus.unauthenticated) {
      state = AuthState.unauthenticated();
    }
  }


  // ---------------------------------------------------------------------------
  // SET AUTHENTICATED STATE
  // ---------------------------------------------------------------------------

  Future<void> _setAuthenticatedState(
    AppUser user,
  ) async {
    debugPrint(
      '[AUTH] Setting authenticated state for: ${user.id}',
    );

    // ---------------------------------------------------------
    // Create a temporary profile from Auth account metadata.
    //
    // This allows the UI to go to the dashboard immediately
    // without waiting for the database profile request.
    // ---------------------------------------------------------

    final fallbackProfile = UserProfile(
      id: user.id,
      username: user.displayName ??
          (
            user.email != null &&
            user.email!.contains('@')
                ? user.email!.split('@').first
                : 'SYNCO User'
          ),
      avatarUrl: user.photoUrl ?? '',
      email: user.email,
      phone: user.phone,
    );

    // ---------------------------------------------------------
    // IMPORTANT:
    //
    // Mark the user authenticated immediately.
    // ---------------------------------------------------------

    if (mounted) {
      state = AuthState.authenticated(
        user: user,
        userProfile: fallbackProfile,
      );
    }

    debugPrint(
      '[AUTH] Authenticated state set successfully.',
    );

    // ---------------------------------------------------------
    // Fetch the complete profile from the database.
    // This happens in the background.
    // ---------------------------------------------------------

    try {
      final dbProfile =
          await _authService.createOrGetProfile(user);

      if (mounted &&
          state.status == AuthStatus.authenticated) {
        state = AuthState.authenticated(
          user: user,
          userProfile: dbProfile,
        );

        debugPrint(
          '[AUTH] Database profile loaded successfully.',
        );
      }
    } catch (e) {
      debugPrint(
        '[AUTH] Background profile sync error: $e',
      );

      // IMPORTANT:
      //
      // We DO NOT log the user out if profile loading fails.
      //
      // The authentication session is still valid.
    }
  }


  // ---------------------------------------------------------------------------
  // GOOGLE AUTHENTICATION
  // ---------------------------------------------------------------------------

  Future<void> startGoogleAuth() async {
    state = AuthState.authenticating();

    final result =
        await _authService.signInWithGoogle();

    if (!result.isSuccess) {
      state = AuthState.unauthenticated().copyWith(
        errorMessage:
            result.errorMessage ??
            'Google Sign-In failed.',
      );
    }
  }


  // ---------------------------------------------------------------------------
  // PHONE OTP
  // ---------------------------------------------------------------------------

  Future<AuthResult> sendPhoneOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    return await _authService.sendOtp(
      countryCode: countryCode,
      phoneNumber: phoneNumber,
    );
  }


  // ---------------------------------------------------------------------------
  // VERIFY PHONE OTP
  // ---------------------------------------------------------------------------

  Future<bool> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    state = AuthState.authenticating();

    final result =
        await _authService.verifyOtp(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    if (result.isSuccess &&
        result.user != null) {
      await _setAuthenticatedState(
        result.user!,
      );

      return true;
    }

    state = AuthState.unauthenticated().copyWith(
      errorMessage:
          result.errorMessage ??
          'Invalid verification code.',
    );

    return false;
  }


  // ---------------------------------------------------------------------------
  // EMAIL LOGIN
  // ---------------------------------------------------------------------------

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.authenticating();

    final result =
        await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess &&
        result.user != null) {
      await _setAuthenticatedState(
        result.user!,
      );

      return true;
    }

    state = AuthState.unauthenticated().copyWith(
      errorMessage:
          result.errorMessage ??
          'Login failed. Please check details.',
    );

    return false;
  }


  // ---------------------------------------------------------------------------
  // EMAIL SIGN UP
  // ---------------------------------------------------------------------------

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.authenticating();

    final result =
        await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess &&
        result.user != null) {
      await _setAuthenticatedState(
        result.user!,
      );

      return true;
    }

    state = AuthState.unauthenticated().copyWith(
      errorMessage:
          result.errorMessage ??
          'Sign up failed. Please try again.',
    );

    return false;
  }


  // ---------------------------------------------------------------------------
  // PASSWORD RESET
  // ---------------------------------------------------------------------------

  Future<AuthResult> sendPasswordReset(
    String email,
  ) async {
    return await _authService.sendPasswordResetEmail(
      email,
    );
  }


  // ---------------------------------------------------------------------------
  // LOGOUT
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    debugPrint(
      '[AUTH] Logging out...',
    );

    await _authService.signOut();

    if (mounted) {
      state = AuthState.unauthenticated();
    }

    debugPrint(
      '[AUTH] Logout completed.',
    );
  }


  // ---------------------------------------------------------------------------
  // UPDATE PROFILE
  // ---------------------------------------------------------------------------

  Future<bool> updateLocalProfile(
    UserProfile newProfile,
  ) async {
    state = state.copyWith(
      userProfile: newProfile,
      status: AuthStatus.authenticated,
    );

    try {
      await _authService.updateProfile(
        newProfile,
      );

      debugPrint(
        '[AUTH] Profile updated in backend.',
      );

      return true;
    } catch (e) {
      debugPrint(
        '[AUTH] Error syncing profile to backend: $e',
      );

      // Keep the local authenticated state.
      return false;
    }
  }


  // ---------------------------------------------------------------------------
  // CLEAR MESSAGES
  // ---------------------------------------------------------------------------

  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      infoNoticeMessage: null,
    );
  }


  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    debugPrint(
      '[AUTH] AuthNotifier disposed.',
    );

    _authSubscription?.cancel();

    super.dispose();
  }
}