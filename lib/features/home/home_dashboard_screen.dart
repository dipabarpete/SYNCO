import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/app_bar_header.dart';
import 'widgets/health_score_card.dart';
import 'widgets/health_data_glance_grid.dart';
import 'widgets/period_cycle_overview_card.dart';
import 'widgets/daily_insights_card.dart';
import 'widgets/upcoming_reminders_card.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Premium pastel cream background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. APP BAR
              AppBarHeader(
                userName: 'Ananya',
                isPartnerLinked: false,
                onAvatarTap: () => _showDialogInfo(context, 'Profile Avatar'),
                onPartnerTap: () => _showDialogInfo(context, 'Link With Partner'),
                onNotificationTap: () => _showDialogInfo(context, 'Notifications'),
              ),
              const SizedBox(height: 20),

              // 2. HEALTH SCORE CARD (Hero Card)
              HealthScoreCard(
                score: 82,
                percentile: 78,
                title: 'Health Score',
                description:
                    'Your body is in optimal balance today! Good sleep and hydration are boosting your energy.',
                onTap: () => _showDialogInfo(context, 'Health Score Details'),
              ),
              const SizedBox(height: 24),

              // 3. HEALTH DATA GLANCE
              _buildSectionTitle('Health Data Glance', subtitle: 'Daily Metrics'),
              const SizedBox(height: 12),
              HealthDataGlanceGrid(
                onTileTap: () => _showDialogInfo(context, 'Metric Detail'),
              ),
              const SizedBox(height: 24),

              // 4. PERIOD CYCLE OVERVIEW
              _buildSectionTitle('Period Cycle Overview', subtitle: 'Track & Predict'),
              const SizedBox(height: 12),
              PeriodCycleOverviewCard(
                currentPhase: 'Follicular Phase',
                currentDay: 8,
                totalDays: 28,
                daysUntilNextPeriod: 16,
                onTap: () => _showDialogInfo(context, 'Period Cycle Overview'),
              ),
              const SizedBox(height: 24),

              // 5. MY DAILY INSIGHTS
              _buildSectionTitle('My Daily Insights', subtitle: 'Personalized For You'),
              const SizedBox(height: 12),
              DailyInsightsCard(
                title: 'Follicular Phase Guidance',
                description:
                    'Your estrogen is rising today! Walking for 20 minutes and eating nutrient-dense foods will keep your energy and focus high.',
                actionButtonText: 'Explore Daily Guidance',
                onActionTap: () => _showDialogInfo(context, 'Daily Insight Details'),
              ),
              const SizedBox(height: 24),

              // 6. UPCOMING REMINDERS
              const UpcomingRemindersCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.softPurple,
            ),
          ),
        ],
      ],
    );
  }

  void _showDialogInfo(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          featureName,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '$featureName dashboard component tapped.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
