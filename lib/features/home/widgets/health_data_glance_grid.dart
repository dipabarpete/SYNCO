import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../health/health_tracking_screen.dart';
import 'glance_metric_card.dart';

class HealthDataGlanceGrid extends StatelessWidget {
  final Function(String title)? onTileTap;
  final VoidCallback? onViewAllTap;

  const HealthDataGlanceGrid({
    super.key,
    this.onTileTap,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Sleep Score',
        'value': '8/10',
        'statusText': 'Excellent',
        'icon': Icons.nightlight_round,
        'cardBg': const Color(0xFFF3EFFF),
        'iconColor': const Color(0xFF8B5CF6),
        'borderColor': const Color(0xFFE5DAFA),
        'dotColor': const Color(0xFF4CAF50),
      },
      {
        'title': 'Stress Level',
        'value': 'Low',
        'statusText': 'Relaxed',
        'icon': Icons.air_rounded,
        'cardBg': const Color(0xFFEAF9F2),
        'iconColor': const Color(0xFF10B981),
        'borderColor': const Color(0xFFD3F4E5),
        'dotColor': const Color(0xFF4CAF50),
      },
      {
        'title': 'Sugar Cravings',
        'value': 'Low',
        'statusText': 'Great Control',
        'icon': Icons.apple,
        'cardBg': const Color(0xFFFFF4E8),
        'iconColor': const Color(0xFFF97316),
        'borderColor': const Color(0xFFFFE4CA),
        'dotColor': const Color(0xFF4CAF50),
      },
      {
        'title': 'Acne Status',
        'value': 'Mild',
        'statusText': 'Improving',
        'icon': Icons.auto_awesome_outlined,
        'cardBg': const Color(0xFFFFF0F5),
        'iconColor': const Color(0xFFEC4899),
        'borderColor': const Color(0xFFFFD6E4),
        'dotColor': const Color(0xFFF59E0B),
      },
      {
        'title': 'Energy',
        'value': 'High',
        'statusText': 'Great',
        'icon': Icons.bolt_rounded,
        'cardBg': const Color(0xFFFFFBE8),
        'iconColor': const Color(0xFFEAB308),
        'borderColor': const Color(0xFFFFF1B8),
        'dotColor': const Color(0xFF4CAF50),
      },
      {
        'title': 'Inflammation',
        'value': 'Low',
        'statusText': 'Good',
        'icon': Icons.local_fire_department_outlined,
        'cardBg': const Color(0xFFFFF0EC),
        'iconColor': const Color(0xFFF97316),
        'borderColor': const Color(0xFFFFDDD5),
        'dotColor': const Color(0xFF4CAF50),
      },
      {
        'title': 'Water Intake',
        'value': '2.5 L',
        'statusText': 'Goal: 2.5 L ✓',
        'icon': Icons.water_drop_outlined,
        'cardBg': const Color(0xFFEFF7FF),
        'iconColor': const Color(0xFF3B82F6),
        'borderColor': const Color(0xFFD6EBFF),
        'dotColor': const Color(0xFF4CAF50),
      },
      {
        'title': 'Steps',
        'value': '6,450',
        'statusText': 'Goal: 8,000',
        'icon': Icons.directions_walk_rounded,
        'cardBg': const Color(0xFFF5F0FF),
        'iconColor': const Color(0xFFA855F7),
        'borderColor': const Color(0xFFE6D8FF),
        'dotColor': const Color(0xFFF59E0B),
      },
      {
        'title': 'Weight Progress',
        'value': '-1.5 kg',
        'statusText': 'This Month',
        'icon': Icons.trending_down_rounded,
        'cardBg': const Color(0xFFEBF8F2),
        'iconColor': const Color(0xFF10B981),
        'borderColor': const Color(0xFFD0F2E3),
        'dotColor': const Color(0xFF4CAF50),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. SECTION HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                'Health Data Glance',
                style: GoogleFonts.outfit(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onViewAllTap ??
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HealthTrackingScreen(),
                      ),
                    );
                  },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEC5586),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: Color(0xFFEC5586),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 2. 3x3 RESPONSIVE GRID
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.88,
          ),
          itemBuilder: (ctx, i) {
            final item = items[i];
            return GlanceMetricCard(
              title: item['title'] as String,
              value: item['value'] as String,
              statusText: item['statusText'] as String,
              icon: item['icon'] as IconData,
              cardBackgroundColor: item['cardBg'] as Color,
              iconColor: item['iconColor'] as Color,
              borderColor: item['borderColor'] as Color,
              statusDotColor: item['dotColor'] as Color,
              onTap: () {
                if (onTileTap != null) {
                  onTileTap!(item['title'] as String);
                }
              },
            );
          },
        ),
      ],
    );
  }
}
