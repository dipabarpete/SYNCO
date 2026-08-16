import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_colors.dart';
import '../../core/providers/notification_providers.dart';
import '../auth/providers/auth_provider.dart';
import '../doctor/screens/consultation_chat_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final user = ref.read(authNotifierProvider).user;
              if (user != null) {
                final batch = FirebaseFirestore.instance.batch();
                final unreadDocs = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.id)
                    .collection('notifications')
                    .where('isUnread', isEqualTo: true)
                    .get();
                
                for (var doc in unreadDocs.docs) {
                  batch.update(doc.reference, {'isUnread': false});
                }
                await batch.commit();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read.')),
                  );
                }
              }
            },
            child: Text(
              'Mark all read',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.softPurple,
              ),
            ),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softPurple)),
        error: (e, st) => Center(child: Text('Error loading notifications: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Text(
                'No new notifications',
                style: GoogleFonts.inter(color: AppColors.textMedium),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final item = notifications[i];
              final isUnread = item.isUnread;

              return GestureDetector(
                onTap: () {
                  if (item.payload != null && item.payload!.startsWith('chat:')) {
                    final chatId = item.payload!.split(':')[1];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsultationChatScreen(
                          chatId: chatId,
                          patientName: 'Doctor', // The chat screen will load data anyway
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? AppColors.babyPink.withValues(alpha: 0.5)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isUnread
                          ? AppColors.blushPink.withValues(alpha: 0.4)
                          : AppColors.borderGrey.withValues(alpha: 0.4),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(int.parse(item.iconColorHex, radix: 16)).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconData(item.iconCode, fontFamily: 'MaterialIcons'),
                          color: Color(int.parse(item.iconColorHex, radix: 16)),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                                Text(
                                  timeago.format(item.createdAt, locale: 'en_short'),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMedium,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
