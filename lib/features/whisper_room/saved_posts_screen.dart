import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/community_post.dart';
import '../../providers/app_providers.dart';

class SavedPostsScreen extends ConsumerStatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  ConsumerState<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends ConsumerState<SavedPostsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // `null` while the first load is in flight.
  List<CommunityPost>? _savedPosts;
  bool _isLoading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPosts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final posts = await ref.read(whisperServiceProvider).getSavedPosts();
      if (!mounted) return;
      setState(() {
        _savedPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to load saved posts: $e');
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load your saved posts. Please check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _unsavePost(String postId) async {
    final saved = await ref.read(whisperRoomProvider.notifier).toggleSave(postId);
    if (!mounted) return;
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not remove the saved post. Please try again.'),
        ),
      );
      return;
    }
    setState(() {
      _savedPosts?.removeWhere((p) => p.id == postId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed from Saved Posts')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final savedPosts = _savedPosts ?? const <CommunityPost>[];

    final filteredPosts = savedPosts.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.content.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Posts',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar for Saved Posts
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search saved posts...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.softPurple),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
              ),
            ),
          ),

          // Saved Posts List
          Expanded(
            child: _isLoading && _savedPosts == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.softPurple),
                  )
                : _loadError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_off_rounded,
                                size: 40,
                                color: AppColors.softPurple,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _loadError!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppColors.textMedium,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadSavedPosts,
                                icon: const Icon(Icons.refresh_rounded, size: 18),
                                label: const Text('Try Again'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.softPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredPosts.isEmpty
                    ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.softLavender.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.bookmark_outline_rounded,
                              size: 40,
                              color: AppColors.softPurple,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'No matching saved posts found.'
                                : 'No saved posts yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the bookmark icon on any post in Whisper Room to save it for quick reference!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredPosts.length,
                    itemBuilder: (ctx, index) {
                      final post = filteredPosts[index];
                      return _buildSavedPostCard(post);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPostCard(CommunityPost post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header & Category
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    post.isAnonymous ? AppColors.babyPink : AppColors.softLavender,
                child: Text(
                  post.authorAvatar,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.authorName,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (post.isAnonymous) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPurple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ANONYMOUS',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.softPurple,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${post.category} • ${post.timeAgo}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              // Saved Bookmark Toggle
              IconButton(
                icon: const Icon(
                  Icons.bookmark_rounded,
                  color: AppColors.softPurple,
                  size: 22,
                ),
                onPressed: () => _unsavePost(post.id),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Post Title & Content
          Text(
            post.title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            post.content,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Action Bar
          Row(
            children: [
              Icon(
                post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18,
                color: post.isLiked ? AppColors.rosePink : AppColors.textLight,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.likesCount}',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.mode_comment_outlined, size: 18, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(
                '${post.commentsCount}',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
