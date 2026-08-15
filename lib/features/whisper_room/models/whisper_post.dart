import 'package:cloud_firestore/cloud_firestore.dart';

class WhisperPost {
  final String id;
  final String authorId;
  final String authorName;
  final String content;
  final String category;
  final bool isAnonymous;
  final DateTime timestamp;

  const WhisperPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.category,
    required this.isAnonymous,
    required this.timestamp,
  });

  factory WhisperPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WhisperPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      authorName: data['authorName'] ?? 'Unknown User',
      content: data['content'] ?? '',
      category: data['category'] ?? 'General',
      isAnonymous: data['isAnonymous'] ?? false,
      timestamp: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'content': content,
      'category': category,
      'isAnonymous': isAnonymous,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
