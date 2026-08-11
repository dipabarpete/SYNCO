import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../models/app_user.dart';
import '../../../models/user_profile.dart';

/// Clean authentication result object encapsulating success status, user data, profile, and errors.
class AuthResult {
  final bool isSuccess;
  final AppUser? user;
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
    AppUser? user,
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

/// Service layer providing Firebase Authentication as the primary backend
/// and Supabase Authentication as an automatic fallback.
class AuthService {
  // -------------------------------------------------------------------------
  // BACKEND ACCESS
  // -------------------------------------------------------------------------

  bool get _useFirebase => Backend.useFirebase;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  fb.FirebaseAuth? get _firebaseAuth => Backend.auth;

  /// Current authenticated user across both backends.
  AppUser? get currentUser {
    if (_useFirebase) {
      final user = _firebaseAuth?.currentUser;
      return user != null ? AppUser.fromFirebase(user) : null;
    }
    final user = _supabase?.auth.currentUser;
    return user != null ? AppUser.fromSupabase(user) : null;
  }

  /// Stream of authenticated user changes across both backends.
  Stream<AppUser?> get authStateChanges {
    if (_useFirebase) {
      final auth = _firebaseAuth;
      if (auth == null) return const Stream.empty();
      return auth.authStateChanges().map(
            (user) => user != null ? AppUser.fromFirebase(user) : null,
          );
    }
    final client = _supabase;
    if (client == null) return const Stream.empty();
    return client.auth.onAuthStateChange.map((data) {
      final user = data.session?.user;
      return user != null ? AppUser.fromSupabase(user) : null;
    });
  }

  // -------------------------------------------------------------------------
  // GOOGLE SIGN-IN
  // -------------------------------------------------------------------------

  Future<AuthResult> signInWithGoogle() async {
    if (_useFirebase) {
      final auth = _firebaseAuth;
      if (auth == null) {
        return AuthResult.failure('Firebase client is not initialized.');
      }

      try {
        // On Android, use the native Google Sign-In flow (Google Play
        // Services). The browser-based IDP flow (signInWithProvider) is
        // fragile on Android and intermittently fails with "missing initial
        // state" when the OAuth state stored by GenericIdpActivity is lost.
        if (!kIsWeb &&
            defaultTargetPlatform == TargetPlatform.android) {
          return _signInWithGoogleNative(auth);
        }

        final provider = fb.GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});

        debugPrint(
          '[DIAGNOSTIC] signInWithGoogle (Firebase) launching...',
        );

        final cred = await auth.signInWithProvider(provider);

        debugPrint(
          '[DIAGNOSTIC] Firebase Google sign-in user: '
          '${cred.user?.uid ?? "NONE"}',
        );

        if (cred.user != null) {
          return AuthResult.success(user: AppUser.fromFirebase(cred.user!));
        }
        return AuthResult.failure('Google sign-in did not return a user.');
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(_formatFirebaseAuthError(e));
      } catch (e) {
        return AuthResult.failure('Google Sign-In failed: ${e.toString()}');
      }
    }

