import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'pcos_article_screen.dart';
import 'placeholder_topic_screen.dart';
import 'stress_wellbeing_screen.dart';
import 'widgets/faq_card.dart';
import 'widgets/topic_card.dart';
import '../../../providers/app_providers.dart';
import 'widgets/article_card.dart'; // We'll create this widget

class PinkCornerScreen extends ConsumerWidget {
  const PinkCornerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 6 Topic Cards configuration for Explore Topics
    final topicItems = [
      {
        'title': 'PMOS',
        'subtitle': 'PCOS / PCOD',
        'route': 'pcos',
        'icon': Icons.spa_rounded,
        'backgroundColor': const Color(0xFFF4EFFB), // Lavender
        'borderColor': const Color(0xFFD8B4F8).withValues(alpha: 0.6),
        'iconColor': AppColors.softPurple,
      },
      {
        'title': 'Menstrual Health',
        'icon': Icons.water_drop_rounded,
        'backgroundColor': const Color(0xFFFFF0F3), // Soft Pink
        'borderColor': const Color(0xFFFFD1DC).withValues(alpha: 0.6),
        'iconColor': AppColors.deepRose,
      },
      {
        'title': 'Reproductive Health',
        'icon': Icons.favorite_rounded,
        'backgroundColor': const Color(0xFFF4EFFB), // Lavender
        'borderColor': const Color(0xFFD8B4F8).withValues(alpha: 0.6),
        'iconColor': AppColors.softPurple,
      },
      {
        'title': 'Nutrition',
        'icon': Icons.restaurant_rounded,
        'backgroundColor': const Color(0xFFFFF7ED), // Peach
        'borderColor': const Color(0xFFFFB085).withValues(alpha: 0.6),
        'iconColor': AppColors.peachCoral,
      },
      {
        'title': 'Stress & Wellbeing',
        'icon': Icons.self_improvement_rounded,
        'backgroundColor': const Color(0xFFF0FDF4), // Mint
        'borderColor': const Color(0xFFB5EAD7).withValues(alpha: 0.6),
        'iconColor': const Color(0xFF45B69C),
      },
      {
        'title': 'Sleep',
        'icon': Icons.bedtime_rounded,
        'backgroundColor': const Color(0xFFF0F4FF), // Soft Blue
        'borderColor': const Color(0xFFC7CEEA).withValues(alpha: 0.6),
        'iconColor': const Color(0xFF5B7FFF),
      },
    ];

    final faqs = [
      'Is it normal to have irregular periods with PCOS?',
      'How can I naturally reduce severe menstrual cramps?',
      'What are early pregnancy symptoms before a missed period?',
      'When should I consult a doctor regarding vaginal discharge?',
    ];

    final articlesAsync = ref.watch(articlesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.softPurple),
            const SizedBox(width: 8),
            Text('Learn', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Explore Topics (2-Column Grid)
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
                  subtitle: topic['subtitle'] as String?,
                  icon: topic['icon'] as IconData,
                  backgroundColor: topic['backgroundColor'] as Color,
                  borderColor: topic['borderColor'] as Color,
                  iconColor: topic['iconColor'] as Color,
                  onTap: () {
                    if (topic['route'] == 'pcos') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PcosArticleScreen(),
                        ),
                      );
                    } else if (topic['title'] == 'Stress & Wellbeing') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const StressWellbeingScreen(),
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
                            description: topic['title'] == 'Exercise & Movement'
                                ? 'Why movement matters, simple daily movement, walking, strength training, stretching, beginner-friendly exercise, and building a consistent routine.'
                                : null,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 28),

            // Latest Articles Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Articles',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Temporarily seed data if empty
                    seedMockArticles(ref);
                  },
                  child: const Text('Seed Data', style: TextStyle(color: AppColors.softPurple)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            articlesAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return const Text('No articles found.');
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: articles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return ArticleCard(article: article);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softPurple)),
              error: (err, stack) => Text('Error: $err'),
            ),

            const SizedBox(height: 28),

            // 3. FAQs Answered Section
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
