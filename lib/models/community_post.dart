import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
    };
  }

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      votes: map['votes'] ?? 0,
    );
  }
}

class CommentItem {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final bool isAnonymous;
  final String text;
  final DateTime createdAt;
  final int likesCount;

  CommentItem({
    required this.id,
    this.authorId = '',
    required this.authorName,
    required this.authorAvatar,
    this.isAnonymous = false,
    required this.text,
    required this.createdAt,
    this.likesCount = 0,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'isAnonymous': isAnonymous,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likesCount': likesCount,
    };
  }

  factory CommentItem.fromMap(Map<String, dynamic> map) {
    return CommentItem(
      id: map['id'] ?? '',
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likesCount: map['likesCount'] ?? 0,
    );
  }
}

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final bool isAnonymous;
  final bool isMine;
  final String category;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isSaved;
  final List<PollOption>? pollOptions;
  final String? userVotedPollOptionId;
  final List<CommentItem> comments;
  final List<String>? attachedImages;
  final List<String> likedBy;
  final List<String> savedBy;

  CommunityPost({
    required this.id,
    this.authorId = '',
    required this.authorName,
    required this.authorAvatar,
    this.isAnonymous = false,
    this.isMine = false,
    required this.category,
    required this.title,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.pollOptions,
    this.userVotedPollOptionId,
    this.comments = const [],
    this.attachedImages,
    this.likedBy = const [],
    this.savedBy = const [],
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? title,
    String? content,
    DateTime? updatedAt,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isSaved,
    bool? isMine,
    List<PollOption>? pollOptions,
    String? userVotedPollOptionId,
    List<CommentItem>? comments,
    List<String>? attachedImages,
    List<String>? likedBy,
    List<String>? savedBy,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      isAnonymous: isAnonymous,
      isMine: isMine ?? this.isMine,
      category: category,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      pollOptions: pollOptions ?? this.pollOptions,
      userVotedPollOptionId: userVotedPollOptionId ?? this.userVotedPollOptionId,
      comments: comments ?? this.comments,
      attachedImages: attachedImages ?? this.attachedImages,
      likedBy: likedBy ?? this.likedBy,
      savedBy: savedBy ?? this.savedBy,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'isAnonymous': isAnonymous,
      'category': category,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? createdAt),
      'pollOptions': pollOptions?.map((x) => x.toMap()).toList(),
      'comments': comments.map((x) => x.toMap()).toList(),
      'attachedImages': attachedImages,
      'likedBy': likedBy,
      'savedBy': savedBy,
    };
  }

  factory CommunityPost.fromMap(String docId, Map<String, dynamic> map, String currentUserId) {
    final List<dynamic>? rawLikedBy = map['likedBy'];
    final List<String> likedByList = rawLikedBy?.map((e) => e.toString()).toList() ?? [];

    final List<dynamic>? rawSavedBy = map['savedBy'];
    final List<String> savedByList = rawSavedBy?.map((e) => e.toString()).toList() ?? [];

    final authorId = map['authorId'] ?? '';

    return CommunityPost(
      id: docId,
      authorId: authorId,
      authorName: map['authorName'] ?? '',
      authorAvatar: map['authorAvatar'] ?? '',
      isAnonymous: map['isAnonymous'] ?? false,
      isMine: authorId == currentUserId,
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      likesCount: likedByList.length,
      isLiked: likedByList.contains(currentUserId),
      isSaved: savedByList.contains(currentUserId),
      pollOptions: map['pollOptions'] != null
          ? List<PollOption>.from((map['pollOptions'] as List<dynamic>).map((x) => PollOption.fromMap(x)))
          : null,
      comments: map['comments'] != null
          ? List<CommentItem>.from((map['comments'] as List<dynamic>).map((x) => CommentItem.fromMap(x)))
          : [],
      commentsCount: map['comments'] != null ? (map['comments'] as List<dynamic>).length : 0,
      attachedImages: map['attachedImages'] != null
          ? List<String>.from(map['attachedImages'])
          : null,
      likedBy: likedByList,
      savedBy: savedByList,
    );
  }
}
