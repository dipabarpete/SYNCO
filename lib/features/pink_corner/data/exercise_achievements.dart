import 'package:flutter/material.dart';

/// An achievement badge that only unlocks when the related activity is
/// actually completed — it is never awarded from inventing activity data.
class ExerciseAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Color background;

  const ExerciseAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.background,
  });
}

/// All achievement badges available in the Exercise & Movement section.
const List<ExerciseAchievement> exerciseAchievements = [
  ExerciseAchievement(
    id: 'first-movement',
    title: 'First Movement',
    description: 'Complete your first movement session.',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFFE8A33D),
    background: Color(0xFFFFF7E8),
  ),
  ExerciseAchievement(
    id: 'streak-3',
    title: '3-Day Streak',
    description: 'Move for three days in a row.',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFFF7A59),
    background: Color(0xFFFFEFEA),
  ),
  ExerciseAchievement(
    id: 'streak-7',
    title: '7-Day Streak',
    description: 'Move for seven days in a row.',
    icon: Icons.whatshot_rounded,
    color: Color(0xFFC94A6E),
    background: Color(0xFFFFF0F3),
  ),
  ExerciseAchievement(
    id: 'sessions-10',
    title: '10 Sessions',
    description: 'Complete ten movement sessions.',
    icon: Icons.stars_rounded,
    color: Color(0xFF5B7FFF),
    background: Color(0xFFF0F4FF),
  ),
  ExerciseAchievement(
    id: 'first-strength',
    title: 'First Strength Session',
    description: 'Complete a strength session.',
    icon: Icons.fitness_center_rounded,
    color: Color(0xFF7B4397),
    background: Color(0xFFF4EFFB),
  ),
  ExerciseAchievement(
    id: 'first-walk',
    title: 'First Walk',
    description: 'Log your first walk.',
    icon: Icons.directions_walk_rounded,
    color: Color(0xFF45B69C),
    background: Color(0xFFE2F5EE),
  ),
  ExerciseAchievement(
    id: 'first-yoga',
    title: 'First Yoga Session',
    description: 'Complete a yoga session.',
    icon: Icons.self_improvement_rounded,
    color: Color(0xFF9D76C1),
    background: Color(0xFFF5EEFC),
  ),
  ExerciseAchievement(
    id: 'first-mobility',
    title: 'First Mobility Session',
    description: 'Complete a mobility session.',
    icon: Icons.accessibility_new_rounded,
    color: Color(0xFF2E8B76),
    background: Color(0xFFE9F7F1),
  ),
];

/// Encouraging, non-judgmental messages used across the Exercise section.
const List<String> exerciseMotivationMessages = [
  'Nice work.',
  'Consistency matters more than perfection.',
  'You showed up today.',
  'Rest is part of taking care of yourself.',
  'Every small move counts.',
  'Ready to start again?',
];