    return _signInWithGoogleSupabase();
  }

  /// Native Android Google Sign-In via Play Services. No browser is
  /// involved, so the flaky OAuth browser redirect is completely bypassed.
  Future<AuthResult> _signInWithGoogleNative(fb.FirebaseAuth auth) async {
    debugPrint(
      '[DIAGNOSTIC] signInWithGoogle (Firebase native, Android) launching...',
    );

    try {
      final gsi.GoogleSignIn googleSignIn = gsi.GoogleSignIn();
      final gsi.GoogleSignInAccount? googleUser =
          await googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure('Google sign-in was cancelled.');
      }

      final gsi.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        return AuthResult.failure(
          'Google ID token is missing. The local google-services.json is '
          'outdated - re-download it from the Firebase console '
          '(Project settings → Your apps → Android app) and rebuild.',
        );
      }

      final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final cred = await auth.signInWithCredential(credential);

      debugPrint(
        '[DIAGNOSTIC] Firebase native Google sign-in user: '
        '${cred.user?.uid ?? "NONE"}',
      );

      if (cred.user != null) {
        return AuthResult.success(user: AppUser.fromFirebase(cred.user!));
      }
      return AuthResult.failure('Google sign-in did not return a user.');
    } on fb.FirebaseAuthException catch (e) {
      return AuthResult.failure(_formatFirebaseAuthError(e));
    } catch (e) {
      return AuthResult.failure('Google Sign-In failed: ${e.toString()}');
    }
  }

  Future<AuthResult> _signInWithGoogleSupabase() async {
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

      if (success) {
        final user = client.auth.currentUser;
        return AuthResult.success(
          user: user != null ? AppUser.fromSupabase(user) : null,
        );
      } else {
        return AuthResult.failure('Google OAuth sign-in could not be launched.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Google Sign-In failed: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------------------
  // PHONE OTP
  // -------------------------------------------------------------------------

  String? _pendingVerificationId;

  /// Sends Phone OTP. Firebase resolves the SMS asynchronously, so the
  /// verification id is stored internally and consumed by [verifyOtp].
  Future<AuthResult> sendOtp({
    required String countryCode,
    required String phoneNumber,
  }) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (cleanNumber.length < 7) {
      return AuthResult.failure('Please enter a valid phone number.');
    }

    final formattedCountry = countryCode.startsWith('+') ? countryCode : '+$countryCode';
    final fullE164Number = '$formattedCountry$cleanNumber';

    if (_useFirebase) {
      final auth = _firebaseAuth;
      if (auth == null) {
        return AuthResult.failure('Firebase client is not initialized.');
      }

      final completer = Completer<AuthResult>();

      auth.verifyPhoneNumber(
        phoneNumber: fullE164Number,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          if (completer.isCompleted) return;
          try {
            final cred = await auth.signInWithCredential(phoneAuthCredential);
            if (cred.user != null) {
              final profile =
                  await createOrGetProfile(AppUser.fromFirebase(cred.user!));
              completer.complete(AuthResult.success(
                user: AppUser.fromFirebase(cred.user!),
                profile: profile,
              ));
            } else {
              completer.complete(
                AuthResult.failure('Phone verification failed. Please try again.'),
              );
            }
          } catch (e) {
            completer.complete(
              AuthResult.failure('Phone verification failed: ${e.toString()}'),
            );
          }
        },
        verificationFailed: (error) {
          if (completer.isCompleted) return;
          completer.complete(
            AuthResult.failure(_formatFirebaseAuthError(error)),
          );
        },
        codeSent: (verificationId, resendToken) {
          if (completer.isCompleted) return;
          _pendingVerificationId = verificationId;
          completer.complete(AuthResult.success());
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );

      return completer.future;
    }

    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
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

  /// Verifies 6-digit Phone OTP.
  Future<AuthResult> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    if (otpCode.length != 6) {
      return AuthResult.failure('Please enter all 6 digits of the OTP code.');
    }

    if (_useFirebase) {
      final auth = _firebaseAuth;
      final verificationId = _pendingVerificationId;
      if (auth == null) {
        return AuthResult.failure('Firebase client is not initialized.');
      }
      if (verificationId == null) {
        return AuthResult.failure(
          'No OTP was requested. Please request a new code.',
        );
      }

      try {
        final credential = fb.PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otpCode.trim(),
        );

        final response = await auth.signInWithCredential(credential);

        if (response.user != null) {
          _pendingVerificationId = null;
          final profile =
              await createOrGetProfile(AppUser.fromFirebase(response.user!));
          return AuthResult.success(
            user: AppUser.fromFirebase(response.user!),
            profile: profile,
          );
        } else {
          return AuthResult.failure('OTP verification failed. Please try again.');
        }
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(_formatFirebaseAuthError(e));
      } catch (e) {
        return AuthResult.failure('Verification failed: ${e.toString()}');
      }
    }

    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final AuthResponse response = await client.auth.verifyOTP(
        type: OtpType.sms,
        token: otpCode.trim(),
        phone: phoneNumber.replaceAll(' ', ''),
      );

      if (response.user != null) {
        final profile =
            await createOrGetProfile(AppUser.fromSupabase(response.user!));
        return AuthResult.success(
          user: AppUser.fromSupabase(response.user!),
          profile: profile,
        );
      } else {
        return AuthResult.failure('OTP verification failed. Please try again.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Verification failed: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------------------
  // EMAIL & PASSWORD
  // -------------------------------------------------------------------------

  Future<String?> _validateEmailPassword(String email, String password) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      return 'Email address is required.';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return 'Please enter a valid email address.';
    }

    if (password.isEmpty) {
      return 'Password cannot be empty.';
    }
    return null;
  }

  /// Authenticates using Email and Password.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final validationError = await _validateEmailPassword(email, password);
    if (validationError != null) {
      return AuthResult.failure(validationError);
    }
    final cleanEmail = email.trim();

    if (_useFirebase) {
      final auth = _firebaseAuth;
      if (auth == null) {
        return AuthResult.failure('Firebase client is not initialized.');
      }

      try {
        final response = await auth.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        if (response.user != null) {
          final profile =
              await createOrGetProfile(AppUser.fromFirebase(response.user!));
          return AuthResult.success(
            user: AppUser.fromFirebase(response.user!),
            profile: profile,
          );
        } else {
          return AuthResult.failure('Invalid email or password.');
        }
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(_formatFirebaseAuthError(e));
      } catch (e) {
        return AuthResult.failure('Sign in failed: ${e.toString()}');
      }
    }

    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final AuthResponse response = await client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (response.user != null) {
        final profile =
            await createOrGetProfile(AppUser.fromSupabase(response.user!));
        return AuthResult.success(
          user: AppUser.fromSupabase(response.user!),
          profile: profile,
        );
      } else {
        return AuthResult.failure('Invalid email or password.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  /// Creates a new user account with Email & Password.
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final validationError = await _validateEmailPassword(email, password);
    if (validationError != null) {
      return AuthResult.failure(validationError);
    }
    final cleanEmail = email.trim();

    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters long.');
    }

    if (_useFirebase) {
      final auth = _firebaseAuth;
      if (auth == null) {
        return AuthResult.failure('Firebase client is not initialized.');
      }

      try {
        final response = await auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );

        if (response.user != null) {
          final profile =
              await createOrGetProfile(AppUser.fromFirebase(response.user!));
          return AuthResult.success(
            user: AppUser.fromFirebase(response.user!),
            profile: profile,
          );
        } else {
          return AuthResult.failure('Sign up failed. Please try again.');
        }
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(_formatFirebaseAuthError(e));
      } catch (e) {
        return AuthResult.failure('Account creation failed: ${e.toString()}');
      }
    }

    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      final AuthResponse response = await client.auth.signUp(
        email: cleanEmail,
        password: password,
      );

      if (response.user != null) {
        final profile =
            await createOrGetProfile(AppUser.fromSupabase(response.user!));
        return AuthResult.success(
          user: AppUser.fromSupabase(response.user!),
          profile: profile,
        );
      } else {
        return AuthResult.failure('Sign up failed. Please try again.');
      }
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Account creation failed: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------------------
  // PASSWORD RESET
  // -------------------------------------------------------------------------

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return AuthResult.failure('Please enter a valid email address.');
    }

    if (_useFirebase) {
      final auth = _firebaseAuth;
      if (auth == null) {
        return AuthResult.failure('Firebase client is not initialized.');
      }

      try {
        await auth.sendPasswordResetEmail(email: cleanEmail);
        return AuthResult.success();
      } on fb.FirebaseAuthException catch (e) {
        return AuthResult.failure(_formatFirebaseAuthError(e));
      } catch (e) {
        return AuthResult.failure('Password reset failed: ${e.toString()}');
      }
    }

    final client = _supabase;
    if (client == null) {
      return AuthResult.failure('Supabase client is not initialized.');
    }

    try {
      await client.auth.resetPasswordForEmail(cleanEmail);
      return AuthResult.success();
    } on AuthException catch (e) {
      return AuthResult.failure(_formatSupabaseError(e));
    } catch (e) {
      return AuthResult.failure('Password reset failed: ${e.toString()}');
    }
  }

  // -------------------------------------------------------------------------
  // PROFILE MANAGEMENT
  // -------------------------------------------------------------------------

  /// Fetches existing profile or creates a new one.
  ///
  /// Firebase backend: `users/{uid}` Firestore document.
  /// Supabase fallback: `profiles` table.
  Future<UserProfile> createOrGetProfile(AppUser user) async {
    if (_useFirebase) {
      final firestore = Backend.firestore;
      if (firestore != null) {
        try {
          final docRef = firestore.collection('users').doc(user.id);
          final doc = await docRef.get();

          if (doc.exists) {
            return UserProfile.fromMap(Map<String, dynamic>.from(doc.data()!));
          }
        } catch (e) {
          debugPrint('Error fetching profile from Firestore users/${
              user.id}: $e');
        }
      }

      // Default values from Firebase account metadata if new profile.
      final String fallbackName = user.displayName ??
          (user.email != null && user.email!.contains('@')
              ? user.email!.split('@').first
              : 'SYNCO User');

      final newProfileMap = <String, dynamic>{
        'id': user.id,
        'name': fallbackName,
        'email': user.email,
        'phone': user.phone,
        'avatar_url': user.photoUrl ?? '',
        'onboarding_completed': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (firestore != null) {
        try {
          await firestore.collection('users').doc(user.id).set(newProfileMap);
        } catch (e) {
          debugPrint('Note: Profile insert to Firestore users/${user.id}: $e');
        }
      }

      return UserProfile.fromMap(newProfileMap);
    }

    // --- Supabase fallback -------------------------------------------------
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
    final String fallbackName = user.displayName ??
        user.userMetadata['name'] ??
        (user.email != null && user.email!.contains('@')
            ? user.email!.split('@').first
            : 'SYNCO User');

    final String fallbackAvatar = user.photoUrl ?? '';

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
    if (_useFirebase) {
      final firestore = Backend.firestore;
      if (firestore == null) {
        throw StateError('Firebase client is not initialized.');
      }
      try {
        await firestore
            .collection('users')
            .doc(profile.id)
            .set(profile.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Note: Profile upsert to Firestore users/${profile.id}: $e');
        rethrow;
      }
      return;
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }
    await client.from('profiles').upsert(profile.toMap());
  }

  // -------------------------------------------------------------------------
  // SIGN OUT
  // -------------------------------------------------------------------------

  Future<void> signOut() async {
    debugPrint('[DIAGNOSTIC] signOut() WAS CALLED in AuthService!');
    if (_useFirebase) {
      final auth = _firebaseAuth;
      if (auth != null) {
        try {
          await auth.signOut();
        } catch (e) {
          debugPrint('Firebase sign out exception: $e');
        }
      }
      return;
    }
    final client = _supabase;
    if (client != null) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('Sign out exception: $e');
      }
    }
  }

  // -------------------------------------------------------------------------
  // ERROR MAPPING
  // -------------------------------------------------------------------------

  /// Helper to map a Firebase AuthException into clean user messages.
  String _formatFirebaseAuthError(fb.FirebaseAuthException exception) {
    final code = exception.code;
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'invalid-login-credentials':
      case 'user-not-found':
        return 'Incorrect email or password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'email-already-in-use':
      case 'account-exists-with-different-credential':
        return 'An account with this email already exists. Please log in.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'invalid-verification-code':
      case 'invalid-verification-id':
      case 'session-expired':
        return 'Invalid or expired OTP code. Please request a new code.';
      case 'invalid-phone-number':
        return 'Invalid phone number format. Please check international format.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'operation-not-allowed':
      case 'admin-restricted-operation':
        return 'This sign-in method is currently unavailable.';
      case 'provider-already-linked':
        return 'This account is already linked to this sign-in method.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      default:
        return exception.message ?? 'Authentication failed. Please try again.';
    }
  }

  /// Helper to map Supabase AuthException into clean user messages.
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