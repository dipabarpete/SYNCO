import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
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
  final sb.User? user;
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

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  factory AuthState.authenticating() =>
      const AuthState(status: AuthStatus.authenticating);

  factory AuthState.authenticated({
    sb.User? user,
    UserProfile? userProfile,
  }) =>
      AuthState(
        status: AuthStatus.authenticated,
        user: user,
        userProfile: userProfile,
      );

  AuthState copyWith({
    AuthStatus? status,
    sb.User? user,
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

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  StreamSubscription<sb.AuthState>? _authSubscription;

  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _initSupabaseListener();
  }

  void _initSupabaseListener() {
    // 1. Check existing session synchronously
    checkInitialAuthStatus();

    // 2. Listen to Supabase auth state changes (initialSession, signedIn, tokenRefreshed, userUpdated, signedOut)
    _authSubscription = _authService.authStateChanges.listen((data) {
      _handleAuthStateChange(data.event, data.session);
    });
  }

  void _handleAuthStateChange(sb.AuthChangeEvent event, sb.Session? session) {
    if ((event == sb.AuthChangeEvent.signedIn ||
            event == sb.AuthChangeEvent.initialSession ||
            event == sb.AuthChangeEvent.tokenRefreshed ||
            event == sb.AuthChangeEvent.userUpdated) &&
        session?.user != null) {
      _setAuthenticatedState(session!.user);
    } else if (event == sb.AuthChangeEvent.signedOut) {
      state = AuthState.unauthenticated();
    } else if (event == sb.AuthChangeEvent.initialSession && session == null) {
      state = AuthState.unauthenticated();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Immediately transitions state to authenticated using user metadata,
  /// then asynchronously fetches the complete DB profile without blocking navigation.
  void _setAuthenticatedState(sb.User user) {
    final fallbackProfile = UserProfile(
      id: user.id,
      username: user.userMetadata?['full_name'] ??
          (user.email != null && user.email!.contains('@')
              ? user.email!.split('@').first
              : 'HerSync User'),
      avatarUrl: user.userMetadata?['avatar_url'] ?? '',
      email: user.email,
      phone: user.phone,
    );

    // Instant synchronous state update so UI routes straight to Dashboard
    state = AuthState.authenticated(
      user: user,
      userProfile: fallbackProfile,
    );

    // Asynchronously update profile from Supabase DB in background
    _authService.createOrGetProfile(user).then((dbProfile) {
      if (mounted && state.status == AuthStatus.authenticated) {
        state = AuthState.authenticated(
          user: user,
          userProfile: dbProfile,
        );
      }
    }).catchError((e) {
      debugPrint('Background profile sync error: $e');
    });
  }

  /// Initial check of current session
  void checkInitialAuthStatus() {
    final session = _authService.currentSession;
    final user = _authService.currentUser;

    if (session != null && user != null) {
      _setAuthenticatedState(user);
    }
  }

  /// Start Google Authentication via OAuth
  Future<void> startGoogleAuth() async {
    state = AuthState.authenticating();
    final result = await _authService.signInWithGoogle();

    if (!result.isSuccess) {
      state = AuthState.unauthenticated().copyWith(
        errorMessage: result.errorMessage ?? 'Google Sign-In failed.',
      );
    }
  }

  /// Send Phone OTP via Supabase
  Future<AuthResult> sendPhoneOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    return await _authService.sendOtp(
      countryCode: countryCode,
      phoneNumber: phoneNumber,
    );
  }

  /// Verify Phone OTP via Supabase
  Future<bool> verifyPhoneOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    state = AuthState.authenticating();
    final result = await _authService.verifyOtp(
      phoneNumber: phoneNumber,
      otpCode: otpCode,
    );

    if (result.isSuccess && result.user != null) {
      _setAuthenticatedState(result.user!);
      return true;
    } else {
      state = AuthState.unauthenticated().copyWith(
        errorMessage: result.errorMessage ?? 'Invalid verification code.',
      );
      return false;
    }
  }

  /// Login with Email & Password
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.authenticating();
    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      _setAuthenticatedState(result.user!);
      return true;
    } else {
      state = AuthState.unauthenticated().copyWith(
        errorMessage: result.errorMessage ?? 'Login failed. Please check details.',
      );
      return false;
    }
  }

  /// Sign Up with Email & Password
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    state = AuthState.authenticating();
    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      _setAuthenticatedState(result.user!);
      return true;
    } else {
      state = AuthState.unauthenticated().copyWith(
        errorMessage: result.errorMessage ?? 'Sign up failed. Please try again.',
      );
      return false;
    }
  }

  /// Send Password Reset
  Future<AuthResult> sendPasswordReset(String email) async {
    return await _authService.sendPasswordResetEmail(email);
  }

  /// Sign out user and reset state
  Future<void> logout() async {
    await _authService.signOut();
    state = AuthState.unauthenticated();
  }

  /// Clear inline messages
  void clearMessages() {
    state = state.copyWith(errorMessage: null, infoNoticeMessage: null);
  }
}
