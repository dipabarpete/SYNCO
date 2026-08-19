import 'package:flutter/foundation.dart';

/// Verification status of a doctor account. The client may only ever set
/// [draft] or [submitted]; the "verified" state must be granted by the
/// backend verification process and is never decided on the device.
enum DoctorVerificationStatus {
  draft,
  submitted,
  pendingVerification,
  verified,
  rejected,
}

extension DoctorVerificationStatusX on DoctorVerificationStatus {
  String toDbValue() {
    switch (this) {
      case DoctorVerificationStatus.draft:
        return 'draft';
      case DoctorVerificationStatus.submitted:
        return 'submitted';
      case DoctorVerificationStatus.pendingVerification:
        return 'pending_verification';
      case DoctorVerificationStatus.verified:
        return 'verified';
      case DoctorVerificationStatus.rejected:
        return 'rejected';
    }
  }

  static DoctorVerificationStatus fromDbValue(String? value) {
    switch (value) {
      case 'draft':
        return DoctorVerificationStatus.draft;
      case 'pending_verification':
        return DoctorVerificationStatus.pendingVerification;
      case 'verified':
        return DoctorVerificationStatus.verified;
      case 'rejected':
        return DoctorVerificationStatus.rejected;
      case 'submitted':
      default:
        return DoctorVerificationStatus.submitted;
    }
  }

  /// Human friendly label shown in the app.
  String get label {
    switch (this) {
      case DoctorVerificationStatus.draft:
        return 'Draft';
      case DoctorVerificationStatus.submitted:
      case DoctorVerificationStatus.pendingVerification:
        return 'Verification Pending';
      case DoctorVerificationStatus.verified:
        return 'Verified Doctor';
      case DoctorVerificationStatus.rejected:
        return 'Needs Changes';
    }
  }
}

/// A document kind collected during doctor verification. Each kind maps to a
/// private storage folder and a field on [DoctorVerification].
enum VerificationDocKind {
  qualificationCertificate,
  registrationCertificate,
  specializationCertificate,
  governmentId,
  profilePhoto,
}

extension VerificationDocKindX on VerificationDocKind {
  /// Storage sub-path used for the private upload of this document.
  String get storageName {
    switch (this) {
      case VerificationDocKind.qualificationCertificate:
        return 'qualification_certificate';
      case VerificationDocKind.registrationCertificate:
        return 'registration_certificate';
      case VerificationDocKind.specializationCertificate:
        return 'specialization_certificate';
      case VerificationDocKind.governmentId:
        return 'government_id';
      case VerificationDocKind.profilePhoto:
        return 'profile_photo';
    }
  }

  bool get isPublicProfileFile =>
      this == VerificationDocKind.profilePhoto;
}

/// A document reference persisted after the file has been uploaded to secure
/// Firebase Storage. Only the storage path and URL are stored - never the
/// file contents.
@immutable
class StoredFile {
  final String name;
  final String storagePath;
  final String url;
  final DateTime uploadedAt;

