import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/app_colors.dart';
import '../models/whisper_post.dart';
import '../providers/whisper_providers.dart';
import 'create_whisper_screen.dart';

class WhisperFeedScreen extends ConsumerWidget {
  const WhisperFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(globalWhisperFeedProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'Whisper Room',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: feedAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softPurple),
        ),
        error: (error, stack) => Center(
          child: Text('Error loading feed: $error'),
        ),
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Text(
                'No whispers yet. Be the first to share!',
                style: GoogleFonts.inter(
                  color: AppColors.textMedium,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final post = posts[index];
              return WhisperPostCard(post: post);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateWhisperScreen(),
            ),
          );
        },
        backgroundColor: AppColors.softPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'New Whisper',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class WhisperPostCard extends StatelessWidget {
  final WhisperPost post;

  const WhisperPostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final authorName = post.isAnonymous ? 'Anonymous' : post.authorName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.babyPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  post.category,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.rosePink,
                  ),
                ),
              ),
              Text(
                timeago.format(post.timestamp),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (!post.isAnonymous)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.softPurple.withValues(alpha: 0.2),
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.softPurple,
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: AppColors.textMedium,
                ),
              const SizedBox(width: 8),
              Text(
                authorName,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
