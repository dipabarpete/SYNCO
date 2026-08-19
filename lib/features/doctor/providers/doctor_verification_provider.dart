import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/doctor_verification.dart';
import '../services/doctor_verification_service.dart';

final doctorVerificationServiceProvider =
    Provider<DoctorVerificationService>((ref) {
  return DoctorVerificationService();
});

/// One-time doctor verification questionnaire state.
///
/// All steps write into this single provider so moving Back / Continue never
/// loses previously entered information.
class DoctorVerificationState {
  final DoctorVerification data;
  final Map<VerificationDocKind, UploadFile> pendingFiles;
  final String password;
  final String confirmPassword;
  final bool isSubmitting;
  final String? errorMessage;

  const DoctorVerificationState({
    this.data = const DoctorVerification(),
    this.pendingFiles = const {},
    this.password = '',
    this.confirmPassword = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  DoctorVerificationState copyWith({
    DoctorVerification? data,
    Map<VerificationDocKind, UploadFile>? pendingFiles,
    String? password,
    String? confirmPassword,
    bool? isSubmitting,
    Object? errorMessage = _unset,
  }) {
    return DoctorVerificationState(
      data: data ?? this.data,
      pendingFiles: pendingFiles ?? this.pendingFiles,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  /// Whether this questionnaire is editing an existing doctor record (i.e. a
  /// resubmission after being asked for changes).
  bool get isEditing => data.userId != null;

  static const Object _unset = Object();
}

final doctorVerificationProvider =
    StateNotifierProvider<DoctorVerificationNotifier, DoctorVerificationState>(
  (ref) => DoctorVerificationNotifier(ref),
);

class DoctorVerificationNotifier
    extends StateNotifier<DoctorVerificationState> {
  final Ref _ref;

  DoctorVerificationNotifier(this._ref) : super(const DoctorVerificationState());

  DoctorVerificationService get _service =>
      _ref.read(doctorVerificationServiceProvider);

  // -------------------------------------------------------------------------
  // PROFESSIONAL INFORMATION
  // -------------------------------------------------------------------------

  void setFullName(String value) =>
      state = state.copyWith(data: state.data.copyWith(fullName: value.trim()));

  void setRegistrationNumber(String value) => state = state.copyWith(
        data: state.data.copyWith(registrationNumber: value.trim()),
      );

  void setRegisteringAuthority(String value) => state = state.copyWith(
        data: state.data.copyWith(registeringAuthority: value.trim()),
      );

  void setQualification(String value) =>
      state = state.copyWith(data: state.data.copyWith(qualification: value.trim()));

  // -------------------------------------------------------------------------
  // IDENTITY
  // -------------------------------------------------------------------------

  void setDateOfBirth(DateTime? value) =>
      state = state.copyWith(data: state.data.copyWith(dateOfBirth: value));

  // -------------------------------------------------------------------------
  // SPECIALIZATION
  // -------------------------------------------------------------------------

  void toggleSpecialization(String value) {
    final current = {...state.data.specializations};
    if (!current.add(value)) current.remove(value);
    state = state.copyWith(
      data: state.data.copyWith(specializations: current.toList()),
    );
  }

  void addCustomSpecialization(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final current = {...state.data.specializations};
    if (current.add(trimmed)) {
      state = state.copyWith(
        data: state.data.copyWith(specializations: current.toList()),
      );
    }
  }

  // -------------------------------------------------------------------------
  // PRACTICE
  // -------------------------------------------------------------------------

  void setClinicName(String value) =>
      state = state.copyWith(data: state.data.copyWith(clinicName: value.trim()));

  void setClinicLocation(String value) => state = state.copyWith(
        data: state.data.copyWith(clinicLocation: value.trim()),
      );

  void setClinicAddress(String value) => state = state.copyWith(
        data: state.data.copyWith(clinicAddress: value.trim()),
      );

  // -------------------------------------------------------------------------
  // CONTACT
  // -------------------------------------------------------------------------

  void setProfessionalEmail(String value) => state = state.copyWith(
        data: state.data.copyWith(professionalEmail: value.trim()),
      );

  void setPhone(String value) =>
      state = state.copyWith(data: state.data.copyWith(phone: value.trim()));

  void setPassword(String value) => state = state.copyWith(password: value);

  void setConfirmPassword(String value) =>
      state = state.copyWith(confirmPassword: value);

  // -------------------------------------------------------------------------
  // DOCUMENTS
  // -------------------------------------------------------------------------

  /// Records a locally selected file. Nothing is uploaded yet - files are
  /// uploaded only when the doctor explicitly submits the verification.
  void pickFile(VerificationDocKind kind, UploadFile file) {
    state = state.copyWith(
      pendingFiles: {...state.pendingFiles, kind: file},
    );
  }

  /// Removes a selected document. A previously uploaded reference (e.g. from
  /// an earlier submission) is removed too so the doctor can replace it.
  void removeFile(VerificationDocKind kind) {
    final pending = {...state.pendingFiles}..remove(kind);
    state = state.copyWith(
      pendingFiles: pending,
      data: state.data.withStored(kind, null),
    );
  }

  // -------------------------------------------------------------------------
  // LOAD / RESET
  // -------------------------------------------------------------------------

  /// Loads an existing verification record (resubmission flow).
  void loadExisting(DoctorVerification data) {
    state = DoctorVerificationState(data: data);
  }

  void reset() {
    state = const DoctorVerificationState();
  }

  // -------------------------------------------------------------------------
  // SUBMIT
  // -------------------------------------------------------------------------

  /// Uploads files, creates/links the authenticated account and persists the
  /// verification record plus the public doctor profile.
  ///
  /// Returns the authenticated doctor user ID, or throws an [Exception] with
  /// a user-friendly message.
  Future<String> submit() async {
    final current = state;
    if (current.isSubmitting) return state.data.userId ?? '';
    state = current.copyWith(isSubmitting: true, errorMessage: null);

    try {
      final uid = await _service.submit(
        data: current.data,
        pendingFiles: current.pendingFiles,
        email: current.data.professionalEmail,
        password: current.password,
        isResubmit: current.isEditing,
      );
      // After a successful submit the files are no longer pending.
      state = DoctorVerificationState(
        data: current.data.copyWith(
          userId: uid,
          status: DoctorVerificationStatus.submitted,
        ),
      );
      return uid;
    } catch (e) {
      final message = _friendlyError(e);
      state = state.copyWith(isSubmitting: false, errorMessage: message);
      throw Exception(message);
    }
  }

  String _friendlyError(Object e) {
    final message = e.toString();
    if (message.contains('weak-password')) {
      return 'Password must be at least 6 characters long.';
    }
    if (message.contains('invalid-email')) {
      return 'Please enter a valid professional email address.';
    }
    if (message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'The password does not match this professional email account.';
    }
    if (message.contains('email-already-in-use')) {
      return 'An account already exists with this email. Please sign in instead.';
    }
    return message.replaceFirst('Exception: ', '');
  }
}