  const StoredFile({
    required this.name,
    required this.storagePath,
    required this.url,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'storagePath': storagePath,
      'url': url,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory StoredFile.fromMap(Map<String, dynamic> map) {
    return StoredFile(
      name: map['name']?.toString() ?? '',
      storagePath: map['storagePath']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
      uploadedAt: DateTime.tryParse(map['uploadedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

/// A file selected locally by the doctor, still waiting to be uploaded. Files
/// are only uploaded when the doctor explicitly submits for verification.
@immutable
class UploadFile {
  final String name;
  final String extension;
  final String? path;
  final Uint8List? bytes;

  const UploadFile({
    required this.name,
    required this.extension,
    this.path,
    this.bytes,
  });

  bool get hasContent => path != null || bytes != null;
}

/// The complete, one-time doctor verification record. Sensitive documents are
/// stored only as [StoredFile] references pointing at private storage.
@immutable
class DoctorVerification {
  final String? userId;

  // Professional information
  final String fullName;
  final String registrationNumber;
  final String registeringAuthority;
  final String qualification;

  // Credential documents
  final StoredFile? qualificationCertificate;
  final StoredFile? registrationCertificate;
  final StoredFile? specializationCertificate;

  // Identity
  final StoredFile? governmentId;
  final DateTime? dateOfBirth;
  final StoredFile? profilePhoto;

  // Specialty
  final List<String> specializations;

  // Practice
  final String clinicName;
  final String clinicLocation;
  final String clinicAddress;

  // Contact
  final String professionalEmail;
  final String phone;

  // Status
  final DoctorVerificationStatus status;
  final DateTime? submittedAt;

  const DoctorVerification({
    this.userId,
    this.fullName = '',
    this.registrationNumber = '',
    this.registeringAuthority = '',
    this.qualification = '',
    this.qualificationCertificate,
    this.registrationCertificate,
    this.specializationCertificate,
    this.governmentId,
    this.dateOfBirth,
    this.profilePhoto,
    this.specializations = const [],
    this.clinicName = '',
    this.clinicLocation = '',
    this.clinicAddress = '',
    this.professionalEmail = '',
    this.phone = '',
    this.status = DoctorVerificationStatus.draft,
    this.submittedAt,
  });

  DoctorVerification copyWith({
    String? userId,
    String? fullName,
    String? registrationNumber,
    String? registeringAuthority,
    String? qualification,
    Object? qualificationCertificate = _unset,
    Object? registrationCertificate = _unset,
    Object? specializationCertificate = _unset,
    Object? governmentId = _unset,
    Object? dateOfBirth = _unset,
    Object? profilePhoto = _unset,
    List<String>? specializations,
    String? clinicName,
    String? clinicLocation,
    String? clinicAddress,
    String? professionalEmail,
    String? phone,
    DoctorVerificationStatus? status,
    DateTime? submittedAt,
  }) {
    return DoctorVerification(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      registeringAuthority:
          registeringAuthority ?? this.registeringAuthority,
      qualification: qualification ?? this.qualification,
      qualificationCertificate: identical(qualificationCertificate, _unset)
          ? this.qualificationCertificate
          : qualificationCertificate as StoredFile?,
      registrationCertificate: identical(registrationCertificate, _unset)
          ? this.registrationCertificate
          : registrationCertificate as StoredFile?,
      specializationCertificate:
          identical(specializationCertificate, _unset)
          ? this.specializationCertificate
          : specializationCertificate as StoredFile?,
      governmentId: identical(governmentId, _unset)
          ? this.governmentId
          : governmentId as StoredFile?,
      dateOfBirth: identical(dateOfBirth, _unset)
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      profilePhoto: identical(profilePhoto, _unset)
          ? this.profilePhoto
          : profilePhoto as StoredFile?,
      specializations: specializations ?? this.specializations,
      clinicName: clinicName ?? this.clinicName,
      clinicLocation: clinicLocation ?? this.clinicLocation,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      professionalEmail: professionalEmail ?? this.professionalEmail,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  /// The stored (already uploaded) file reference for [kind], if any.
  StoredFile? storedFor(VerificationDocKind kind) {
    switch (kind) {
      case VerificationDocKind.qualificationCertificate:
        return qualificationCertificate;
      case VerificationDocKind.registrationCertificate:
        return registrationCertificate;
      case VerificationDocKind.specializationCertificate:
        return specializationCertificate;
      case VerificationDocKind.governmentId:
        return governmentId;
      case VerificationDocKind.profilePhoto:
        return profilePhoto;
    }
  }

  DoctorVerification withStored(
    VerificationDocKind kind,
    StoredFile? file,
  ) {
    switch (kind) {
      case VerificationDocKind.qualificationCertificate:
        return copyWith(qualificationCertificate: file);
      case VerificationDocKind.registrationCertificate:
        return copyWith(registrationCertificate: file);
      case VerificationDocKind.specializationCertificate:
        return copyWith(specializationCertificate: file);
      case VerificationDocKind.governmentId:
        return copyWith(governmentId: file);
      case VerificationDocKind.profilePhoto:
        return copyWith(profilePhoto: file);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'registrationNumber': registrationNumber,
      'registeringAuthority': registeringAuthority,
      'qualification': qualification,
      'qualificationCertificate': qualificationCertificate?.toMap(),
      'registrationCertificate': registrationCertificate?.toMap(),
      'specializationCertificate': specializationCertificate?.toMap(),
      'governmentId': governmentId?.toMap(),
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'profilePhoto': profilePhoto?.toMap(),
      'specializations': specializations,
      'clinicName': clinicName,
      'clinicLocation': clinicLocation,
      'clinicAddress': clinicAddress,
      'professionalEmail': professionalEmail,
      'phone': phone,
      'status': status.toDbValue(),
      'submittedAt': submittedAt?.toIso8601String(),
    };
  }

  factory DoctorVerification.fromMap(Map<String, dynamic> map) {
    StoredFile? ref(String key) {
      final raw = map[key];
      if (raw is Map) return StoredFile.fromMap(Map<String, dynamic>.from(raw));
      return null;
    }

    return DoctorVerification(
      userId: map['userId']?.toString(),
      fullName: map['fullName']?.toString() ?? '',
      registrationNumber: map['registrationNumber']?.toString() ?? '',
      registeringAuthority: map['registeringAuthority']?.toString() ?? '',
      qualification: map['qualification']?.toString() ?? '',
      qualificationCertificate: ref('qualificationCertificate'),
      registrationCertificate: ref('registrationCertificate'),
      specializationCertificate: ref('specializationCertificate'),
      governmentId: ref('governmentId'),
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.tryParse(map['dateOfBirth'].toString())
          : null,
      profilePhoto: ref('profilePhoto'),
      specializations: (map['specializations'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          const [],
      clinicName: map['clinicName']?.toString() ?? '',
      clinicLocation: map['clinicLocation']?.toString() ?? '',
      clinicAddress: map['clinicAddress']?.toString() ?? '',
      professionalEmail: map['professionalEmail']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      status: DoctorVerificationStatusX.fromDbValue(map['status']?.toString()),
      submittedAt: map['submittedAt'] != null
          ? DateTime.tryParse(map['submittedAt'].toString())
          : null,
    );
  }

  static const Object _unset = Object();
}
