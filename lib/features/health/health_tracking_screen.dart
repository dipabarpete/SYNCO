import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import 'models/ai_insight.dart';
import 'models/health_entries.dart';
import 'providers/health_data_provider.dart';
import 'screens/ai_insights_screen.dart';
import 'screens/health_history_screen.dart';
import 'services/ai_pattern_service.dart';
import 'services/health_analytics.dart';
import 'widgets/health_dashboard_widgets.dart';
import 'widgets/food_tracker_sheet.dart';
import 'widgets/sleep_tracker_sheet.dart';
import 'widgets/steps_tracker_sheet.dart';
import 'widgets/sugar_tracker_sheet.dart';
import 'widgets/supplement_tracker_sheet.dart';
import 'widgets/water_tracker_sheet.dart';
import 'widgets/weight_tracker_sheet.dart';
import 'widgets/wellness_tracker_sheet.dart';

/// SYNCO Health module dashboard.
///
/// Layout:
///  1. App bar: "Health"
///  2. Today summary
///  3. Kyra AI pattern detection (banner, Weekly/Monthly filter, insight cards)
///  4. Health Trackers (8 loggable trackers in a 2 x 4 card grid)
///  5. Privacy note
class HealthTrackingScreen extends ConsumerStatefulWidget {
  const HealthTrackingScreen({super.key});

  @override
  ConsumerState<HealthTrackingScreen> createState() =>
      _HealthTrackingScreenState();
}

