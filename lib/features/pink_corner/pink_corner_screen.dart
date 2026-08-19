import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import 'pcos_article_screen.dart';
import 'placeholder_topic_screen.dart';
import 'reproductive_health_screen.dart';
import 'stress_wellbeing_screen.dart';
import 'menstrual_health_screen.dart';
import 'nutrition_screen.dart';
import 'exercise_screen.dart';
import 'widgets/topic_card.dart';
import 'providers/learn_provider.dart';
import 'widgets/learn_hero_card.dart';
import 'widgets/your_movement_card.dart';

class PinkCornerScreen extends ConsumerWidget {
  const PinkCornerScreen({super.key});

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
        'title': 'Exercise & Movements',
        'icon': Icons.fitness_center_rounded,
        'backgroundColor': const Color(0xFFF0F4FF), // Soft Blue
        'borderColor': const Color(0xFFC7CEEA).withValues(alpha: 0.6),
        'iconColor': const Color(0xFF5B7FFF),
      },
    ];

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
            const LearnHeroCard(),
            const SizedBox(height: 20),

            // Your Movement — shared card displaying live movement progress & streak
            const YourMovementCard(),
            const SizedBox(height: 24),

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
                    } else if (topic['title'] == 'Menstrual Health') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MenstrualHealthScreen(),
                        ),
                      );
                    } else if (topic['title'] == 'Reproductive Health') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReproductiveHealthScreen(),
                        ),
                      );
                    } else if (topic['title'] == 'Nutrition') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NutritionScreen(),
                        ),
                      );
                    } else if (topic['title'] == 'Exercise & Movements' ||
                        topic['title'] == 'Exercise & Movement') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExerciseScreen(),
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
                            description: topic['title'] == 'Exercise & Movements'
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
                    child: Text('No FAQs found yet.'),
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
