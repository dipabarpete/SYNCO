import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final int iconCode;
  final String iconColorHex;
  final bool isUnread;

  const AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.iconCode,
    required this.iconColorHex,
    this.isUnread = true,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> data) {
    return AppNotification(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      iconCode: data['iconCode'] ?? 0xe000,
      iconColorHex: data['iconColorHex'] ?? 'FF9C27B0',
      isUnread: data['isUnread'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'createdAt': Timestamp.fromDate(createdAt),
      'iconCode': iconCode,
      'iconColorHex': iconColorHex,
      'isUnread': isUnread,
    };
  }

  AppNotification copyWith({
    bool? isUnread,
  }) {
    return AppNotification(
      id: id,
      title: title,
      subtitle: subtitle,
      createdAt: createdAt,
      iconCode: iconCode,
      iconColorHex: iconColorHex,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}
