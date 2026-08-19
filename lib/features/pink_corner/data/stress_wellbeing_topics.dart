import 'package:flutter/material.dart';
import 'stress_wellbeing_topic.dart';
import 'stress_wellbeing_topics_part1.dart';
import 'stress_wellbeing_topics_part2.dart';

/// All Stress & Well-being educational topics, in reading order.
const List<StressWellbeingTopic> allStressWellbeingTopics = [
  ...stressWellbeingTopicsPart1,
  ...stressWellbeingTopicsPart2,
];

/// A named group of topics shown as a section in the Stress & Well-being list.
class StressWellbeingGroup {
  final String name;
  final IconData icon;
  final Color accentColor;
  final List<StressWellbeingTopic> topics;

  const StressWellbeingGroup({
    required this.name,
    required this.icon,
    required this.accentColor,
    required this.topics,
  });
}

/// Group ordering + icons for the Stress & Well-being list screen.
const List<({String name, IconData icon, Color accent})> _groupMeta = [
  (
    name: 'Understanding Stress',
    icon: Icons.waves_rounded,
    accent: Color(0xFF45B69C),
  ),
  (
    name: 'Mental Well-being',
    icon: Icons.favorite_outline_rounded,
    accent: Color(0xFF7B4397),
  ),
  (
    name: 'Practical Tools',
    icon: Icons.self_improvement_rounded,
    accent: Color(0xFF2E8B76),
  ),
];

/// Topics grouped by category, preserving the intended reading order.
///
/// The dedicated "When should I seek professional help?" topic has its own
/// category and is rendered separately as a prominent banner on the list
/// screen, so it never appears inside the regular topic grid.
final List<StressWellbeingGroup> stressWellbeingGroups = _groupMeta.map((meta) {
  final topics = allStressWellbeingTopics
      .where((t) => t.category == meta.name)
      .toList(growable: false);
  return StressWellbeingGroup(
    name: meta.name,
    icon: meta.icon,
    accentColor: meta.accent,
    topics: topics,
  );
}).toList(growable: false);

/// The dedicated "When should I seek professional help?" topic, kept available
/// so its detail screen can be pushed from anywhere.
final StressWellbeingTopic seekProfessionalHelpTopic = allStressWellbeingTopics
    .firstWhere((t) => t.id == 'when-to-seek-professional-help');