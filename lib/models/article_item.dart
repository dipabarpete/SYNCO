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
}
