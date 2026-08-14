import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

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

/// Service layer providing Firebase Authentication.
class AuthService {
  fb.FirebaseAuth? get _firebaseAuth => Backend.auth;

  /// Current authenticated user.
  AppUser? get currentUser {
    final user = _firebaseAuth?.currentUser;
    return user != null ? AppUser.fromFirebase(user) : null;
  }

  /// Stream of authenticated user changes.
  Stream<AppUser?> get authStateChanges {
    final auth = _firebaseAuth;
    if (auth == null) return const Stream.empty();
    return auth.authStateChanges().map(
          (user) => user != null ? AppUser.fromFirebase(user) : null,
        );
  }

  // -------------------------------------------------------------------------
  // GOOGLE SIGN-IN
  // -------------------------------------------------------------------------

  Future<AuthResult> signInWithGoogle() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      return AuthResult.failure('Firebase client is not initialized.');
    }

    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        return _signInWithGoogleNative(auth);
      }

      final provider = fb.GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});

      debugPrint('[DIAGNOSTIC] signInWithGoogle (Firebase) launching...');
      final cred = await auth.signInWithProvider(provider);

      debugPrint('[DIAGNOSTIC] Firebase Google sign-in user: ${cred.user?.uid ?? "NONE"}');

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

  Future<AuthResult> _signInWithGoogleNative(fb.FirebaseAuth auth) async {
    debugPrint('[DIAGNOSTIC] signInWithGoogle (Firebase native, Android) launching...');

    try {
      final gsi.GoogleSignIn googleSignIn = gsi.GoogleSignIn();
      final gsi.GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure('Google sign-in was cancelled.');
      }

      final gsi.GoogleSignInAuthentication googleAuth = await googleUser.authentication;

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

      debugPrint('[DIAGNOSTIC] Firebase native Google sign-in user: ${cred.user?.uid ?? "NONE"}');

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

  // -------------------------------------------------------------------------
  // PHONE OTP
  // -------------------------------------------------------------------------

  String? _pendingVerificationId;

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

    final auth = _firebaseAuth;
    if (auth == null) {
      return AuthResult.failure('Firebase client is not initialized.');
    }

    // --- MOCK OTP BYPASS FOR TESTING ---
    if (fullE164Number.contains('5555555555') || fullE164Number.contains('0000000000')) {
      _pendingVerificationId = 'mock_verification_id';
      return AuthResult.success();
    }
    // -----------------------------------

    final completer = Completer<AuthResult>();

    auth.verifyPhoneNumber(
      phoneNumber: fullE164Number,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (phoneAuthCredential) async {
        if (completer.isCompleted) return;
        try {
          final cred = await auth.signInWithCredential(phoneAuthCredential);
          if (cred.user != null) {
            final profile = await createOrGetProfile(AppUser.fromFirebase(cred.user!));
            completer.complete(AuthResult.success(
              user: AppUser.fromFirebase(cred.user!),
              profile: profile,
            ));
          } else {
            completer.complete(AuthResult.failure('Phone verification failed. Please try again.'));
          }
        } catch (e) {
          completer.complete(AuthResult.failure('Phone verification failed: ${e.toString()}'));
        }
      },
      verificationFailed: (error) {
        if (completer.isCompleted) return;
        completer.complete(AuthResult.failure(_formatFirebaseAuthError(error)));
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

  Future<AuthResult> verifyOtp({
    required String phoneNumber,
    required String otpCode,
  }) async {
    if (otpCode.length != 6) {
      return AuthResult.failure('Please enter all 6 digits of the OTP code.');
    }

    final auth = _firebaseAuth;
    final verificationId = _pendingVerificationId;
    if (auth == null) {
      return AuthResult.failure('Firebase client is not initialized.');
    }
    if (verificationId == null) {
      return AuthResult.failure('No OTP was requested. Please request a new code.');
    }

    // --- MOCK OTP BYPASS FOR TESTING ---
    if (verificationId == 'mock_verification_id') {
      if (otpCode == '123456') {
        try {
          final mockEmail = '${phoneNumber.replaceAll(RegExp(r'\D'), '')}@mock.synco.app';
          fb.UserCredential cred;
          try {
            cred = await auth.signInWithEmailAndPassword(email: mockEmail, password: 'mockpassword');
          } catch (_) {
            cred = await auth.createUserWithEmailAndPassword(email: mockEmail, password: 'mockpassword');
          }
          _pendingVerificationId = null;
          final mockAppUser = AppUser.fromFirebase(cred.user!);
          final profile = await createOrGetProfile(mockAppUser);
          return AuthResult.success(user: mockAppUser, profile: profile);
        } catch (e) {
          return AuthResult.failure('Mock sign in failed: $e');
        }
      } else {
        return AuthResult.failure('Invalid mock OTP. Use 123456.');
      }
    }
    // -----------------------------------

    try {
      final credential = fb.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode.trim(),
      );

      final response = await auth.signInWithCredential(credential);

      if (response.user != null) {
        _pendingVerificationId = null;
        final profile = await createOrGetProfile(AppUser.fromFirebase(response.user!));
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

  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final validationError = await _validateEmailPassword(email, password);
    if (validationError != null) {
      return AuthResult.failure(validationError);
    }
    final cleanEmail = email.trim();

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
        final profile = await createOrGetProfile(AppUser.fromFirebase(response.user!));
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
        final profile = await createOrGetProfile(AppUser.fromFirebase(response.user!));
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

  // -------------------------------------------------------------------------
  // PASSWORD RESET
  // -------------------------------------------------------------------------

  Future<AuthResult> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      return AuthResult.failure('Please enter a valid email address.');
    }

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

  // -------------------------------------------------------------------------
  // PROFILE MANAGEMENT
  // -------------------------------------------------------------------------

  Future<UserProfile> createOrGetProfile(AppUser user) async {
    final firestore = Backend.firestore;
    if (firestore != null) {
      try {
        final docRef = firestore.collection('users').doc(user.id);
        final doc = await docRef.get();

        if (doc.exists) {
          return UserProfile.fromMap(Map<String, dynamic>.from(doc.data()!));
        }
      } catch (e) {
        debugPrint('Error fetching profile from Firestore users/${user.id}: $e');
      }
    }

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

  Future<void> updateProfile(UserProfile profile) async {
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
  }

  // -------------------------------------------------------------------------
  // SIGN OUT
  // -------------------------------------------------------------------------

  Future<void> signOut() async {
    debugPrint('[DIAGNOSTIC] signOut() WAS CALLED in AuthService!');
    final auth = _firebaseAuth;
    if (auth != null) {
      try {
        await auth.signOut();
      } catch (e) {
        debugPrint('Firebase sign out exception: $e');
      }
    }
  }

  // -------------------------------------------------------------------------
  // ERROR MAPPING
  // -------------------------------------------------------------------------

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
}