import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'data/stress_wellbeing_topic.dart';
import 'data/stress_wellbeing_tools.dart';
import 'data/stress_wellbeing_topics.dart';
import 'stress_wellbeing_topic_detail_screen.dart';
import 'tools/breathing_tool_screen.dart';
import 'tools/grounding_tool_screen.dart';
import 'tools/journal_tool_screen.dart';
import 'tools/meditation_tool_screen.dart';
import 'tools/pmr_tool_screen.dart';
import 'tools/screen_breaks_tool_screen.dart';
import 'tools/social_connection_tool_screen.dart';
import 'tools/stress_checkin_tool_screen.dart';
import 'tools/walking_tool_screen.dart';
import 'widgets/article_widgets.dart';
import 'widgets/topic_card.dart';

/// Entry screen for the Stress & Well-being card inside Learn.
///
/// Shows the educational topic groups, the nine practical tools, and — front
/// and centre — a prominent "When should I seek professional help?" banner.
class StressWellbeingScreen extends StatelessWidget {
  const StressWellbeingScreen({super.key});

  static const Color _mintDeep = Color(0xFF45B69C);
  static const Color _mintLight = Color(0xFFE2F5EE);
  static const Color _mintCardBg = Color(0xFFF0FDF4);

  void _openTool(BuildContext context, StressTool tool) {
    final Widget screen = switch (tool.id) {
      'breathing' => const BreathingToolScreen(),
      'meditation' => const MeditationToolScreen(),
      'journaling' => const JournalToolScreen(),
      'grounding' => const GroundingToolScreen(),
      'muscle-relaxation' => const PmrToolScreen(),
      'walking' => const WalkingToolScreen(),
      'social-connection' => const SocialConnectionToolScreen(),
      'screen-breaks' => const ScreenBreaksToolScreen(),
      'stress-checkin' => const StressCheckInToolScreen(),
      _ => throw StateError('Unknown tool id: ${tool.id}'),
    };
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          'Stress & Wellbeing',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Intro hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_mintCardBg, _mintLight],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: stressMintBorder.withValues(alpha: 0.7),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.self_improvement_rounded,
                      color: _mintDeep,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Understand stress, gently',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Simple guides to stress and emotional well-being, gentle tools to try, '
                          'and honest guidance on when professional support can help — all in one calm place.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            height: 1.5,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Professional-help banner (clearly visible, right after the hero)
            _SeekHelpBanner(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StressWellbeingTopicDetailScreen(
                      topic: seekProfessionalHelpTopic,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 1. Group — Understanding Stress
            const ArticleSectionHeading(
              title: 'Understanding Stress',
              icon: Icons.waves_rounded,
            ),
            _TopicGrid(
              topics: stressWellbeingGroups[0].topics,
              showSubtitle: false,
              onTap: (topic) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StressWellbeingTopicDetailScreen(
                      topic: topic,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            // 2. Group — Mental Well-being
            const ArticleSectionHeading(
              title: 'Mental Well-being',
              icon: Icons.favorite_outline_rounded,
            ),
            _TopicGrid(
              topics: stressWellbeingGroups[1].topics,
              showSubtitle: false,
              onTap: (topic) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StressWellbeingTopicDetailScreen(
                      topic: topic,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 22),

            // 3. Group — Practical Tools
            const ArticleSectionHeading(
              title: 'Practical Tools',
              icon: Icons.self_improvement_rounded,
            ),
            _ToolGrid(
              tools: allStressTools,
              onTap: (tool) => _openTool(context, tool),
            ),
            const SizedBox(height: 22),

            // Support reminder
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE8A33D).withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.volunteer_activism_rounded,
                        size: 18,
                        color: Color(0xFFE8A33D),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Support is always available',
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This app can\u2019t replace people. If you\u2019re in immediate danger or feel you '
                    'can\u2019t keep yourself safe, please reach out right away to a trusted person or '
                    'local emergency services.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

const Color stressMintBorder = Color(0xFFB5EAD7);

/// 2-column grid of educational topics, matching the other Learn categories.
class _TopicGrid extends StatelessWidget {
  final List<StressWellbeingTopic> topics;
  final void Function(StressWellbeingTopic) onTap;
  final bool showSubtitle;

  const _TopicGrid({
    required this.topics,
    required this.onTap,
    this.showSubtitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: topics.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final topic = topics[index];
        return TopicCard(
          title: topic.title,
          subtitle: showSubtitle ? topic.shortDescription : null,
          icon: topic.icon,
          backgroundColor: topic.backgroundColor,
          borderColor: topic.accentColor.withValues(alpha: 0.35),
          iconColor: topic.accentColor,
          onTap: () => onTap(topic),
        );
      },
    );
  }
}

/// 2-column grid of interactive tools, sharing the same card system.
class _ToolGrid extends StatelessWidget {
  final List<StressTool> tools;
  final void Function(StressTool) onTap;

  const _ToolGrid({required this.tools, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return TopicCard(
          title: tool.title,
          subtitle: tool.subtitle,
          icon: tool.icon,
          backgroundColor: tool.backgroundColor,
          borderColor: tool.accentColor.withValues(alpha: 0.35),
          iconColor: tool.accentColor,
          onTap: () => onTap(tool),
        );
      },
    );
  }
}

/// Prominent, clearly visible banner linking to the professional-help guide.
class _SeekHelpBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _SeekHelpBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF7E8), Color(0xFFFFFBEF)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE8A33D).withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                color: Color(0xFFE8A33D),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When should I seek professional help?',
                    style: GoogleFonts.outfit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'A calm, clear three-level guide — self-care, considering support, and urgent help.',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      height: 1.4,
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      _LightDot(color: Color(0xFF2E8B76)),
                      SizedBox(width: 6),
                      _LightDot(color: Color(0xFFE8A33D)),
                      SizedBox(width: 6),
                      _LightDot(color: Color(0xFFC94A6E)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }
}

class _LightDot extends StatelessWidget {
  final Color color;

  const _LightDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}