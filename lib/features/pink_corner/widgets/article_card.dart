import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/article_item.dart';
import '../dynamic_article_screen.dart';

class ArticleCard extends StatelessWidget {
  final ArticleItem article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DynamicArticleScreen(article: article),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.softLavender),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: article.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(article.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.softLavender,
              ),
              child: article.imageUrl.isEmpty
                  ? const Icon(Icons.article_rounded, color: AppColors.softPurple)
                  : null,
            ),
            const SizedBox(width: 12),
            
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepRose,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textMedium),
                      const SizedBox(width: 4),
                      Text(
                        article.readTime,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textMedium,
                        ),
                      ),
                      if (article.isTrending) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Trending',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
