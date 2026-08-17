import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/article_item.dart';
import '../../../models/faq_item.dart';
import '../../../providers/app_providers.dart';

// Latest Articles Provider (Limit 5)
final latestArticlesProvider = StreamProvider<List<ArticleItem>>((ref) {
  final service = ref.read(pinkCornerServiceProvider);
  return service.streamArticles(limit: 5);
});

// FAQs Provider (Limit 5)
final faqsProvider = StreamProvider<List<FaqItem>>((ref) {
  final service = ref.read(pinkCornerServiceProvider);
  return service.streamFaqs(limit: 5);
});
