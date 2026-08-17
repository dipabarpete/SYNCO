import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ConsultationMode { online, offline }

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int consultationFee;
  final String availability;
  final ConsultationMode mode;
  final double? distanceKm;
  final String? clinicLocation;
  final String about;
  final List<String> availableDays;
  final List<String> timeSlots;
  final Color avatarBackground;

  /// Number of submitted reviews. The rating is only meaningful when this
  /// count is greater than zero (ratings are recomputed from real reviews).
  final int reviewCount;

  /// Profile photo URL. When empty the UI falls back to the initials avatar.
  final String? photoUrl;

  /// Qualifications such as "MBBS" or "MD", e.g. ['MBBS', 'MD'].
  final List<String> qualifications;

  /// Medical license ID shown on the profile.
  final String? licenseId;

  /// Whether the doctor's credentials have been verified. The "Verified
  /// Doctor" badge is shown only when this is explicitly true.
  final bool isVerified;

  /// Optional gender. Only displayed publicly when [showGender] is true.
  final String? gender;

  /// Whether the doctor has chosen to display their gender on the profile.
  final bool showGender;

  /// All specializations the doctor practices. When empty the legacy single
  /// [specialization] field is used (see [specializationList]).
  final List<String> specializations;

  /// Total consultations provided, when the doctor document tracks it. The
  /// doctor portal prefers the live completed-booking count when available.
  final int consultationsCount;

  /// Hospital/clinic name where offline consultations happen.
  final String? clinicName;

  /// Languages the doctor can speak, e.g. ['English', 'Hindi', 'Bengali'].
  final List<String> languages;

  /// Structured weekly availability entries saved by the doctor, each with
  /// `day`, `start`, `end` and `mode` ('online' | 'offline' | 'both').
  final List<Map<String, dynamic>> availabilitySlots;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.consultationFee,
    required this.availability,
    required this.mode,
    this.distanceKm,
    this.clinicLocation,
    required this.about,
    required this.availableDays,
    required this.timeSlots,
    this.avatarBackground = AppColors.babyPink,
    this.reviewCount = 0,
    this.photoUrl,
    this.qualifications = const [],
    this.licenseId,
    this.isVerified = false,
    this.gender,
    this.showGender = false,
    this.specializations = const [],
    this.consultationsCount = 0,
    this.clinicName,
    this.languages = const [],
    this.availabilitySlots = const [],
  });

  factory Doctor.fromFirestore(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    String safeStr(String key) {
      final val = data[key];
      if (val == null) return '';
      if (val is String) return val;
      return val.toString();
    }
    
    List<String> safeList(String key) {
      final val = data[key];
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }
    String parseAvailability(dynamic val) {
      if (val == null) return 'Available';
      if (val is String) return val;
      if (val is Map) {
        final isOnline = val['online'] == true;
        final isInPerson = val['inPerson'] == true;
        if (isOnline && isInPerson) return 'Online & In-Person';
        if (isOnline) return 'Online Only';
        if (isInPerson) return 'In-Person Only';
        return 'Available';
      }
      return val.toString();
    }

    return Doctor(
      id: doc.id,
      name: safeStr('name'),
      specialization: safeStr('specialization'),
      experience: safeStr('experience'),
      rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
      reviewCount: (data['reviewCount'] is num)
          ? (data['reviewCount'] as num).toInt()
          : 0,
      consultationFee: (data['consultationFee'] is num) ? (data['consultationFee'] as num).toInt() : 0,
      availability: parseAvailability(data['availability']),
      mode: safeStr('mode') == 'offline' ? ConsultationMode.offline : ConsultationMode.online,
      distanceKm: (data['distanceKm'] is num) ? (data['distanceKm'] as num).toDouble() : null,
      clinicLocation: data['clinicLocation']?.toString(),
      about: safeStr('about'),
      availableDays: safeList('availableDays'),
      timeSlots: safeList('timeSlots'),
      photoUrl: data['photoUrl']?.toString(),
      qualifications: safeList('qualifications'),
      licenseId: data['licenseId']?.toString(),
      isVerified: data['isVerified'] == true,
      gender: data['gender']?.toString(),
      showGender: data['showGender'] == true,
      specializations: safeList('specializations'),
      consultationsCount: (data['consultationsCount'] is num)
          ? (data['consultationsCount'] as num).toInt()
          : 0,
      clinicName: data['clinicName']?.toString(),
      languages: safeList('languages'),
      availabilitySlots: _parseAvailabilitySlots(data['availabilitySlots']),
    );
  }

  /// Parses the structured availability entries saved through the doctor
  /// portal. Any malformed entries are ignored so old documents never crash.
  static List<Map<String, dynamic>> _parseAvailabilitySlots(dynamic raw) {
    if (raw is! List) return const [];
    final slots = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if (entry is Map) {
        slots.add(Map<String, dynamic>.from(entry));
      }
    }
    return slots;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'rating': rating,
      'reviewCount': reviewCount,
      'consultationFee': consultationFee,
      'availability': availability,
      'mode': mode == ConsultationMode.offline ? 'offline' : 'online',
      'distanceKm': distanceKm,
      'clinicLocation': clinicLocation,
      'about': about,
      'availableDays': availableDays,
      'timeSlots': timeSlots,
      'photoUrl': photoUrl,
      'qualifications': qualifications,
      'licenseId': licenseId,
      'isVerified': isVerified,
      'gender': gender,
      'showGender': showGender,
      'specializations': specializations,
      'consultationsCount': consultationsCount,
      'clinicName': clinicName,
      'languages': languages,
      'availabilitySlots': availabilitySlots,
    };
  }

  /// All specializations the doctor practices, falling back to the legacy
  /// single [specialization] field when no list is stored.
  List<String> get specializationList {
    if (specializations.isNotEmpty) return specializations;
    final primary = specialization.trim();
    return primary.isEmpty ? const [] : [primary];
  }

  /// The doctor's gender label when they have chosen to display it publicly.
  String? get visibleGender => showGender && gender != null ? gender : null;

  /// Whether the doctor offers offline consultations (clinic visits). Used to
  /// decide whether the Hospital / Clinic section is shown.
  bool get isOfflineConsultant {
    if (mode == ConsultationMode.offline) return true;
    if (clinicName != null && clinicName!.isNotEmpty) return true;
    if (clinicLocation != null && clinicLocation!.isNotEmpty) return true;
    return availabilitySlots.any((s) => s['mode'] != 'online');
  }

  String get initials {
    final parts = name.replaceAll('Dr. ', '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String get modeLabel =>
      mode == ConsultationMode.online ? 'Online' : 'Offline';
}
