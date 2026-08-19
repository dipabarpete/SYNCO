import 'package:flutter/material.dart';

/// Metadata for one interactive Stress & Well-being tool.
///
/// Tools are full interactive experiences (breathing, meditation, journaling,
/// grounding, and more) rather than educational articles. Their screens are
/// resolved by [id] in the Stress & Well-being list screen.
class StressTool {
  final String id;
  final String title;
  final String subtitle;
  final String shortDescription;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;

  const StressTool({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.shortDescription,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });
}

const Color _mintDeep = Color(0xFF45B69C);
const Color _mintDeepAlt = Color(0xFF2E8B76);
const Color _mintLight = Color(0xFFF0FDF4);
const Color _mintLightAlt = Color(0xFFE9F7F1);
const Color _lavender = Color(0xFF7B4397);
const Color _blue = Color(0xFF5B7FFF);
const Color _rose = Color(0xFFE892A2);
const Color _peach = Color(0xFFFFB085);

/// All 9 practical tools, in suggested reading order.
const List<StressTool> allStressTools = [
  StressTool(
    id: 'breathing',
    title: 'Breathing',
    subtitle: 'Guided slow breathing',
    shortDescription: 'A soft circle guides your breath — try a few slow rounds in a pattern that feels comfortable.',
    icon: Icons.air_rounded,
    accentColor: _mintDeep,
    backgroundColor: _mintLight,
  ),
  StressTool(
    id: 'meditation',
    title: 'Meditation',
    subtitle: 'A short, guided pause',
    shortDescription: 'A calm 1–5 minute pause — settle, notice your breathing, relax, and return gently.',
    icon: Icons.self_improvement_rounded,
    accentColor: _mintDeepAlt,
    backgroundColor: _mintLightAlt,
  ),
  StressTool(
    id: 'journaling',
    title: 'Journaling',
    subtitle: 'Private prompt-based writing',
    shortDescription: 'Gentle prompts for your thoughts — saved privately, only visible to you.',
    icon: Icons.edit_note_rounded,
    accentColor: _lavender,
    backgroundColor: Color(0xFFF4EFFB),
  ),
  StressTool(
    id: 'grounding',
    title: 'Grounding',
    subtitle: 'The 5-4-3-2-1 senses walk',
    shortDescription: 'A step-by-step way to settle into the present moment using your five senses.',
    icon: Icons.touch_app_rounded,
    accentColor: _blue,
    backgroundColor: Color(0xFFF0F4FF),
  ),
  StressTool(
    id: 'muscle-relaxation',
    title: 'Muscle Relaxation',
    subtitle: 'Gentle tense-and-release',
    shortDescription: 'A slow body scan — notice, gently tense, release, repeat. You stay in control.',
    icon: Icons.spa_rounded,
    accentColor: _mintDeep,
    backgroundColor: _mintLight,
  ),
  StressTool(
    id: 'walking',
    title: 'Walking',
    subtitle: 'A calm path to movement',
    shortDescription: 'Why gentle walking helps — and how to start small and comfortably.',
    icon: Icons.directions_walk_rounded,
    accentColor: _mintDeepAlt,
    backgroundColor: _mintLightAlt,
  ),
  StressTool(
    id: 'social-connection',
    title: 'Social Connection',
    subtitle: 'Small, honest contact',
    shortDescription: 'Reaching out to trusted people — friends, family, or professionals — and why it helps.',
    icon: Icons.people_alt_rounded,
    accentColor: _rose,
    backgroundColor: Color(0xFFFFF3F6),
  ),
  StressTool(
    id: 'screen-breaks',
    title: 'Screen Breaks',
    subtitle: 'Kind reminders to rest',
    shortDescription: 'Gentle eye-and-body breaks from screens — not rigid rules, just helpful pauses.',
    icon: Icons.smartphone_rounded,
    accentColor: _peach,
    backgroundColor: Color(0xFFFFF7ED),
  ),
  StressTool(
    id: 'stress-checkin',
    title: 'Stress Check-in',
    subtitle: 'A private moment to notice',
    shortDescription: 'A quick, private check-in to notice how you feel — never a diagnosis or a score.',
    icon: Icons.monitor_heart_outlined,
    accentColor: _blue,
    backgroundColor: Color(0xFFF0F4FF),
  ),
];