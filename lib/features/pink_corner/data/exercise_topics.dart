import 'package:flutter/material.dart';
import 'exercise_topic.dart';
import 'exercise_topics_part1.dart';

/// All Exercise & Movement educational topics, in reading order.
const List<ExerciseTopic> allExerciseTopics = [
  ...exerciseTopicsPart1,
];

/// A named group of topics shown as a section in the Exercise list.
class ExerciseGroup {
  final String name;
  final IconData icon;
  final Color accentColor;
  final List<ExerciseTopic> topics;

  const ExerciseGroup({
    required this.name,
    required this.icon,
    required this.accentColor,
    required this.topics,
  });
}

/// Group ordering + icons for the Exercise & Movement list screen.
const List<({String name, IconData icon, Color accent})> _groupMeta = [
  (
    name: 'Why Movement Matters',
    icon: Icons.emoji_people_rounded,
    accent: Color(0xFF5B7FFF),
  ),
  (
    name: 'Types of Movement',
    icon: Icons.directions_run_rounded,
    accent: Color(0xFF7B4397),
  ),
  (
    name: 'Movement & Your Cycle',
    icon: Icons.calendar_month_rounded,
    accent: Color(0xFFE892A2),
  ),
  (
    name: 'Movement & PCOS/PCOD',
    icon: Icons.eco_rounded,
    accent: Color(0xFF45B69C),
  ),
];

/// Topics grouped by category, preserving the intended reading order.
final List<ExerciseGroup> exerciseGroups = _groupMeta.map((meta) {
  final topics = allExerciseTopics
      .where((t) => t.category == meta.name)
      .toList(growable: false);
  return ExerciseGroup(
    name: meta.name,
    icon: meta.icon,
    accentColor: meta.accent,
    topics: topics,
  );
}).toList(growable: false);