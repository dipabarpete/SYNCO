import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/metric_tile.dart';

class HealthDataGlanceGrid extends StatelessWidget {
  final VoidCallback? onTileTap;

  const HealthDataGlanceGrid({
    super.key,
    this.onTileTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> glanceItems = [
      {
        'title': 'Weight Progress',
        'value': '54.5 kg',
        'subtitle': 'Target: 55 kg',
        'icon': Icons.monitor_weight_outlined,
        'color': AppColors.weightColor,
        'progress': 0.98,
      },
      {
        'title': 'Sleep Score',
        'value': '7.8h',
        'subtitle': 'Score: 88% (Restful)',
        'icon': Icons.bedtime_outlined,
        'color': AppColors.sleepColor,
        'progress': 0.88,
      },
      {
        'title': 'Water Intake',
        'value': '2.1L',
        'subtitle': 'Target: 2.5L Today',
        'icon': Icons.water_drop_outlined,
        'color': AppColors.waterColor,
        'progress': 0.84,
      },
      {
        'title': 'Acne',
        'value': 'Mild',
        'subtitle': 'Low Hormonal Flareup',
        'icon': Icons.face_retouching_natural_outlined,
        'color': AppColors.acneColor,
        'progress': 0.85,
      },
      {
        'title': 'Stress',
        'value': '25%',
        'subtitle': 'Low Stress (Balanced)',
        'icon': Icons.spa_outlined,
        'color': AppColors.stressColor,
        'progress': 0.25,
      },
      {
        'title': 'Sugar Cravings',
        'value': 'Low',
        'subtitle': 'Under Control',
        'icon': Icons.cookie_outlined,
        'color': AppColors.sugarColor,
        'progress': 0.30,
      },
      {
        'title': 'Steps',
        'value': '6,420',
        'subtitle': 'Goal: 8,000 steps',
        'icon': Icons.directions_walk_outlined,
        'color': AppColors.stepsColor,
        'progress': 0.80,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: glanceItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (ctx, i) {
        final item = glanceItems[i];
        return MetricTile(
          title: item['title'] as String,
          value: item['value'] as String,
          subtitle: item['subtitle'] as String,
          icon: item['icon'] as IconData,
          themeColor: item['color'] as Color,
          progressPercent: item['progress'] as double,
          onTap: onTileTap ?? () {},
        );
      },
    );
  }
}
