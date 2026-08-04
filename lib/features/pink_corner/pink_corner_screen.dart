import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'pcos_article_screen.dart';
import 'placeholder_topic_screen.dart';
import 'widgets/faq_card.dart';
import 'widgets/suggestion_card.dart';
import 'widgets/topic_card.dart';

class PinkCornerScreen extends ConsumerWidget {
  const PinkCornerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 6 Topic Cards configuration in EXACT order specified
    final topicItems = [
      {
        'title': 'PCOS/PCOD',
        'icon': Icons.spa_rounded,
        'backgroundColor': const Color(0xFFF4EFFB), // Lavender
        'borderColor': const Color(0xFFD8B4F8).withValues(alpha: 0.6),
        'iconColor': AppColors.softPurple,
      },
      {
        'title': 'Periods',
        'icon': Icons.water_drop_rounded,
        'backgroundColor': const Color(0xFFFFF0F3), // Pink
        'borderColor': const Color(0xFFFFD1DC).withValues(alpha: 0.6),
        'iconColor': AppColors.deepRose,
      },
      {
        'title': 'Body & Wellness',
        'icon': Icons.self_improvement_rounded,
        'backgroundColor': const Color(0xFFF0FDF4), // Mint
        'borderColor': const Color(0xFFB5EAD7).withValues(alpha: 0.6),
        'iconColor': const Color(0xFF45B69C),
      },
      {
        'title': 'Sex & Pleasure',
        'icon': Icons.favorite_rounded,
        'backgroundColor': const Color(0xFFFFF7ED), // Peach
        'borderColor': const Color(0xFFFFB085).withValues(alpha: 0.6),
        'iconColor': AppColors.peachCoral,
      },
      {
        'title': 'Pregnancy',
        'icon': Icons.child_care_rounded,
        'backgroundColor': const Color(0xFFF0F4FF), // Soft Blue
        'borderColor': const Color(0xFFC7CEEA).withValues(alpha: 0.6),
        'iconColor': const Color(0xFF5B7FFF),
      },
      {
        'title': 'Vaginal Discharge',
        'icon': Icons.opacity_rounded,
        'backgroundColor': const Color(0xFFF8F0FF), // Lilac
        'borderColor': const Color(0xFFE0C3FC).withValues(alpha: 0.6),
        'iconColor': AppColors.softPurpleLight,
      },
    ];

    final suggestedArticles = [
      {
        'title': 'Understanding Your Cycle & Hormones',
        'category': 'Cycle Syncing',
        'description': 'A complete guide to how estrogen and progesterone affect your energy and mood.',
        'icon': Icons.auto_awesome_rounded,
        'iconColor': AppColors.softPurple,
        'iconBackgroundColor': const Color(0xFFF4EFFB),
      },
      {
        'title': 'PCOS Care: Foods That Support Balance',
        'category': 'PCOS Care',
        'description': 'Nutritional strategies and meal tips for insulin sensitivity and wellness.',
        'icon': Icons.restaurant_rounded,
        'iconColor': AppColors.deepRose,
        'iconBackgroundColor': const Color(0xFFFFF0F3),
      },
      {
        'title': 'Prioritizing Pleasure & Body Confidence',
        'category': 'Sex & Pleasure',
        'description': 'Insights on intimate wellness, open communication, and self-care practices.',
        'icon': Icons.favorite_rounded,
        'iconColor': AppColors.peachCoral,
        'iconBackgroundColor': const Color(0xFFFFF7ED),
      },
      {
        'title': 'Gentle Movement for Cramp Relief',
        'category': 'Period Care',
        'description': 'Targeted yoga poses and stretch routines to soothe dysmenorrhea naturally.',
        'icon': Icons.self_improvement_rounded,
        'iconColor': const Color(0xFF45B69C),
        'iconBackgroundColor': const Color(0xFFF0FDF4),
      },
    ];

    final faqs = [
      'Is it normal to have irregular periods with PCOS?',
      'How can I naturally reduce severe menstrual cramps?',
      'What are early pregnancy symptoms before a missed period?',
      'When should I consult a doctor regarding vaginal discharge?',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.softPurple),
            const SizedBox(width: 8),
            Text('Pink Corner', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Empower Your Body Hero Card (Updated Soft Purple/Lavender Theme)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9D76C1), Color(0xFF7B4397)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Empower Your Body ✨',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Medically backed insights on PCOS, cycle sync, fertility, and intimacy.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('📚', style: TextStyle(fontSize: 40)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Explore Topics (2-Column Grid)
            Text(
              'Explore Topics',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topicItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemBuilder: (context, index) {
                final topic = topicItems[index];
                return TopicCard(
                  title: topic['title'] as String,
                  icon: topic['icon'] as IconData,
                  backgroundColor: topic['backgroundColor'] as Color,
                  borderColor: topic['borderColor'] as Color,
                  iconColor: topic['iconColor'] as Color,
                  onTap: () {
                    if (topic['title'] == 'PCOS/PCOD') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PcosArticleScreen(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaceholderTopicScreen(
                            title: topic['title'] as String,
                            icon: topic['icon'] as IconData,
                            accentColor: topic['iconColor'] as Color,
                            backgroundColor: topic['backgroundColor'] as Color,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 28),

            // 3. Suggested for You Section
            Text(
              'Suggested for You',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            ...suggestedArticles.map(
              (article) => SuggestionCard(
                title: article['title'] as String,
                category: article['category'] as String,
                description: article['description'] as String,
                icon: article['icon'] as IconData,
                iconColor: article['iconColor'] as Color,
                iconBackgroundColor: article['iconBackgroundColor'] as Color,
                onTap: () {
                  if (article['category'] == 'PCOS Care') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PcosArticleScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceholderTopicScreen(
                          title: article['title'] as String,
                          icon: article['icon'] as IconData,
                          accentColor: article['iconColor'] as Color,
                          backgroundColor: article['iconBackgroundColor'] as Color,
                          description: article['description'] as String,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 28),

            // 4. FAQs Answered Section
            Text(
              'FAQs Answered',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 14),
            ...faqs.map(
              (question) => FaqCard(
                question: question,
                onTap: () {
                  if (question.contains('PCOS')) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PcosArticleScreen(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaceholderTopicScreen(
                          title: 'FAQ Detail',
                          icon: Icons.help_outline_rounded,
                          accentColor: AppColors.softPurple,
                          backgroundColor: AppColors.babyPink,
                          description: question,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
