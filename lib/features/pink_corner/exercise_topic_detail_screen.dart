import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'data/exercise_topic.dart';
import 'widgets/article_widgets.dart';
import 'widgets/exercise_visuals.dart';

/// Reusable detail screen for any Exercise & Movement educational topic.
///
/// Renders every topic with the same A–H structure: title header, visual
/// guide, what is it, why does it matter, what can it look like, how can I
/// start, what should I notice, myth vs fact, when to get professional
/// guidance, and a quick takeaway — mirroring the other Learn category
/// detail screens.
class ExerciseTopicDetailScreen extends StatelessWidget {
  final ExerciseTopic topic;

  const ExerciseTopicDetailScreen({super.key, required this.topic});

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
          topic.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            ExerciseTopicVisual(topic: topic),

            // A. What is it?
            const ArticleSectionHeading(
              title: 'What is it?',
              icon: Icons.info_outline_rounded,
            ),
            Text(
              topic.whatIsIt,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.6,
                color: AppColors.textDark,
              ),
            ),

            // B. Why does it matter?
            const ArticleSectionHeading(
              title: 'Why does it matter?',
              icon: Icons.favorite_rounded,
            ),
            ArticleInfoCard(
              child: Column(
                children: [
                  for (var i = 0; i < topic.whyItMatters.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == topic.whyItMatters.length - 1 ? 0 : 12,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: topic.accentColor,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              topic.whyItMatters[i],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                height: 1.45,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // C. What can it look like?
            const ArticleSectionHeading(
              title: 'What can it look like?',
              icon: Icons.image_outlined,
            ),
            _BulletList(
              items: topic.whatItCanLookLike,
              icon: Icons.visibility_outlined,
              color: topic.accentColor,
            ),

            // D. How can I start?
            const ArticleSectionHeading(
              title: 'How can I start?',
              icon: Icons.flag_rounded,
            ),
            _BulletList(
              items: topic.howToStart,
              icon: Icons.check_rounded,
              color: const Color(0xFF45B69C),
            ),

            // E. What should I notice?
            const ArticleSectionHeading(
              title: 'What should I notice?',
              icon: Icons.remove_red_eye_outlined,
            ),
            _BulletList(
              items: topic.whatToNotice,
              icon: Icons.healing_rounded,
              color: topic.accentColor,
            ),

            // F. Myth vs Fact
            const ArticleSectionHeading(
              title: 'Myth vs Fact',
              icon: Icons.fact_check_outlined,
            ),
            for (final myth in topic.myths) _MythFactCard(myth: myth),

            // G. When should I get professional guidance?
            const ArticleSectionHeading(
              title: 'When should I get professional guidance?',
              icon: Icons.volunteer_activism_outlined,
            ),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFFFF7ED),
              borderColor: const Color(0xFFFFB085).withValues(alpha: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.support_rounded,
                        size: 20,
                        color: Color(0xFFE8A33D),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          topic.whenToSeekHelp,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.55,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.textMedium,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This information is educational, not a diagnosis or medical advice. '
                            'For your own situation, a qualified healthcare professional is the '
                            'best person to talk to.',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              height: 1.4,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // H. Quick takeaway
            const ArticleSectionHeading(
              title: 'Quick takeaway',
              icon: Icons.star_rounded,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF0F4FF), Color(0xFFE5EBFF)],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: exerciseBlueBorder.withValues(alpha: 0.7),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: topic.accentColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      topic.quickTakeaway,
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            topic.backgroundColor,
            Color.lerp(topic.backgroundColor, topic.accentColor, 0.08)!,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: topic.accentColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: topic.accentColor.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              topic.icon,
              size: 30,
              color: topic.accentColor,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            topic.pageTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            topic.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;

  const _BulletList({
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 14, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      items[i],
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MythFactCard extends StatelessWidget {
  final ExerciseMyth myth;

  const _MythFactCard({required this.myth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Myth: ${myth.myth}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 18,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Fact: ${myth.fact}',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.textDark,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}