import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
import '../../doctor/models/doctor.dart';
import '../models/doctor_verification.dart';

/// Service responsible for the one-time doctor verification and account
/// creation flow.
///
/// Responsibilities:
///  - Upload verification documents to PRIVATE Firebase Storage folders
///    (`doctor_documents/{uid}/...`). Only the owning doctor can read them.
///  - Create the authenticated doctor account using the professional email +
///    password, or link them to an already signed-in identity.
///  - Persist the verification record in `doctor_verifications/{uid}`
///    (private, owner-only per Firestore rules).
///  - Create the public doctor profile in `doctors/{uid}`. Sensitive
///    documents are never written there.
///  - Update the shared `users/{uid}` document with the doctor role so the
///    app routes the doctor to the Doctor Portal on future logins.
///
/// Passwords are never stored anywhere - they are only handed to Firebase
/// Authentication.
class DoctorVerificationService {
  FirebaseFirestore? get _db => Backend.firestore;

  // -------------------------------------------------------------------------
  // LOOKUP
  // -------------------------------------------------------------------------

  /// Whether a doctor identity exists for [uid]. This checks both the public
  /// profile (`doctors/{uid}`) and the verification record
  /// (`doctor_verifications/{uid}`) so legacy doctors created before this
  /// flow still route straight to the Doctor Portal.
  Future<bool> hasDoctorRecord(String uid) async {
    final db = _db;
    if (db == null || uid.isEmpty) return false;
    try {
      final doctorsDoc = await db.collection('doctors').doc(uid).get();
      if (doctorsDoc.exists) return true;
      final verificationDoc =
          await db.collection('doctor_verifications').doc(uid).get();
      return verificationDoc.exists;
    } catch (e) {
      debugPrint('[DOCTOR_PORTAL] Warning: error checking hasDoctorRecord for $uid: $e');
      return false;
    }
  }

  /// Loads the stored verification record for [uid], or `null` when the
  /// doctor never submitted one.
  Future<DoctorVerification?> getVerification(String uid) async {
    final db = _db;
    if (db == null || uid.isEmpty) return null;
    try {
      final doc = await db.collection('doctor_verifications').doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return DoctorVerification.fromMap(Map<String, dynamic>.from(doc.data()!));
    } catch (e) {
      debugPrint('[DOCTOR_PORTAL] Warning: error fetching getVerification for $uid: $e');
      return null;
    }
  }

  // -------------------------------------------------------------------------
  // SUBMIT
  // -------------------------------------------------------------------------

