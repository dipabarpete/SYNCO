import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleItem {
  final String id;
  final String title;
  final String category;
  final String readTime;
  final String summary;
  final String fullBody;
  final String imageUrl;
  final bool isTrending;
  final int likesCount;

  ArticleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.summary,
    required this.fullBody,
    required this.imageUrl,
    this.isTrending = false,
    this.likesCount = 142,
  });

  factory ArticleItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleItem(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      readTime: data['readTime'] ?? '3 min read',
      summary: data['summary'] ?? '',
      fullBody: data['fullBody'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      isTrending: data['isTrending'] ?? false,
      likesCount: data['likesCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'readTime': readTime,
      'summary': summary,
      'fullBody': fullBody,
      'imageUrl': imageUrl,
      'isTrending': isTrending,
      'likesCount': likesCount,
    };
  }
}
