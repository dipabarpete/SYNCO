import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/article_item.dart';

class DynamicArticleScreen extends StatelessWidget {
  final ArticleItem article;

  const DynamicArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          article.category,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            if (article.imageUrl.isNotEmpty)
              Image.network(
                article.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textMedium),
                      const SizedBox(width: 6),
                      Text(
                        article.readTime,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.favorite_rounded, size: 16, color: AppColors.deepRose),
                      const SizedBox(width: 6),
                      Text(
                        '${article.likesCount} likes',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Summary Block
                  if (article.summary.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.softLavender.withValues(alpha: 0.2),
                        border: Border(
                          left: BorderSide(color: AppColors.softPurple, width: 4),
                        ),
                      ),
                      child: Text(
                        article.summary,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textDark,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Full Body Text
                  Text(
                    article.fullBody,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppColors.textDark,
                      height: 1.7,
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
}
