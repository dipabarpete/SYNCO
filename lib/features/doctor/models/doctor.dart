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
  });

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
