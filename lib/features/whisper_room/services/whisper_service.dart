import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../core/backend.dart';
import '../../../models/community_post.dart';

class WhisperService {
  FirebaseFirestore? get _firestore => Backend.firestore;
  FirebaseAuth? get _auth => Backend.auth;

  /// Fetches a paginated list of posts, excluding those from blocked users
  Future<List<CommunityPost>> getPosts({
    int limit = 10,
    DocumentSnapshot? startAfter,
    List<String> blockedUserNames = const [],
  }) async {
    final firestore = _firestore;
    if (firestore == null) return [];

    try {
      Query query = firestore
          .collection('whisper_posts')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      
      final currentUserId = _auth?.currentUser?.uid ?? '';
      
      final posts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CommunityPost.fromMap(doc.id, data, currentUserId);
      }).toList();

      // Filter out blocked users locally because Firestore doesn't support complex NOT IN arrays easily across collections
      return posts.where((p) => !blockedUserNames.contains(p.authorName)).toList();
    } catch (e) {
      debugPrint('Error fetching whisper posts: $e');
      return [];
    }
  }

  /// Create a new post
  Future<CommunityPost?> createPost(CommunityPost post) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return null;
    try {
      final docRef = firestore.collection('whisper_posts').doc();
      final postWithId = post.copyWith(id: docRef.id, authorId: user.uid);
      await docRef.set(postWithId.toMap());
      return postWithId;
    } catch (e) {
      debugPrint('Error creating whisper post: $e');
      rethrow;
    }
  }

  /// Toggle Like
  Future<void> toggleLike(String postId, bool isCurrentlyLiked) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;
    try {
      await firestore.collection('whisper_posts').doc(postId).update({
        'likedBy': isCurrentlyLiked
            ? FieldValue.arrayRemove([user.uid])
            : FieldValue.arrayUnion([user.uid]),
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }
  
  /// Add Comment
  Future<void> addComment(String postId, CommentItem comment) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('whisper_posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([comment.toMap()]),
        'commentsCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  /// Report a post
  Future<void> reportPost(String postId) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;
    try {
      await firestore.collection('reported_posts').add({
        'postId': postId,
        'reportedBy': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error reporting post: $e');
      rethrow;
    }
  }

  /// Block a user
  Future<void> blockUser(String authorName) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;
    try {
      // Storing blocked users by authorName to easily filter local feed
      final docRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('blocked_users')
          .doc(authorName);
          
      await docRef.set({
        'authorName': authorName,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error blocking user: $e');
      rethrow;
    }
  }

  /// Get blocked users for current user
  Future<List<String>> getBlockedUsers() async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return [];
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(user.uid)
          .collection('blocked_users')
          .get();
      return snapshot.docs.map((doc) => doc.data()['authorName'] as String).toList();
    } catch (e) {
      debugPrint('Error getting blocked users: $e');
      return [];
    }
  }

  /// Toggle Save
  Future<void> toggleSave(String postId, bool isCurrentlySaved) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;
    try {
      await firestore.collection('whisper_posts').doc(postId).update({
        'savedBy': isCurrentlySaved
            ? FieldValue.arrayRemove([user.uid])
            : FieldValue.arrayUnion([user.uid]),
      });
    } catch (e) {
      debugPrint('Error toggling save: $e');
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('whisper_posts').doc(postId).delete();
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  /// Edit a post
  Future<void> editPost(String postId, String newTitle, String newContent) async {
    final firestore = _firestore;
    if (firestore == null) return;
    try {
      await firestore.collection('whisper_posts').doc(postId).update({
        'title': newTitle,
        'content': newContent,
      });
    } catch (e) {
      debugPrint('Error editing post: $e');
      rethrow;
    }
  }

  /// Vote on a poll
  Future<void> votePoll(String postId, String optionId) async {
    final firestore = _firestore;
    final user = _auth?.currentUser;
    if (firestore == null || user == null) return;
    try {
      final docRef = firestore.collection('whisper_posts').doc(postId);
      
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data();
        if (data == null || data['pollOptions'] == null) return;

        final List<dynamic> rawPollOptions = data['pollOptions'];
        
        // Prevent multiple votes by the same user in the backend
        bool alreadyVoted = false;
        for (final opt in rawPollOptions) {
          final String optId = opt['id'];
          final List<dynamic>? voters = data['votedBy_$optId'];
          if (voters != null && voters.contains(user.uid)) {
            alreadyVoted = true;
            break;
          }
        }
        if (alreadyVoted) return;

        final updatedPollOptions = rawPollOptions.map((opt) {
          final optMap = Map<String, dynamic>.from(opt);
          if (optMap['id'] == optionId) {
            optMap['votes'] = (optMap['votes'] ?? 0) + 1;
          }
          return optMap;
        }).toList();

        transaction.update(docRef, {
          'pollOptions': updatedPollOptions,
          'votedBy_$optionId': FieldValue.arrayUnion([user.uid]), // Tracking who voted for what
        });
      });
    } catch (e) {
      debugPrint('Error voting poll: $e');
      rethrow;
    }
  }
}
