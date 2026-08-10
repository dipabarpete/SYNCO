import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_profile.dart';

/// Clean authentication result object encapsulating success status, user data, profile, and errors.
class AuthResult {
  final bool isSuccess;
  final User? user;
  final UserProfile? profile;
  final String? errorMessage;
  final bool isRealAuthPending;

  const AuthResult({
    required this.isSuccess,
    this.user,
    this.profile,
    this.errorMessage,
    this.isRealAuthPending = false,
  });

  factory AuthResult.success({
    User? user,
    UserProfile? profile,
  }) {
    return AuthResult(
      isSuccess: true,
      user: user,
      profile: profile,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }

  factory AuthResult.pendingService(String message) {
    return AuthResult(
      isSuccess: false,
      errorMessage: message,
      isRealAuthPending: true,
    );
  }
}

/// Service layer providing real Supabase Authentication & Profile Management.
class AuthService {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Check if user has an active Supabase session
  Session? get currentSession => _supabase?.auth.currentSession;

  /// Current authenticated Supabase User
  User? get currentUser => _supabase?.auth.currentUser;

  /// Stream of Supabase Auth state changes
  Stream<AuthState> get authStateChanges {
    final client = _supabase;
    if (client == null) return const Stream.empty();
    return client.auth.onAuthStateChange;
  }

  /// Initiates Google OAuth flow using Supabase.
  Future<AuthResult> signInWithGoogle() async {
    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final redirectUrl = kIsWeb
          ? null
          : 'com.hersync.app.hersync://login-callback';

      final success = await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );

      debugPrint('[DIAGNOSTIC] signInWithOAuth launched: $success');
      debugPrint('[DIAGNOSTIC] currentSession immediately after signInWithOAuth launch: ${client.auth.currentSession != null ? "EXISTS" : "NULL (OAuth browser in progress)"}');

      if (success) {
        return AuthResult.success(user: client.auth.currentUser);
      } else {
        return AuthResult.failure('Google OAuth sign-in could not be launched.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(e.message);
    } catch (e) {
      return AuthResult.failure('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Sends Phone OTP using Supabase Auth.
  Future<AuthResult> sendOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanNumber.length < 7) {
        return AuthResult.failure('Please enter a valid phone number.');
      }

      final formattedCountry = countryCode.startsWith('+') ? countryCode : '+$countryCode';
      final fullE164Number = '$formattedCountry$cleanNumber';

      await client.auth.signInWithOtp(
        phone: fullE164Number,
      );

      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Failed to send OTP: ${e.toString()}');
    }
  }

  /// Verifies 6-digit Phone OTP with Supabase Auth.
  Future<AuthResult> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      if (otpCode.length != 6) {
        return AuthResult.failure('Please enter all 6 digits of the OTP code.');
      }

      final AuthResponse response = await client.auth.verifyOTP(
        type: OtpType.sms,
        token: otpCode.trim(),
        phone: phoneNumber.replaceAll(' ', ''),
      );

      if (response.user != null) {
        final profile = await createOrGetProfile(response.user!);
        return AuthResult.success(user: response.user, profile: profile);
      } else {
        return AuthResult.failure('OTP verification failed. Please try again.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Verification failed: ${e.toString()}');
    }
  }

  /// Authenticates using Email and Password with Supabase.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final cleanEmail = email.trim();
      if (cleanEmail.isEmpty) {
        return AuthResult.failure('Email address is required.');
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(cleanEmail)) {
        return AuthResult.failure('Please enter a valid email address.');
      }

      if (password.isEmpty) {
        return AuthResult.failure('Password cannot be empty.');
      }

      final AuthResponse response = await client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (response.user != null) {
        final profile = await createOrGetProfile(response.user!);
        return AuthResult.success(user: response.user, profile: profile);
      } else {
        return AuthResult.failure('Invalid email or password.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  /// Creates a new user account with Email & Password in Supabase.
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final cleanEmail = email.trim();
      if (cleanEmail.isEmpty) {
        return AuthResult.failure('Email address is required.');
      }

      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(cleanEmail)) {
        return AuthResult.failure('Please enter a valid email address.');
      }

      if (password.isEmpty) {
        return AuthResult.failure('Password cannot be empty.');
      }

      if (password.length < 6) {
        return AuthResult.failure('Password must be at least 6 characters long.');
      }

      final AuthResponse response = await client.auth.signUp(
        email: cleanEmail,
        password: password,
      );

      if (response.user != null) {
        final profile = await createOrGetProfile(response.user!);
        return AuthResult.success(user: response.user, profile: profile);
      } else {
        return AuthResult.failure('Sign up failed. Please try again.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Account creation failed: ${e.toString()}');
    }
  }

  /// Sends password reset email link using Supabase Auth.
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final cleanEmail = email.trim();
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(cleanEmail)) {
        return AuthResult.failure('Please enter a valid email address.');
      }

      await client.auth.resetPasswordForEmail(cleanEmail);
      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Password reset failed: ${e.toString()}');
    }
  }

  /// Fetches existing profile or creates a new user profile in the `profiles` table.
  Future<UserProfile> createOrGetProfile(User user) async {
    final client = _supabase;
    if (client != null) {
      try {
        final response = await client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          return UserProfile.fromMap(response);
        }
      } catch (e) {
        debugPrint('Error fetching profile from profiles table: $e');
      }
    }

    // Default values from User metadata if new profile
    final String fallbackName = user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        (user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'SYNCO User');

    final String fallbackAvatar = user.userMetadata?['avatar_url'] ??
        user.userMetadata?['picture'] ??
        '';

    final newProfileMap = {
      'id': user.id,
      'name': fallbackName,
      'email': user.email,
      'phone': user.phone,
      'avatar_url': fallbackAvatar,
      'onboarding_completed': false,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (client != null) {
      try {
        await client.from('profiles').upsert(newProfileMap);
      } catch (e) {
        debugPrint('Note: Profile insert to Supabase DB profiles table: $e');
      }
    }

    return UserProfile.fromMap(newProfileMap);
  }

  /// Persists changes made to an existing profile.
  Future<void> updateProfile(UserProfile profile) async {
    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }
    await client.from('profiles').upsert(profile.toMap());
  }

  /// Signs out the user from Supabase.
  Future<void> signOut() async {
    debugPrint('[DIAGNOSTIC] signOut() WAS CALLED in AuthService!');
    final client = _supabase;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Sign out exception: $e');
      }
    }
  }

  /// Helper to map Supabase AuthException into clean user messages
  String _formatSupabaseError(AuthException exception) {
    final msg = exception.message.toLowerCase();
    if (msg.contains('invalid login credentials') || msg.contains('wrong password')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('user already registered') || msg.contains('already exists')) {
      return 'An account with this email already exists. Please log in.';
    }
    if (msg.contains('invalid otp') || msg.contains('token has expired')) {
      return 'Invalid or expired OTP code. Please request a new code.';
    }
    if (msg.contains('phone number') && msg.contains('invalid')) {
      return 'Invalid phone number format. Please check international format.';
    }
    return exception.message;
  }
}
