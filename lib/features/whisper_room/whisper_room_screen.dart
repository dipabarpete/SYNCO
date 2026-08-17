import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/community_post.dart';
import '../../providers/app_providers.dart';
import 'create_post_screen.dart';
import 'notifications_screen.dart';
import 'saved_posts_screen.dart';

class WhisperRoomScreen extends ConsumerStatefulWidget {
  const WhisperRoomScreen({super.key});

  @override
  ConsumerState<WhisperRoomScreen> createState() => _WhisperRoomScreenState();
}

bool _isLocalImagePath(String path) {
  return path.startsWith('/') || path.contains(':\\') || path.startsWith('file://');
}

class _WhisperRoomScreenState extends ConsumerState<WhisperRoomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
      ),
    );
  }

  void _navigateToSavedPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedPostsScreen(),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final whisperState = ref.watch(whisperRoomProvider);
    final posts = whisperState;
    final userProfile = ref.watch(effectiveUserProfileProvider);

    final filteredPosts = posts.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.content.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

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
            centerTitle: false,
            titleSpacing: 16,
            title: Text(
              'Whisper Room',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            actions: [
              // Standalone Outlined Material Notification Icon
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: _navigateToNotifications,
                tooltip: 'Notifications',
              ),

              // Saved Posts Icon (unchanged)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.bookmark_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _navigateToSavedPosts,
                  tooltip: 'Saved Posts',
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search topics, PCOS, period tips...',
                        hintStyle:
                            GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.softPurple),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: AppColors.borderGrey.withValues(alpha: 0.4)),
                        ),
                      ),
                    ),
                  ),

                  // Filter Chips / Tabs in exact requested order:
                  // For You → Popular → Following → My Posts → Categories
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.textDark,
                    unselectedLabelColor: Colors.white,
                    indicatorColor: AppColors.textDark,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelStyle: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(text: 'For You'),
                      Tab(text: 'Popular'),
                      Tab(text: 'Following'),
                      Tab(text: 'My Posts'),
                      Tab(text: 'Categories'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildPostFeed(filteredPosts),
              _buildPostFeed(filteredPosts.reversed.toList()),
              _buildPostFeed(filteredPosts.where((p) => !p.isAnonymous).toList()),
              _buildPostFeed(
                filteredPosts
                    .where((p) => p.isMine || p.authorName == userProfile.username)
                    .toList(),
                emptyMessage: 'You haven\'t posted anything yet. Share your thoughts!',
              ),
              _buildCategoriesView(filteredPosts),
            ],
          ),
          // FAB Label: "New Post"
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navigateToCreatePost,
            backgroundColor: AppColors.softPurple,
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
            label: const Text(
              'New Post',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostFeed(List<CommunityPost> postsList, {String? emptyMessage}) {
    if (postsList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bubble_chart_outlined,
                  size: 48, color: AppColors.softPurpleLight),
              const SizedBox(height: 12),
              Text(
                emptyMessage ?? 'No posts found. Be the first to share!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: AppColors.textMedium, fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Load more posts from the database when the user reaches the end of
        // the feed so older posts (My Posts / Saved) stay visible.
        if (notification.metrics.extentAfter < 300) {
          ref.read(whisperRoomProvider.notifier).loadMorePosts();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
        itemCount: postsList.length,
        itemBuilder: (ctx, i) {
          final post = postsList[i];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final userProfile = ref.watch(effectiveUserProfileProvider);
    final isMyPost = post.isMine || post.authorName == userProfile.username;

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
          // Author Header & Identity
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: post.isAnonymous
                    ? AppColors.babyPink
                    : AppColors.softLavender,
                child: Text(
                  post.isAnonymous ? '🌸' : post.authorAvatar,
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
                          post.isAnonymous ? 'Anonymous Girl' : post.authorName,
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
                                horizontal: 6, vertical: 2),
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
                        if (isMyPost && !post.isAnonymous) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.rosePink.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'YOU',
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
                          fontSize: 11, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded,
                    size: 18, color: AppColors.textLight),
                onPressed: () => _showPostOptionsDialog(context, post),
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
                color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            post.content,
            style: GoogleFonts.inter(
                fontSize: 13, color: AppColors.textMedium, height: 1.4),
          ),
          const SizedBox(height: 12),

          // Attached Images (if present)
          if (post.attachedImages != null && post.attachedImages!.isNotEmpty) ...[
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.attachedImages!.length,
                itemBuilder: (ctx, idx) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 140,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: _isLocalImagePath(post.attachedImages![idx])
                            ? FileImage(File(post.attachedImages![idx]))
                                as ImageProvider
                            : NetworkImage(post.attachedImages![idx]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Optional Interactive Poll
          if (post.pollOptions != null) ...[
            _buildPollSection(post),
            const SizedBox(height: 12),
          ],

          // Footer Action Bar (Like, Comment, Save, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isLiked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: post.isLiked
                          ? AppColors.rosePink
                          : AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () => ref
                        .read(whisperRoomProvider.notifier)
                        .toggleLike(post.id),
                  ),
                  Text('${post.likesCount}',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.mode_comment_outlined,
                        color: AppColors.textLight, size: 20),
                    onPressed: () => _showCommentsDrawer(context, post),
                  ),
                  Text('${post.commentsCount}',
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: post.isSaved
                          ? AppColors.softPurple
                          : AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () async {
                      final saved = await ref
                          .read(whisperRoomProvider.notifier)
                          .toggleSave(post.id);
                      if (!mounted) return;
                      if (!saved) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Could not update saved posts. Please try again.'),
                          ),
                        );
                        return;
                      }
                      final isSavedNow = !post.isSaved;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isSavedNow
                                ? 'Post saved to your bookmarks! 🔖'
                                : 'Post removed from saved.',
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined,
                        color: AppColors.textLight, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Post link copied for sharing! 📲')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollSection(CommunityPost post) {
    int totalVotes = 0;
    for (final opt in post.pollOptions!) {
      totalVotes += opt.votes;
    }

    return Column(
      children: post.pollOptions!.map((opt) {
        final bool isVoted = post.userVotedPollOptionId == opt.id;
        final double ratio = totalVotes > 0 ? opt.votes / totalVotes : 0.0;

        return GestureDetector(
          onTap: () =>
              ref.read(whisperRoomProvider.notifier).votePoll(post.id, opt.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isVoted
                  ? AppColors.softPurple.withValues(alpha: 0.12)
                  : AppColors.lightGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isVoted ? AppColors.softPurple : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    opt.text,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isVoted ? FontWeight.bold : FontWeight.w500,
                      color: isVoted ? AppColors.softPurple : AppColors.textDark,
                    ),
                  ),
                ),
                Text(
                  '${(ratio * 100).round()}% (${opt.votes})',
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMedium),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesView(List<CommunityPost> allPosts) {
    // Exact requested categories in exact specified order with Material icons:
    final categories = [
      {
        'name': 'PCOS/PCOD Support',
        'count': '1.2k posts',
        'icon': Icons.spa_rounded,
      },
      {
        'name': 'Periods & Flow Talk',
        'count': '3.4k posts',
        'icon': Icons.water_drop_rounded,
      },
      {
        'name': 'Mental Wellness & Mood',
        'count': '2.1k posts',
        'icon': Icons.psychology_rounded,
      },
      {
        'name': 'Exercise & Nutrition',
        'count': '1.8k posts',
        'icon': Icons.fitness_center_rounded,
      },
      {
        'name': 'Reproductive Health',
        'count': '2.4k posts',
        'icon': Icons.health_and_safety_rounded,
      },
      {
        'name': 'General',
        'count': '4.2k posts',
        'icon': Icons.forum_rounded,
      },
    ];

    if (_selectedCategoryFilter != null) {
      final categoryPosts = allPosts.where((p) {
        final pCat = p.category.toLowerCase();
        final selCat = _selectedCategoryFilter!.toLowerCase();
        return pCat.contains(selCat) || selCat.contains(pCat);
      }).toList();

      final selectedCatData = categories.firstWhere(
        (c) => c['name'] == _selectedCategoryFilter,
        orElse: () => {
          'name': _selectedCategoryFilter!,
          'icon': Icons.category_rounded,
        },
      );

      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.softPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.softPurple.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      selectedCatData['icon'] as IconData,
                      color: AppColors.softPurple,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCategoryFilter!,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategoryFilter = null;
                    });
                  },
                  icon: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.softPurple),
                  label: Text(
                    'All Categories',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.softPurple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildPostFeed(
              categoryPosts,
              emptyMessage:
                  'No posts under $_selectedCategoryFilter yet. Be the first to start a conversation!',
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (ctx, i) {
        final cat = categories[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shadowColor: AppColors.shadowColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.softPurple.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                cat['icon'] as IconData,
                color: AppColors.softPurple,
                size: 20,
              ),
            ),
            title: Text(
              cat['name'] as String,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Text(
              cat['count'] as String,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textLight,
            ),
            onTap: () {
              setState(() {
                _selectedCategoryFilter = cat['name'] as String;
              });
            },
          ),
        );
      },
    );
  }

  void _showCommentsDrawer(BuildContext context, CommunityPost post) {
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SizedBox(
            height: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Comments (${post.commentsCount})',
                    style: GoogleFonts.outfit(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: post.comments.isEmpty
                      ? Center(
                          child: Text(
                              'No comments yet. Say something supportive!',
                              style: GoogleFonts.inter()))
                      : ListView.builder(
                          itemCount: post.comments.length,
                          itemBuilder: (ctx, i) {
                            final c = post.comments[i];
                            return ListTile(
                              leading: CircleAvatar(child: Text(c.authorAvatar)),
                              title: Text(c.authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle:
                                  Text(c.text, style: const TextStyle(fontSize: 12)),
                            );
                          },
                        ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: AppColors.softPurple),
                      onPressed: () async {
                        if (commentCtrl.text.isNotEmpty) {
                          final text = commentCtrl.text.trim();
                          try {
                            await ref
                                .read(whisperRoomProvider.notifier)
                                .addComment(post.id, text);
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Could not post your comment. Please try again.'),
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPostOptionsDialog(BuildContext context, CommunityPost post) {
    final userProfile = ref.watch(effectiveUserProfileProvider);
    final isMyPost = post.isMine || post.authorName == userProfile.username;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMyPost) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.softPurple),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditPostDialog(context, post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: const Text('Delete Post', style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final deleted = await ref
                      .read(whisperRoomProvider.notifier)
                      .deletePost(post.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(deleted
                            ? 'Post deleted successfully.'
                            : 'Could not delete the post. Please try again.'),
                      ),
                    );
                  }
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Thank you. Post reported for moderator review.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('Hide Content like this'),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, CommunityPost post) {
    final titleCtrl = TextEditingController(text: post.title);
    final contentCtrl = TextEditingController(text: post.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Post', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                ref.read(whisperRoomProvider.notifier).editPost(
                      post.id,
                      titleCtrl.text.trim(),
                      contentCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post updated! ✨')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.softPurple,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