class _HealthTrackingScreenState extends ConsumerState<HealthTrackingScreen> {
  PatternRange _range = PatternRange.week;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(healthDataProvider.notifier).loadAll());
  }

  Future<void> _refresh() async {
    await ref.read(healthDataProvider.notifier).loadAll();
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HealthHistoryScreen()),
    );
  }

  void _openAllInsights() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AiInsightsScreen()),
    );
  }

  void _showInsightDetails(AiInsight insight) {
    showAiInsightDetails(context, insight);
  }

  Future<void> _openTracker(HealthTrackerType type) async {
    final data = ref.read(healthDataProvider);
    final today = DateTime.now();

    switch (type) {
      case HealthTrackerType.sleep:
        final existing = data.sleepOn(today).firstOrNull;
        await SleepSheet.show(context, entry: existing);
      case HealthTrackerType.water:
        await WaterSheet.show(context);
      case HealthTrackerType.steps:
        final existing = data.steps
            .where((e) => HealthDataState.sameDay(e.date, today))
            .firstOrNull;
        await StepsSheet.show(context, entry: existing);
      case HealthTrackerType.sugarCravings:
        await SugarCravingSheet.show(context);
      case HealthTrackerType.supplements:
        await SupplementSheet.show(context);
      case HealthTrackerType.mentalWellness:
        final existing = data.wellness
            .where((e) => HealthDataState.sameDay(e.date, today))
            .firstOrNull;
        await WellnessSheet.show(context, entry: existing);
      case HealthTrackerType.food:
        await FoodSheet.show(context);
      case HealthTrackerType.weight:
        await WeightSheet.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(healthDataProvider);
    final weeklyInsights = ref.watch(aiWeeklyInsightsProvider);
    final monthlyInsights = ref.watch(aiMonthlyInsightsProvider);
    final insights =
        _range == PatternRange.week ? weeklyInsights : monthlyInsights;
    final now = DateTime.now();
    final today = HealthAnalytics.daily(all: data.allEntries, date: now);
    final dataDays =
        HealthAnalytics.dataDaysLastDays(data.allEntries, now, days: 30);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/whisper_room_bg.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Row(
              children: [
                const Icon(Icons.favorite_rounded, color: AppColors.rosePink),
                const SizedBox(width: 8),
                Text(
                  'Health',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: _openHistory,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.softPurple,
                ),
                icon: const Icon(Icons.history_rounded, size: 18),
                label: Text(
                  'History',
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: data.isLoading && data.allEntries.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.softPurple),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  color: AppColors.softPurple,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      // -----------------------------------------------------------------
                      // 2. TODAY SUMMARY
                      // -----------------------------------------------------------------
                      TodaySummaryCard(snapshot: today),
                      const SizedBox(height: 22),
    
                      // -----------------------------------------------------------------
                      // 3. KYRA AI PATTERN DETECTION (banner, filter, insight cards)
                      // -----------------------------------------------------------------
                      AiHeroBanner(patternCount: insights.length),
                      const SizedBox(height: 12),
                      _PatternRangeSelector(
                        range: _range,
                        onChanged: (range) => setState(() => _range = range),
                      ),
                      const SizedBox(height: 12),
    
                      if (data.errorMessage != null) ...[
                        _buildErrorBanner(data.errorMessage!),
                        const SizedBox(height: 12),
                      ],
    
                      if (insights.isEmpty)
                        AiEmptyState(hasAnyData: dataDays > 0)
                      else ...[
                        for (final insight in insights.take(2))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AiInsightCard(
                              insight: insight,
                              onViewDetails: () => _showInsightDetails(insight),
                            ),
                          ),
                        if (insights.length > 2)
                          Center(
                            child: TextButton.icon(
                              onPressed: _openAllInsights,
                              icon: const Icon(
                                Icons.view_list_rounded,
                                size: 17,
                                color: AppColors.softPurple,
                              ),
                              label: Text(
                                'View all insights (${insights.length})',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.softPurple,
                                ),
                              ),
                            ),
                          ),
                      ],
    
                      const SizedBox(height: 20),
    
                      // -----------------------------------------------------------------
                      // 4. HEALTH TRACKERS (2 x 4 card grid)
                      // -----------------------------------------------------------------
                      const HealthSectionHeader(
                        title: 'Health Trackers',
                        subtitle: 'Track the small things that shape your wellbeing.',
                      ),
                      const SizedBox(height: 12),
                      _buildTrackerGrid(today, data),
    
                      const SizedBox(height: 10),
    
                      // -----------------------------------------------------------------
                      // 5. PRIVACY NOTE
                      // -----------------------------------------------------------------
                      _buildPrivacyNote(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pendingAmberSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              size: 18, color: AppColors.pendingAmber),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerGrid(DailySnapshot today, HealthDataState data) {
    final entries = <(HealthTrackerType, String?, String?)>[
      (
        HealthTrackerType.sleep,
        today.sleep == null
            ? null
            : formatDurationMinutes(today.sleep!.durationMinutes),
        today.sleep == null ? 'Not logged' : today.sleep!.quality,
      ),
      (
        HealthTrackerType.water,
        today.water.isEmpty
            ? null
            : '${_cupsLabel(today.totalWaterCups)} cups',
        today.water.isEmpty
            ? 'Not logged'
            : _hydrationLabel(today.water.last.hydrationLevel),
      ),
      (
        HealthTrackerType.steps,
        today.steps == null ? null : '${_thousands(today.steps!.count)} steps',
        today.steps == null ? 'Not logged' : 'Manual entry',
      ),
      (
        HealthTrackerType.sugarCravings,
        today.cravings.isEmpty ? null : today.cravings.last.craving,
        today.cravings.isEmpty
            ? 'Not logged'
            : '${today.cravings.last.level} \u00B7 ${today.cravings.length} today',
      ),
      (
        HealthTrackerType.supplements,
        today.supplements.isEmpty ? null : today.supplements.first.name,
        today.supplements.isEmpty
            ? 'Not logged'
            : today.supplements.length > 1
                ? '+${today.supplements.length - 1} more'
                : '1 today',
      ),
      (
        HealthTrackerType.mentalWellness,
        today.wellness?.mood,
        today.wellness == null
            ? 'Not logged'
            : 'Stress ${today.wellness!.stressLevel}/5',
      ),
      (
        HealthTrackerType.food,
        today.mealCount == 0
            ? null
            : '${today.mealCount} '
                '${today.mealCount == 1 ? 'meal' : 'meals'} today',
        today.mealCount == 0
            ? 'No meals logged'
            : (today.meals.last.mealType.isNotEmpty
                ? today.meals.last.mealType
                : 'Logged'),
      ),
      (
        HealthTrackerType.weight,
        data.weight.firstOrNull == null
            ? null
            : _weightLabel(data.weight.first.weight, data.weight.first.unit),
        data.weight.firstOrNull == null
            ? 'Not logged'
            : 'Latest \u00B7 ${data.weight.first.date.day} '
                '${_monthName(data.weight.first.date)}',
      ),
    ];

    final isWide = MediaQuery.of(context).size.width >= 600;
    const spacing = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        final itemHeight = (itemWidth * 0.96)
            .clamp(isWide ? 170.0 : 150.0, 195.0)
            .toDouble();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: itemHeight,
          ),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final (type, value, summary) = entries[index];
            return TrackerGridCard(
              type: type,
              value: value,
              summary: summary,
              onTap: () => _openTracker(type),
            );
          },
        );
      },
    );
  }

  static String _cupsLabel(double cups) =>
      cups % 1 == 0 ? cups.toInt().toString() : cups.toStringAsFixed(1);

  static String _hydrationLabel(String level) =>
      level.isEmpty ? 'Logged' : level;

  static String _weightLabel(double weight, String unit) =>
      '${weight % 1 == 0 ? weight.toInt() : weight} $unit';

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.babyPink.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.blushPinkLight.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 18,
            color: AppColors.rosePink,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your health data stays private to you. Insights are educational '
              'observations of your own patterns - never a diagnosis. Share it '
              'with professionals only when you choose to.',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.45,
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _thousands(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  static String _monthName(DateTime d) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];
}

/// Pill-style Weekly / Monthly selector for the AI pattern detection section.
class _PatternRangeSelector extends StatelessWidget {
  final PatternRange range;
  final ValueChanged<PatternRange> onChanged;

  const _PatternRangeSelector({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.softLavender.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _segment(
            PatternRange.week,
            'Weekly',
            Icons.calendar_view_week_rounded,
          ),
          _segment(
            PatternRange.month,
            'Monthly',
            Icons.calendar_month_rounded,
          ),
        ],
      ),
    );
  }

  Widget _segment(PatternRange value, String label, IconData icon) {
    final selected = range == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      AppColors.softPurple,
                      AppColors.softPurpleLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: selected ? Colors.white : AppColors.textMedium,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : AppColors.textMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