  /// Submits the verification data for the doctor.
  ///
  /// For a brand new doctor the authenticated account is created with the
  /// professional email + password (or the credentials are linked to an
  /// already signed-in identity). For a resubmission the existing account is
  /// reused - the same authenticated user ID stays associated.
  ///
  /// [pendingFiles] are uploaded to private storage. Sensitive documents are
  /// stored only as references and are never made publicly readable.
  ///
  /// Throws an [Exception] with a user-friendly message on failure.
  Future<String> submit({
    required DoctorVerification data,
    required Map<VerificationDocKind, UploadFile> pendingFiles,
    required String email,
    required String password,
    required bool isResubmit,
  }) async {
    final auth = Backend.auth;
    final db = _db;
    if (auth == null || db == null) {
      throw Exception('Firebase is not initialized. Please try again.');
    }

    final String uid;
    if (isResubmit) {
      final current = auth.currentUser;
      if (current == null) {
        throw Exception('Please sign in again to update your information.');
      }
      uid = current.uid;
    } else {
      uid = await _resolveAccount(
        auth: auth,
        email: email,
        password: password,
      );
    }

    // 1. Upload selected files. This happens only now, on explicit submit.
    // Profile photos are the only file that may appear publicly on the
    // doctor's profile page (`doctor_profiles/{uid}`); every other document
    // goes into the private, owner-only `doctor_documents/{uid}` folder.
    final uploaded = <VerificationDocKind, StoredFile>{};
    for (final entry in pendingFiles.entries) {
      final file = entry.value;
      if (!file.hasContent) continue;
      final bytes = await _readBytes(file);
      final folder = entry.key.isPublicProfileFile
          ? 'doctor_profiles'
          : 'doctor_documents';
      final storagePath = file.extension.isNotEmpty
          ? '$folder/$uid/${entry.key.storageName}.${file.extension}'
          : '$folder/$uid/${entry.key.storageName}';
      final stored = await _uploadFile(
        storagePath: storagePath,
        name: file.name,
        bytes: bytes,
      );
      uploaded[entry.key] = stored;
    }

    var finalData = data;
    for (final entry in uploaded.entries) {
      finalData = finalData.withStored(entry.key, entry.value);
    }
    finalData = finalData.copyWith(
      userId: uid,
      professionalEmail: email.trim(),
      status: DoctorVerificationStatus.submitted,
      submittedAt: DateTime.now(),
    );

    // 2. Save the private verification record.
    await db.collection('doctor_verifications').doc(uid).set(
          {
            ...finalData.toMap(),
            'updatedAt': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );

    // 3. Create / update the public doctor profile. Sensitive documents are
    // never written here.
    final profile = _buildDoctorProfile(uid, finalData);
    final profileMap = profile.toMap();
    profileMap['email'] = email.trim();
    await db.collection('doctors').doc(uid).set(
          profileMap,
          SetOptions(merge: true),
        );

    // 4. Keep the shared user profile in sync so the auth gateway routes the
    // doctor to the Doctor Portal on future logins.
    await db.collection('users').doc(uid).set(
          {
            'name': finalData.fullName,
            'email': email.trim(),
            'avatar_url': finalData.profilePhoto?.url ?? '',
            'role': 'doctor',
            'onboarding_completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          },
          SetOptions(merge: true),
        );

    // 5. Mirror the display name on the authentication profile.
    try {
      await auth.currentUser?.updateDisplayName(finalData.fullName);
      if (finalData.profilePhoto != null) {
        await auth.currentUser
            ?.updatePhotoURL(finalData.profilePhoto!.url);
      }
    } catch (_) {
      // Non-fatal: profile data is already stored in Firestore.
    }

    return uid;
  }

  /// Creates the authenticated account with the professional email+password,
  /// or links the credentials to an already signed-in identity. Returns the
  /// authenticated user ID.
  Future<String> _resolveAccount({
    required fb.FirebaseAuth auth,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();

    final current = auth.currentUser;
    if (current == null) {
      try {
        final result = await auth.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        return result.user!.uid;
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          // The professional email already belongs to an account - verify the
          // password and use that existing identity.
          final result = await auth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          return result.user!.uid;
        }
        rethrow;
      }
    }

    // An identity is already signed in (e.g. Google / phone / user account).
    if (current.email == null ||
        current.email!.toLowerCase() != cleanEmail.toLowerCase()) {
      try {
        await current.linkWithCredential(
          fb.EmailAuthProvider.credential(
            email: cleanEmail,
            password: password,
          ),
        );
        return current.uid;
      } on fb.FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked' ||
            e.code == 'credential-in-use' ||
            e.code == 'email-already-in-use') {
          final result = await auth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          return result.user!.uid;
        }
        rethrow;
      }
    }
    return current.uid;
  }

  /// Builds the public `doctors/{uid}` profile from the verification data.
  Doctor _buildDoctorProfile(String uid, DoctorVerification data) {
    final primarySpecialization = data.specializations.isNotEmpty
        ? data.specializations.first
        : 'General Medicine';
    final hasPractice = data.clinicName.trim().isNotEmpty ||
        data.clinicLocation.trim().isNotEmpty;

    return Doctor(
      id: uid,
      name: data.fullName,
      specialization: primarySpecialization,
      specializations: data.specializations,
      qualifications:
          data.qualification.trim().isNotEmpty ? [data.qualification] : const [],
      licenseId: data.registrationNumber.trim().isEmpty
          ? null
          : data.registrationNumber.trim(),
      experience: '0 Years',
      rating: 0.0,
      reviewCount: 0,
      consultationFee: 50,
      availability: 'Available Today',
      mode: hasPractice
          ? ConsultationMode.offline
          : ConsultationMode.online,
      clinicName: data.clinicName.trim().isEmpty ? null : data.clinicName.trim(),
      clinicLocation: data.clinicLocation.trim().isEmpty
          ? null
          : data.clinicLocation.trim(),
      photoUrl: data.profilePhoto?.url,
      isVerified: false,
      about:
          'Newly registered $primarySpecialization practitioner on SYNCO.',
      availableDays: const [],
      timeSlots: const [],
    );
  }

  // -------------------------------------------------------------------------
  // STORAGE HELPERS
  // -------------------------------------------------------------------------

  Future<Uint8List> _readBytes(UploadFile file) async {
    if (file.bytes != null) return file.bytes!;
    if (file.path != null) {
      return File(file.path!).readAsBytes();
    }
    throw Exception('Selected file could not be read. Please try again.');
  }

  Future<StoredFile> _uploadFile({
    required String storagePath,
    required String name,
    required Uint8List bytes,
  }) async {
    final ref = FirebaseStorage.instance.ref(storagePath);
    await ref.putData(bytes);
    final url = await ref.getDownloadURL();
    return StoredFile(
      name: name,
      storagePath: storagePath,
      url: url,
      uploadedAt: DateTime.now(),
    );
  }
}
