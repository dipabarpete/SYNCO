import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import 'pcos_article_screen.dart';
import 'placeholder_topic_screen.dart';
import 'stress_wellbeing_screen.dart';
import 'widgets/topic_card.dart';
import '../../../providers/app_providers.dart';
import 'providers/learn_provider.dart';
import 'widgets/article_card.dart';
import '../../../models/article_item.dart';
import '../../../models/faq_item.dart';

class PinkCornerScreen extends ConsumerWidget {
  const PinkCornerScreen({super.key});

  Future<void> _handleSeedData(BuildContext context, WidgetRef ref) async {
    final service = ref.read(pinkCornerServiceProvider);
    
    final staticArticles = [
      ArticleItem(
        id: 'art_1',
        title: 'PCOS vs PCOD: Understanding the Key Differences & Daily Habits',
        category: 'PMOS',
        readTime: '4 min read',
        summary: 'Learn how hormonal balance, insulin sensitivity, and cycle tracking can help manage PCOS symptoms effectively.',
        fullBody: 'PCOS (Polycystic Ovary Syndrome) and PCOD (Polycystic Ovarian Disease) are endocrine conditions affecting millions of women worldwide.\n\nWhile PCOD is primarily a metabolic imbalance causing ovaries to produce immature eggs, PCOS involves higher androgen levels leading to irregular cycles, acne, and hirsutism.\n\nKey Daily Habits to Balance Hormones:\n1. Seed Cycling: Pumpkin & flax seeds in follicular phase; sunflower & sesame in luteal phase.\n2. Spearmint Tea: 2 cups daily helps lower free testosterone levels.\n3. Strength Training: Builds muscle sensitivity to insulin.\n4. Prioritize Sleep: 7-8 hours prevents cortisol spikes.',
        imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=600',
        isTrending: true,
      ),
      ArticleItem(
        id: 'art_2',
        title: 'Deciphering Cervical Mucus & Your Fertile Window',
        category: 'Menstrual Health',
        readTime: '3 min read',
        summary: 'Identify egg-white discharge patterns to predict your exact ovulation day naturally.',
        fullBody: 'Cervical mucus changes dynamically throughout your cycle under the influence of estrogen and progesterone.\n\n• Dry/Sticky: Right after your period.\n• Creamy: Early follicular phase.\n• Egg-White Clear & Stretchy: Peak fertile window right before ovulation!',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600',
        isTrending: true,
      ),
      ArticleItem(
        id: 'art_3',
        title: 'The Science of PMS & Luteal Phase Nutrition',
        category: 'Nutrition',
        readTime: '5 min read',
        summary: 'Reduce mood swings and bloating with magnesium, B6, and complex carbohydrates.',
        fullBody: 'During the luteal phase (days 15-28), progesterone rises while serotonin drops. This can cause cravings and mood dips.\n\nNourish your body with dark chocolate (70%+), spinach, bananas, and herbal chamomiles.',
        imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600',
        isTrending: false,
      ),
      ArticleItem(
        id: 'art_4',
        title: 'Box Breathing for Stress & Wellbeing',
        category: 'Stress & Wellbeing',
        readTime: '2 min read',
        summary: 'A simple 4-second inhale and 4-second exhale cycle to relax your nervous system.',
        fullBody: 'Stress directly impacts your hormonal balance and cortisol levels. A highly effective method to calm down is Box Breathing.\n\nHow to do it:\n1. Inhale deeply through your nose for 4 seconds.\n2. Hold your breath for 4 seconds.\n3. Exhale slowly through your mouth for 4 seconds.\n4. Hold for another 4 seconds.\n5. Repeat this cycle 4 times to feel an immediate sense of calm and lower your heart rate.',
        imageUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600',
        isTrending: false,
      ),
    ];

    final staticFaqs = [
      FaqItem(
        id: 'faq_1',
        question: 'Is it normal to have irregular periods with PCOS?',
        answer: 'Yes, irregular periods are one of the most common symptoms of PCOS. This occurs because elevated androgen levels interfere with the normal development and release of eggs (ovulation). Without regular ovulation, the lining of the uterus does not shed as often as it should.',
      ),
      FaqItem(
        id: 'faq_2',
        question: 'How can I naturally reduce severe menstrual cramps?',
        answer: 'Applying heat to your abdomen, drinking chamomile tea, practicing gentle yoga stretches, and eating anti-inflammatory foods can naturally help reduce the severity of menstrual cramps.',
      ),
      FaqItem(
        id: 'faq_3',
        question: 'What are early pregnancy symptoms before a missed period?',
        answer: 'Early symptoms can include tender breasts, mild cramping, spotting (implantation bleeding), fatigue, nausea, and an increased sense of smell. However, these symptoms can also be similar to PMS.',
      ),
      FaqItem(
        id: 'faq_4',
        question: 'When should I consult a doctor regarding vaginal discharge?',
        answer: 'You should consult a doctor if your discharge changes drastically in color (like green or yellow), consistency (like cottage cheese), or if it is accompanied by a strong foul odor, itching, or burning.',
      ),
    ];

    try {
      await service.seedDataBatch(articles: staticArticles, faqs: staticFaqs);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Learn Corner data seeded successfully!'),
            backgroundColor: AppColors.softPurple,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to seed: ${e.toString().split(']').last.trim()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildShimmerSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildFaqShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: List.generate(4, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )),
      ),
    );
  }

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

    final articlesAsync = ref.watch(latestArticlesProvider);
    final faqsAsync = ref.watch(faqsProvider);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/whisper_room_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
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
                  onPressed: () => _handleSeedData(context, ref),
                  child: const Text('Seed Data', style: TextStyle(color: AppColors.softPurple)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            articlesAsync.when(
              data: (articles) {
                if (articles.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No articles found. Tap "Seed Data" to generate some!'),
                  );
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
              loading: () => _buildShimmerSkeleton(),
              error: (err, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to load articles. Please check your connection or permissions.',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
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
            faqsAsync.when(
              data: (faqs) {
                if (faqs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No FAQs found. Tap "Seed Data" to generate some!'),
                  );
                }
                return Column(
                  children: faqs.map((faq) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent, // Removes the divider line
                      ),
                      child: ExpansionTile(
                        title: Text(
                          faq.question,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontSize: 15,
                          ),
                        ),
                        backgroundColor: AppColors.babyPink,
                        collapsedBackgroundColor: Colors.white,
                        iconColor: AppColors.softPurple,
                        collapsedIconColor: AppColors.textLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        collapsedShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              faq.answer,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )).toList(),
                );
              },
              loading: () => _buildFaqShimmer(),
              error: (err, stack) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade400),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed to load FAQs. Please check your connection or permissions.',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  ],
);
  }
}
