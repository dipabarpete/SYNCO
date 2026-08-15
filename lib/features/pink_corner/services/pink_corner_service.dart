import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/article_item.dart';
import '../../../models/faq_item.dart';

class PinkCornerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream all articles, ordered by newest
  Stream<List<ArticleItem>> streamArticles({int? limit}) {
    Query<Map<String, dynamic>> query = _db.collection('learn_content');
    if (limit != null) {
      query = query.limit(limit);
    }
    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ArticleItem.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }

  // Stream trending articles
  Stream<List<ArticleItem>> streamTrendingArticles() {
    return _db
        .collection('learn_content')
        .where('isTrending', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ArticleItem.fromFirestore(doc)).toList());
  }

  // Stream articles by category
  Stream<List<ArticleItem>> streamArticlesByCategory(String category) {
    return _db
        .collection('learn_content')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ArticleItem.fromFirestore(doc)).toList());
  }

  // Fallback seeder method to mock data if Firestore is empty
  Future<void> seedMockArticles(List<ArticleItem> fallbackArticles) async {
    for (var article in fallbackArticles) {
      await _db.collection('learn_content').doc(article.id).set(article.toMap());
    }
  }

  // Stream FAQs
  Stream<List<FaqItem>> streamFaqs({int? limit}) {
    Query<Map<String, dynamic>> query = _db.collection('faqs');
    if (limit != null) query = query.limit(limit);
    
    return query
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => FaqItem.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)).toList());
  }

  // Fallback seeder method for FAQs
  Future<void> seedMockFaqs(List<FaqItem> fallbackFaqs) async {
    final query = await _db.collection('faqs').limit(1).get();
    if (query.docs.isNotEmpty) return; // already seeded

    for (var faq in fallbackFaqs) {
      await _db.collection('faqs').doc(faq.id).set(faq.toMap());
    }
  }

  // Atomic batch seed for articles and FAQs
  Future<void> seedDataBatch({required List<ArticleItem> articles, required List<FaqItem> faqs}) async {
    final batch = _db.batch();

    for (var article in articles) {
      final docRef = _db.collection('learn_content').doc(article.id);
      batch.set(docRef, article.toMap());
    }

    for (var faq in faqs) {
      final docRef = _db.collection('faqs').doc(faq.id);
      batch.set(docRef, faq.toMap());
    }

    await batch.commit();
  }
}
