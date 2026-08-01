import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/app_providers.dart';

class HealthTrackingScreen extends ConsumerStatefulWidget {
  const HealthTrackingScreen({super.key});

  @override
  ConsumerState<HealthTrackingScreen> createState() =>
      _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends ConsumerState<HealthTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _reportTabController;

  @override
  void initState() {
    super.initState();
    _reportTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _reportTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final health = ref.watch(healthMetricsProvider);

    final trackers = [
      {
        'title': 'Sleep Tracker',
        'value': '${health.sleepHours}h Today',
        'icon': Icons.bedtime_rounded,
        'color': AppColors.sleepColor,
      },
      {
        'title': 'Weight Tracker',
        'value': '${health.weightKg} kg',
        'icon': Icons.monitor_weight_rounded,
        'color': AppColors.weightColor,
      },
      {
        'title': 'Water Intake',
        'value': '${health.waterIntakeLiters} / ${health.targetWaterLiters} L',
        'icon': Icons.water_drop_rounded,
        'color': AppColors.waterColor,
      },
      {
        'title': 'Exercise Tracker',
        'value': '${health.stepsCount} Steps',
        'icon': Icons.directions_run_rounded,
        'color': AppColors.stepsColor,
      },
      {
        'title': 'Food & Nutrition',
        'value': 'Balanced Follicular',
        'icon': Icons.restaurant_rounded,
        'color': AppColors.mintGreen,
      },
      {
        'title': 'Mental Wellness',
        'value': 'Stress Low (25%)',
        'icon': Icons.spa_rounded,
        'color': AppColors.softPurpleLight,
      },
      {
        'title': 'Skin Tracker',
        'value': health.acneStatus,
        'icon': Icons.face_retouching_natural_rounded,
        'color': AppColors.acneColor,
      },
      {
        'title': 'Supplement Tracker',
        'value': health.supplementsTaken ? 'All Taken ✨' : 'Pending',
        'icon': Icons.medication_rounded,
        'color': AppColors.rosePink,
      },
      {
        'title': 'Lab Reports AI',
        'value': 'Thyroid & Iron Normal',
        'icon': Icons.document_scanner_rounded,
        'color': AppColors.softPurple,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.rosePink),
            const SizedBox(width: 8),
            Text(
              'Health & Analytics',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Pattern Detection Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.softPurple, AppColors.softPurpleLight],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Pattern Detection System',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pattern Detected: Higher sleep duration (7.8h+) directly correlates with lower stress levels (25%) and reduced sugar cravings during your follicular phase.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Weekly & Monthly Reports Tabs with Charts
            Text(
              'Weekly & Monthly Reports',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderGrey.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  TabBar(
                    controller: _reportTabController,
                    labelColor: AppColors.softPurple,
                    unselectedLabelColor: AppColors.textMedium,
                    indicatorColor: AppColors.softPurple,
                    tabs: const [
                      Tab(text: 'Weekly Trend'),
                      Tab(text: 'Monthly Overview'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      controller: _reportTabController,
                      children: [
                        _buildSimpleBarChart(),
                        _buildSimpleLineChart(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Health Trackers Suite Grid
            Text(
              'Health Trackers Suite',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trackers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (ctx, i) {
                final t = trackers[i];
                return GestureDetector(
                  onTap: () => _openTrackerActionSheet(
                    context,
                    ref,
                    t['title'] as String,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: (t['color'] as Color).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          t['icon'] as IconData,
                          color: t['color'] as Color,
                          size: 22,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t['title'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t['value'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                return Text(
                  days[val.toInt() % 7],
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: 75, color: AppColors.softPurple)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 82, color: AppColors.softPurple)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 88, color: AppColors.softPurple)],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 79, color: AppColors.softPurple)],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [BarChartRodData(toY: 85, color: AppColors.softPurple)],
          ),
          BarChartGroupData(
            x: 5,
            barRods: [BarChartRodData(toY: 90, color: AppColors.softPurple)],
          ),
          BarChartGroupData(
            x: 6,
            barRods: [BarChartRodData(toY: 82, color: AppColors.rosePink)],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 70),
              FlSpot(1, 75),
              FlSpot(2, 80),
              FlSpot(3, 78),
              FlSpot(4, 85),
              FlSpot(5, 88),
              FlSpot(6, 92),
            ],
            isCurved: true,
            color: AppColors.softPurple,
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.softLavender.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  void _openTrackerActionSheet(
    BuildContext context,
    WidgetRef ref,
    String title,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage $title',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (title.contains('Water')) ...[
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(healthMetricsProvider.notifier)
                      .updateWaterIntake(0.25);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('+250 ml Water Logged! 💧')),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Log +250 ml Water'),
              ),
            ] else ...[
              Text(
                'Log your daily metric or scan reports to update your AI Health Score.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                ),
                child: const Text(
                  'Update Metric Log',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
