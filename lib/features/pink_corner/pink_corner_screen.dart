import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/article_item.dart';
import '../../providers/app_providers.dart';

class PinkCornerScreen extends ConsumerWidget {
  const PinkCornerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(articlesProvider);
    final trending = articles.where((a) => a.isTrending).toList();

    final categories = [
      {'name': 'PCOS & PCOD', 'icon': Icons.spa_rounded, 'color': AppColors.softPurple},
      {'name': 'Period Flow Guide', 'icon': Icons.water_drop_rounded, 'color': AppColors.rosePink},
      {'name': 'Body Changes', 'icon': Icons.accessibility_new_rounded, 'color': AppColors.peachCoral},
      {'name': 'Pleasure & Wellness', 'icon': Icons.favorite_rounded, 'color': AppColors.blushPink},
      {'name': 'Pregnancy', 'icon': Icons.child_care_rounded, 'color': AppColors.skyBlue},
      {'name': 'Exercise & Movement', 'icon': Icons.fitness_center_rounded, 'color': AppColors.mintGreen},
      {'name': 'Vaginal Discharge', 'icon': Icons.opacity_rounded, 'color': AppColors.softPurpleLight},
      {'name': 'Fertility Awareness', 'icon': Icons.wb_sunny_rounded, 'color': AppColors.peachCoral},
      {'name': 'Women Health FAQs', 'icon': Icons.help_outline_rounded, 'color': AppColors.textMedium},
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
            // Top Header Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Empower Your Body ✨',
                          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Medically backed insights on PCOS, cycle sync, fertility, and intimacy.',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  const Text('📚', style: TextStyle(fontSize: 40)),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Categories Horizontal Cards
            Text('Explore Topics', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (ctx, i) {
                  final cat = categories[i];
                  return Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: (cat['color'] as Color).withValues(alpha: 0.3)),
                      boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 6, offset: Offset(0, 3))],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // Trending Topics Horizontal Scroll Section
            Text('Trending Topics 🔥', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trending.length,
                itemBuilder: (ctx, i) {
                  final art = trending[i];
                  return GestureDetector(
                    onTap: () => _openArticleDetail(context, art),
                    child: Container(
                      width: 240,
                      margin: const EdgeInsets.only(right: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [BoxShadow(color: AppColors.shadowColor, blurRadius: 10, offset: Offset(0, 4))],
                        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                            child: Image.network(art.imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(art.category, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.softPurple)),
                                const SizedBox(height: 4),
                                Text(art.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('${art.readTime} • ${art.likesCount} ❤️', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // Suggested Articles List
            Text('Suggested Articles', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...articles.map((art) => _buildArticleListItem(context, art)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleListItem(BuildContext context, ArticleItem article) {
    return GestureDetector(
      onTap: () => _openArticleDetail(context, article),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(article.imageUrl, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.category, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.softPurple)),
                  const SizedBox(height: 4),
                  Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(article.readTime, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openArticleDetail(BuildContext context, ArticleItem article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.network(article.imageUrl, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Text(article.category, style: GoogleFonts.inter(color: AppColors.softPurple, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(article.title, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(article.readTime, style: GoogleFonts.inter(color: AppColors.textMedium)),
                const Divider(height: 24),
                Text(article.fullBody, style: GoogleFonts.inter(fontSize: 14, height: 1.6, color: AppColors.textDark)),
              ],
            ),
          );
        },
      ),
    );
  }
}
