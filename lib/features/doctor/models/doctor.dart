import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum ConsultationMode { online, offline }

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int totalReviews;
  final int consultationFee;
  final String availability;
  final ConsultationMode mode;
  final double? distanceKm;
  final String? clinicLocation;
  final String about;
  final List<String> availableDays;
  final List<String> timeSlots;
  final Color avatarBackground;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    this.totalReviews = 0,
    required this.consultationFee,
    required this.availability,
    required this.mode,
    this.distanceKm,
    this.clinicLocation,
    required this.about,
    required this.availableDays,
    required this.timeSlots,
    this.avatarBackground = AppColors.babyPink,
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
    String _parseAvailability(dynamic val) {
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
      totalReviews: (data['totalReviews'] is num) ? (data['totalReviews'] as num).toInt() : 0,
      consultationFee: (data['consultationFee'] is num) ? (data['consultationFee'] as num).toInt() : 0,
      availability: _parseAvailability(data['availability']),
      mode: safeStr('mode') == 'offline' ? ConsultationMode.offline : ConsultationMode.online,
      distanceKm: (data['distanceKm'] is num) ? (data['distanceKm'] as num).toDouble() : null,
      clinicLocation: data['clinicLocation']?.toString(),
      about: safeStr('about'),
      availableDays: safeList('availableDays'),
      timeSlots: safeList('timeSlots'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'rating': rating,
      'totalReviews': totalReviews,
      'consultationFee': consultationFee,
      'availability': availability,
      'mode': mode == ConsultationMode.offline ? 'offline' : 'online',
      'distanceKm': distanceKm,
      'clinicLocation': clinicLocation,
      'about': about,
      'availableDays': availableDays,
      'timeSlots': timeSlots,
    };
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
