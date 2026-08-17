import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'data/reproductive_health_topic.dart';
import 'widgets/article_widgets.dart';
import 'widgets/reproductive_health_visuals.dart';

class ReproductiveHealthTopicScreen extends StatelessWidget {
  final ReproductiveHealthTopic topic;

  const ReproductiveHealthTopicScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          topic.title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO
            Text(
              topic.pageTitle,
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic.subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: topic.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: topic.backgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: topic.accentColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(topic.icon, size: 14, color: topic.accentColor),
                  const SizedBox(width: 6),
                  Text(
                    topic.category,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: topic.accentColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // EDUCATIONAL VISUAL
            ReproductiveHealthVisual(topic: topic),

            // A. WHAT IS IT?
            const ArticleSectionHeading(title: 'What is it?', icon: Icons.help_outline_rounded),
            Text(
              topic.whatIsIt,
              style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark),
            ),

            // B. WHAT HAPPENS IN THE BODY?
            const ArticleSectionHeading(title: 'What happens in the body?', icon: Icons.biotech_rounded),
            ArticleInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final point in topic.whatHappensInBody)
                    _buildBullet(point, topic.accentColor),
                ],
              ),
            ),

            // C. WHAT IS GENERALLY NORMAL?
            const ArticleSectionHeading(title: 'What is generally normal?', icon: Icons.check_circle_outline_rounded),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFFFF0F3),
              borderColor: const Color(0xFFFFD1DC),
              child: Text(
                topic.generallyNormal,
                style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: AppColors.textDark),
              ),
            ),

            // D. WHAT SHOULD I NOTICE?
            const ArticleSectionHeading(title: 'What should I notice?', icon: Icons.visibility_rounded),
            ArticleInfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final point in topic.whatToNotice)
                    _buildBullet(point, topic.accentColor),
                ],
              ),
            ),

            // E. WHAT CAN HELP?
            const ArticleSectionHeading(title: 'What can help?', icon: Icons.lightbulb_outline_rounded),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFF0FDF4),
              borderColor: const Color(0xFFB5EAD7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final point in topic.whatCanHelp)
                    _buildBullet(point, topic.accentColor),
                ],
              ),
            ),

            // F. MYTH VS FACT (already shown as the visual for Fertility Myths)
            if (topic.visualType != ReproductiveVisualType.mythFactCards) ...[
              const ArticleSectionHeading(title: 'Myth vs fact', icon: Icons.fact_check_rounded),
              MythFactCards(myths: topic.myths),
            ],

            // G. WHEN SHOULD I SEE A DOCTOR?
            const ArticleSectionHeading(title: 'When should I see a doctor?', icon: Icons.local_hospital_rounded),
            ArticleInfoCard(
              backgroundColor: const Color(0xFFFBF0DF),
              borderColor: AppColors.pendingAmber.withValues(alpha: 0.5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.pendingAmber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic.whenToSeeDoctor,
                      style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),

            // H. QUICK TAKEAWAY
            const ArticleSectionHeading(title: 'Quick takeaway', icon: Icons.bookmark_rounded),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: topic.accentColor.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: topic.accentColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_rounded, size: 18, color: topic.accentColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic.quickTakeaway,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // EDUCATIONAL NOTICE
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'This information is educational, not a diagnosis. Persistent or concerning symptoms should be evaluated by a healthcare professional.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 11.5, height: 1.5, color: AppColors.textLight),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(fontSize: 13, height: 1.45, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}