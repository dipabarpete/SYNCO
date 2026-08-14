import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/article_item.dart';

class PinkCornerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream all articles, ordered by newest
  Stream<List<ArticleItem>> streamArticles() {
    return _db
        .collection('articles')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ArticleItem.fromFirestore(doc)).toList());
  }

  // Stream trending articles
  Stream<List<ArticleItem>> streamTrendingArticles() {
    return _db
        .collection('articles')
        .where('isTrending', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ArticleItem.fromFirestore(doc)).toList());
  }

  // Fallback seeder method to mock data if Firestore is empty
  Future<void> seedMockArticles(List<ArticleItem> fallbackArticles) async {
    final query = await _db.collection('articles').limit(1).get();
    if (query.docs.isNotEmpty) return; // already seeded

    for (var article in fallbackArticles) {
      await _db.collection('articles').doc(article.id).set(article.toMap());
    }
  }
}
