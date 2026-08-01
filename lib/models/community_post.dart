class PollOption {
  final String id;
  final String text;
  final int votes;

  PollOption({
    required this.id,
    required this.text,
    required this.votes,
  });

  PollOption copyWith({int? votes}) {
    return PollOption(
      id: id,
      text: text,
      votes: votes ?? this.votes,
    );
  }
}

class CommentItem {
  final String id;
  final String authorName;
  final String authorAvatar;
  final bool isAnonymous;
  final String text;
  final String timeAgo;
  final int likesCount;

  CommentItem({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    this.isAnonymous = false,
    required this.text,
    required this.timeAgo,
    this.likesCount = 0,
  });
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorAvatar;
  final bool isAnonymous;
  final String category; // e.g. PCOS/PCOD, Period Talk, Mental Wellness, TTC, Q&A
  final String title;
  final String content;
  final String timeAgo;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final List<PollOption>? pollOptions;
  final String? userVotedPollOptionId;
  final List<CommentItem> comments;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    this.isAnonymous = false,
    required this.category,
    required this.title,
    required this.content,
    required this.timeAgo,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
    this.isSaved = false,
    this.pollOptions,
    this.userVotedPollOptionId,
    this.comments = const [],
  });

  CommunityPost copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    List<PollOption>? pollOptions,
    String? userVotedPollOptionId,
    List<CommentItem>? comments,
  }) {
    return CommunityPost(
      id: id,
      authorName: authorName,
      authorAvatar: authorAvatar,
      isAnonymous: isAnonymous,
      category: category,
      title: title,
      content: content,
      timeAgo: timeAgo,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      pollOptions: pollOptions ?? this.pollOptions,
      userVotedPollOptionId: userVotedPollOptionId ?? this.userVotedPollOptionId,
      comments: comments ?? this.comments,
    );
  }
}
