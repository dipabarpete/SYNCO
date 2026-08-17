import 'package:flutter/material.dart';
import 'reproductive_health_topic.dart';
import 'reproductive_health_topics_part1.dart';
import 'reproductive_health_topics_part2.dart';
import 'reproductive_health_topics_part3.dart';
import 'reproductive_health_topics_part4.dart';

/// All Reproductive Health topics, in reading order.
const List<ReproductiveHealthTopic> allReproductiveHealthTopics = [
  ...reproductiveHealthTopicsPart1,
  ...reproductiveHealthTopicsPart2,
  ...reproductiveHealthTopicsPart3,
  ...reproductiveHealthTopicsPart4,
];

/// A named group of topics shown as a section in the Reproductive Health list.
class ReproductiveHealthGroup {
  final String name;
  final IconData icon;
  final Color accentColor;
  final List<ReproductiveHealthTopic> topics;

  const ReproductiveHealthGroup({
    required this.name,
    required this.icon,
    required this.accentColor,
    required this.topics,
  });
}

/// Group ordering + icons for the Reproductive Health list screen.
const List<({String name, IconData icon, Color accent})> _groupMeta = [
  (name: 'Know Your Body', icon: Icons.favorite_rounded, accent: Color(0xFF7B4397)),
  (name: 'Ovulation & Fertility', icon: Icons.wb_twilight_rounded, accent: Color(0xFFC94A6E)),
  (name: 'Sexual & Reproductive Health', icon: Icons.volunteer_activism_rounded, accent: Color(0xFF9D76C1)),
  (name: 'Important Symptoms', icon: Icons.healing_rounded, accent: Color(0xFFFFB085)),
  (name: 'When to See a Gynecologist', icon: Icons.monitor_heart_rounded, accent: Color(0xFFC94A6E)),
];

/// Topics grouped by category, preserving the intended reading order.
final List<ReproductiveHealthGroup> reproductiveHealthGroups = _groupMeta.map((meta) {
  final topics = allReproductiveHealthTopics
      .where((t) => t.category == meta.name)
      .toList(growable: false);
  return ReproductiveHealthGroup(
    name: meta.name,
    icon: meta.icon,
    accentColor: meta.accent,
    topics: topics,
  );
}).toList(growable: false);
