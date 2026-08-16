import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/providers/dashboard_provider.dart';
import '../../symptoms_assessment/providers/screening_results_provider.dart';
import '../health_tracking_screen.dart';
import '../providers/health_data_provider.dart';
import '../services/health_analytics.dart';
import '../services/health_report_service.dart';
import '../services/health_score_status.dart';
import '../widgets/health_dashboard_widgets.dart';
import '../widgets/report_period_sheet.dart';
import '../widgets/tracker_meta.dart';

class HealthReportScreen extends ConsumerWidget {
  const HealthReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScore = ref.watch(healthScoreProvider);
    final aiInsights = ref.watch(aiInsightsProvider);
    final healthData = ref.watch(healthDataProvider);

    final now = DateTime.now();
    final week = HealthAnalytics.thisWeek(healthData.allEntries, now);

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'Full Health Report',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.softPurple),
            onPressed: () => _handleDownload(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO SCORE
            _buildScoreHero(healthScore),
            const SizedBox(height: 32),

            // 2. SCORE BREAKDOWN
            Text(
              'SCORE BREAKDOWN',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownCard(week),
            const SizedBox(height: 32),

            // 3. RECENT AI INSIGHTS
            Text(
              'RECENT AI INSIGHTS',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            if (aiInsights.isEmpty)
              const AiEmptyState(hasAnyData: true)
            else
              ...aiInsights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AiInsightCard(
                      insight: insight,
                      onViewDetails: () =>
                          showAiInsightDetails(context, insight),
                    ),
                  )),

            const SizedBox(height: 32),

            // 4. VIEW HEALTH & ANALYTICS
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const HealthTrackingScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                ),
                label: Text(
                  'View Health & Analytics',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDownload(BuildContext context, WidgetRef ref) async {
    final period = await showReportPeriodSheet(context);
    if (period == null || !context.mounted) return;

    _showGeneratingDialog(context);

    try {
      // Ensure the user's data is loaded before building the report.
      await ref.read(healthDataProvider.notifier).loadAll();
      await ref.read(periodLogsProvider.notifier).loadPeriods();

      final data = HealthReportService.buildReport(
        periodType: period,
        healthData: ref.read(healthDataProvider),
        healthScore: ref.read(healthScoreProvider),
        cycleInsights: ref.read(cycleInsightsProvider),
        periodRecords: ref.read(periodLogsProvider).records,
        aiInsights: ref.read(aiInsightsProvider),
        screenings: ref.read(screeningResultsProvider),
        userName:
            ref.read(authNotifierProvider).userProfile?.username ?? '',
      );

      final bytes = await HealthReportService.generatePdfBytes(data);
      final fileName = HealthReportService.reportFileName(data);
      final savedPath = await HealthReportService.saveToDevice(bytes, fileName);

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showSuccessDialog(context, bytes, fileName, savedPath);
    } catch (_) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to generate your report. Please try again.',
            style: GoogleFonts.inter(),
          ),
          backgroundColor: AppColors.softPurple,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showGeneratingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3.5,
                    color: AppColors.softPurple,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Generating your health report…',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    Uint8List bytes,
    String fileName,
    String savedPath,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.confirmedGreen,
              size: 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Health report generated successfully.',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fileName,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.softPurple,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your report has been saved to this device. You can open it, '
              'or share it with your doctor or anyone you choose.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMedium,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Done',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              HealthReportService.sharePdf(bytes, fileName);
            },
            icon: const Icon(
              Icons.share_rounded,
              size: 18,
              color: AppColors.softPurple,
            ),
            label: Text(
              'Share',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.softPurple,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              HealthReportService.openPdf(savedPath);
            },
            icon: const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: AppColors.rosePink,
            ),
            label: Text(
              'Open',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.rosePink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreHero(HealthScoreState state) {
    final status = getHealthScoreStatus(state.score);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE0D8ED), // Soft purple tint
            Color(0xFFF7ECED), // Baby pink tint
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.softPurple.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: state.score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  color: getHealthScoreColor(state.score),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${status.score}',
                    style: GoogleFonts.outfit(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      color: AppColors.softPurple,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    '/100',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.softPurple.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status.status,
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: status.color,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            status.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You are in the top ${state.percentile}% of users with similar cycle profiles this week.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCORE BREAKDOWN (built from the user's stored health data)
  // ---------------------------------------------------------------------------

  Widget _buildBreakdownCard(PeriodStats week) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _breakdownItem(
            meta: TrackerMeta.sleep,
            title: 'Sleep',
            value: _formatSleep(week.avgSleepMinutes),
            status: _grade(
              good: week.avgSleepMinutes != null &&
                  week.avgSleepMinutes! >= 420 &&
                  week.avgSleepMinutes! <= 540,
              fair: week.avgSleepMinutes != null,
              logged: week.avgSleepMinutes != null,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderGrey),
          _breakdownItem(
            meta: TrackerMeta.steps,
            title: 'Activity',
            value: _formatSteps(week.avgSteps),
            status: _grade(
              good: week.avgSteps != null && week.avgSteps! >= 7500,
              fair: week.avgSteps != null && week.avgSteps! >= 5000,
              logged: week.avgSteps != null,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderGrey),
          _breakdownItem(
            meta: TrackerMeta.water,
            title: 'Hydration',
            value: _formatWater(week.avgWaterFlOz),
            status: _grade(
              good: week.avgWaterFlOz != null && week.avgWaterFlOz! >= 64,
              fair: week.avgWaterFlOz != null && week.avgWaterFlOz! >= 40,
              logged: week.avgWaterFlOz != null,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderGrey),
          _breakdownItem(
            meta: TrackerMeta.wellness,
            title: 'Mental Wellbeing',
            value: _formatStress(week.avgStress),
            status: _grade(
              good: week.avgStress != null && week.avgStress! <= 2,
              fair: week.avgStress != null && week.avgStress! <= 3.5,
              logged: week.avgStress != null,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderGrey),
          _breakdownItem(
            meta: TrackerMeta.food,
            title: 'Nutrition',
            value: _formatMeals(week.mealCount),
            status: _grade(
              good: week.mealCount >= 14,
              fair: week.mealCount >= 7,
              logged: week.mealCount > 0,
            ),
          ),
          const Divider(height: 28, color: AppColors.borderGrey),
          _breakdownItem(
            meta: TrackerMeta.supplements,
            title: 'Medication Adherence',
            value: _formatSupplements(week.supplementDays),
            status: _grade(
              good: week.supplementDays >= 6,
              fair: week.supplementDays >= 3,
              logged: week.supplementDays > 0,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softLavender.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Breakdown is based on your logged health data over the last 7 days.',
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdownItem({
    required TrackerMeta meta,
    required String title,
    required String value,
    required (String, Color) status,
  }) {
    final (statusLabel, statusColor) = status;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: meta.color.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(meta.icon, color: meta.strongColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textMedium,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// On track / needs work / needs attention / not logged, with colors.
  (String, Color) _grade({
    required bool good,
    required bool fair,
    required bool logged,
  }) {
    if (good) return ('On Track', AppColors.confirmedGreen);
    if (fair) return ('Needs Work', AppColors.pendingAmber);
    if (logged) return ('Needs Attention', AppColors.deepRose);
    return ('Not Logged', AppColors.textLight);
  }

  String _formatSleep(double? minutes) {
    if (minutes == null) return 'No sleep logged this week.';
    final hours = (minutes / 60).floor();
    final mins = (minutes % 60).round();
    return 'Avg ${hours}h ${mins}m of sleep per day this week.';
  }

  String _formatSteps(double? steps) {
    if (steps == null) return 'No activity logged this week.';
    return 'Avg ${steps.round().toString()} steps per day this week.';
  }

  String _formatWater(double? flOz) {
    if (flOz == null) return 'No hydration logged this week.';
    final cups = (flOz / 8).toStringAsFixed(1);
    return 'Avg $cups cups of water per day this week.';
  }

  String _formatStress(double? stress) {
    if (stress == null) return 'No wellness logged this week.';
    final level = stress <= 2.0
        ? 'Low'
        : stress <= 3.5
            ? 'Moderate'
            : 'High';
    return 'Avg stress level: $level (${stress.toStringAsFixed(1)}/5) this week.';
  }

  String _formatMeals(int count) {
    if (count == 0) return 'No meals logged this week.';
    return '$count ${count == 1 ? 'meal' : 'meals'} logged this week.';
  }

  String _formatSupplements(int days) {
    if (days == 0) return 'No supplements logged this week.';
    return 'Supplements logged on $days of the last 7 days.';
  }
}
