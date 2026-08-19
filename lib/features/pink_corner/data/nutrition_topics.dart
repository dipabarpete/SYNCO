import 'package:flutter/material.dart';
import 'nutrition_topic.dart';
import 'nutrition_topics_part1.dart';
import 'nutrition_topics_part2.dart';
import 'nutrition_topics_part3.dart';

/// All Nutrition educational topics, in reading order.
const List<NutritionTopic> allNutritionTopics = [
  ...nutritionBasicsTopics,
  ...pcosConsciousTopics,
  ...indianEverydayTopics,
];

/// A named group of topics shown as a section in the Nutrition list.
class NutritionGroup {
  final String name;
  final IconData icon;
  final Color accentColor;
  final List<NutritionTopic> topics;

  const NutritionGroup({
    required this.name,
    required this.icon,
    required this.accentColor,
    required this.topics,
  });
}

/// Group ordering + icons for the Nutrition list screen.
const List<({String name, IconData icon, Color accent})> _groupMeta = [
  (name: 'Nutrition Basics', icon: Icons.school_rounded, accent: Color(0xFFE8A33D)),
  (name: 'PCOS-Conscious Eating', icon: Icons.spa_rounded, accent: Color(0xFF2E8B76)),
  (name: 'Indian Everyday Guides', icon: Icons.temple_hindu_rounded, accent: Color(0xFFE07A5F)),
];

/// Topics grouped by category, preserving the intended reading order.
final List<NutritionGroup> nutritionGroups = _groupMeta.map((meta) {
  final topics = allNutritionTopics
      .where((t) => t.category == meta.name)
      .toList(growable: false);
  return NutritionGroup(
    name: meta.name,
    icon: meta.icon,
    accentColor: meta.accent,
    topics: topics,
  );
}).toList(growable: false);