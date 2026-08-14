import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_entries.dart';

/// Icon + accent color metadata for each health tracker, matching the SYNCO
/// colour language used by the existing dashboard (sleep purple, water blue,
/// steps mint, etc.).
class TrackerMeta {
  final IconData icon;
  final Color color;

  const TrackerMeta({required this.icon, required this.color});

  static const TrackerMeta sleep = TrackerMeta(
    icon: Icons.bedtime_rounded,
    color: AppColors.sleepColor,
  );
  static const TrackerMeta water = TrackerMeta(
    icon: Icons.water_drop_rounded,
    color: AppColors.waterColor,
  );
  static const TrackerMeta steps = TrackerMeta(
    icon: Icons.directions_walk_rounded,
    color: AppColors.stepsColor,
  );
  static const TrackerMeta sugar = TrackerMeta(
    icon: Icons.cake_rounded,
    color: AppColors.sugarColor,
  );
  static const TrackerMeta supplements = TrackerMeta(
    icon: Icons.medication_rounded,
    color: AppColors.rosePink,
  );
  static const TrackerMeta wellness = TrackerMeta(
    icon: Icons.spa_rounded,
    color: AppColors.softPurpleLight,
  );
  static const TrackerMeta food = TrackerMeta(
    icon: Icons.restaurant_rounded,
    color: AppColors.peachCoral,
  );
  static const TrackerMeta weight = TrackerMeta(
    icon: Icons.monitor_weight_rounded,
    color: AppColors.weightColor,
  );

  static TrackerMeta of(HealthTrackerType type) {
    switch (type) {
      case HealthTrackerType.sleep:
        return sleep;
      case HealthTrackerType.water:
        return water;
      case HealthTrackerType.steps:
        return steps;
      case HealthTrackerType.sugarCravings:
        return sugar;
      case HealthTrackerType.supplements:
        return supplements;
      case HealthTrackerType.mentalWellness:
        return wellness;
      case HealthTrackerType.food:
        return food;
      case HealthTrackerType.weight:
        return weight;
    }
  }

  /// Darker readable text version of the accent for tinted backgrounds.
  Color get strongColor => color == AppColors.stepsColor
      ? const Color(0xFF3E7D5F)
      : color == AppColors.sugarColor
          ? const Color(0xFFD96A75)
          : color;
}