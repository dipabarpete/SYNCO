import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../models/app_notification.dart';

final userNotificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.id)
      .collection('notifications')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => AppNotification.fromMap(doc.id, doc.data())).toList();
  });
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(userNotificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => n.isUnread).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
