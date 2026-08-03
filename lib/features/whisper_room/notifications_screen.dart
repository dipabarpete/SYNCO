import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Sarah M. liked your post',
        'subtitle': '"My top 5 seed cycling tips for hormonal balance ✨"',
        'time': '10m ago',
        'icon': Icons.favorite_rounded,
        'iconColor': AppColors.rosePink,
        'isUnread': true,
      },
      {
        'title': 'New comment in PCOS/PCOD Support',
        'subtitle': 'Anonymous Butterfly replied to a thread you follow.',
        'time': '1h ago',
        'icon': Icons.chat_bubble_outline_rounded,
        'iconColor': AppColors.softPurple,
        'isUnread': true,
      },
      {
        'title': 'Daily Hydration Goal Met! 💧',
        'subtitle': 'Great job staying hydrated today during your Follicular phase.',
        'time': '3h ago',
        'icon': Icons.water_drop_rounded,
        'iconColor': AppColors.waterColor,
        'isUnread': false,
      },
      {
        'title': 'Kyra AI Health Insight',
        'subtitle': 'Your sleep score reached 88% last night! Keep it up.',
        'time': '1d ago',
        'icon': Icons.auto_awesome_rounded,
        'iconColor': AppColors.lavenderAccent,
        'isUnread': false,
      },
    ];

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read.')),
              );
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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final item = notifications[i];
          final isUnread = item['isUnread'] as bool;

          return Container(
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
                    color: (item['iconColor'] as Color).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['iconColor'] as Color,
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
                              item['title'] as String,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          Text(
                            item['time'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['subtitle'] as String,
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
          );
        },
      ),
    );
  }
}
