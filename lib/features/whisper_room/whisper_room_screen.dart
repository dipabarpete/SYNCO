import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../models/community_post.dart';
import '../../providers/app_providers.dart';

class WhisperRoomScreen extends ConsumerStatefulWidget {
  const WhisperRoomScreen({super.key});

  @override
  ConsumerState<WhisperRoomScreen> createState() => _WhisperRoomScreenState();
}

class _WhisperRoomScreenState extends ConsumerState<WhisperRoomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(whisperRoomProvider);

    final filteredPosts = posts.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.content.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Whisper Room',
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.softPurple, size: 28),
            onPressed: () => _showCreatePostModal(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search topics, PCOS, period tips...',
                    hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.textLight),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.softPurple),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: AppColors.borderGrey.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              ),

              // Categories Tab Bar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.softPurple,
                unselectedLabelColor: AppColors.textMedium,
                indicatorColor: AppColors.softPurple,
                labelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Popular'),
                  Tab(text: 'Following'),
                  Tab(text: 'Categories'),
                  Tab(text: 'For You'),
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
          _buildCategoriesView(),
          _buildPostFeed(filteredPosts),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePostModal(context),
        backgroundColor: AppColors.softPurple,
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        label: const Text('Post Anonymously', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPostFeed(List<CommunityPost> postsList) {
    if (postsList.isEmpty) {
      return Center(
        child: Text(
          'No posts found. Be the first to share!',
          style: GoogleFonts.inter(color: AppColors.textMedium),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 80),
      itemCount: postsList.length,
      itemBuilder: (ctx, i) {
        final post = postsList[i];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(CommunityPost post) {
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
          // Author Header & Anonymous Badge
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: post.isAnonymous ? AppColors.babyPink : AppColors.softLavender,
                child: Text(post.authorAvatar, style: const TextStyle(fontSize: 16)),
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
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark),
                        ),
                        if (post.isAnonymous) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.softPurple.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ANONYMOUS',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.softPurple),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${post.category} • ${post.timeAgo}',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textMedium),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textLight),
                onPressed: () => _showPostOptionsDialog(context, post),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Post Title & Content
          Text(
            post.title,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            post.content,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textMedium, height: 1.4),
          ),
          const SizedBox(height: 12),

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
                      post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: post.isLiked ? AppColors.rosePink : AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () => ref.read(whisperRoomProvider.notifier).toggleLike(post.id),
                  ),
                  Text('${post.likesCount}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.mode_comment_outlined, color: AppColors.textLight, size: 20),
                    onPressed: () => _showCommentsDrawer(context, post),
                  ),
                  Text('${post.commentsCount}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: post.isSaved ? AppColors.softPurple : AppColors.textLight,
                      size: 20,
                    ),
                    onPressed: () => ref.read(whisperRoomProvider.notifier).toggleSave(post.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppColors.textLight, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post link copied for sharing! 📲')),
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
          onTap: () => ref.read(whisperRoomProvider.notifier).votePoll(post.id, opt.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isVoted ? AppColors.softPurple.withValues(alpha: 0.12) : AppColors.lightGrey,
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
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesView() {
    final categories = [
      {'name': 'PCOS & PCOD Support', 'count': '1.2k posts', 'icon': Icons.spa_rounded},
      {'name': 'Period & Flow Talk', 'count': '3.4k posts', 'icon': Icons.water_drop_rounded},
      {'name': 'Mental Wellness & Mood', 'count': '2.1k posts', 'icon': Icons.psychology_rounded},
      {'name': 'TTC & Fertility Journey', 'count': '980 posts', 'icon': Icons.favorite_rounded},
      {'name': 'Pregnancy & Motherhood', 'count': '1.5k posts', 'icon': Icons.child_care_rounded},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (ctx, i) {
        final cat = categories[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            leading: Icon(cat['icon'] as IconData, color: AppColors.softPurple),
            title: Text(cat['name'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            subtitle: Text(cat['count'] as String, style: GoogleFonts.inter(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {},
          ),
        );
      },
    );
  }

  void _showCreatePostModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool isAnon = true;
    String selectedCategory = 'PCOS/PCOD';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Share in Whisper Room', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Post Anonymously', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      Switch(
                        value: isAnon,
                        onChanged: (val) => setModalState(() => isAnon = val),
                        activeThumbColor: AppColors.softPurple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Ask a question or share advice...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Content Details',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty) {
                        final newPost = CommunityPost(
                          id: 'post_${DateTime.now().millisecondsSinceEpoch}',
                          authorName: isAnon ? 'Anonymous Sister' : 'Sonali',
                          authorAvatar: isAnon ? '🌷' : '👑',
                          isAnonymous: isAnon,
                          category: selectedCategory,
                          title: titleCtrl.text.trim(),
                          content: contentCtrl.text.trim(),
                          timeAgo: 'Just now',
                          likesCount: 0,
                          commentsCount: 0,
                        );

                        ref.read(whisperRoomProvider.notifier).addPost(newPost);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Your post is live in Whisper Room! 💖')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Publish Post', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCommentsDrawer(BuildContext context, CommunityPost post) {
    final commentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
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
                Text('Comments (${post.commentsCount})', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Expanded(
                  child: post.comments.isEmpty
                      ? Center(child: Text('No comments yet. Say something supportive!', style: GoogleFonts.inter()))
                      : ListView.builder(
                          itemCount: post.comments.length,
                          itemBuilder: (ctx, i) {
                            final c = post.comments[i];
                            return ListTile(
                              leading: CircleAvatar(child: Text(c.authorAvatar)),
                              title: Text(c.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(c.text, style: const TextStyle(fontSize: 12)),
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
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.softPurple),
                      onPressed: () {
                        if (commentCtrl.text.isNotEmpty) {
                          ref.read(whisperRoomProvider.notifier).addComment(post.id, commentCtrl.text.trim());
                          Navigator.pop(ctx);
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Thank you. Post reported for moderator review.')),
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
}
