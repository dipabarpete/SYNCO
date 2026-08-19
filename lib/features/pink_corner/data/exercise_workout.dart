import 'package:flutter/material.dart';

/// One step inside a workout — a short exercise with a timer, a friendly
/// description, and a simple icon.
class ExerciseStep {
  final String name;
  final String detail;
  final int seconds;
  final IconData icon;

  const ExerciseStep({
    required this.name,
    required this.detail,
    required this.seconds,
    required this.icon,
  });
}

/// A beginner-friendly guided workout.
///
/// Every workout is bodyweight or household-friendly, short, and structured
/// around gentle, well-paced steps. [activityType] maps to the achievement
/// system (e.g. 'strength', 'yoga', 'walk', 'gentle', 'general').
class ExerciseWorkout {
  final String id;
  final String title;
  final String subtitle;
  final int durationMinutes;
  final String difficulty;
  final String activityType;
  final String equipment;
  final String gentleNote;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
  final List<ExerciseStep> steps;

  const ExerciseWorkout({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.durationMinutes,
    required this.difficulty,
    required this.activityType,
    required this.equipment,
    required this.gentleNote,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
    required this.steps,
  });
}