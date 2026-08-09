import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../auth/providers/auth_provider.dart';
import 'widgets/app_bar_header.dart';
import 'widgets/health_score_card.dart';
import 'widgets/health_data_glance_grid.dart';
import 'widgets/period_cycle_overview_card.dart';
import 'widgets/daily_insights_card.dart';
import 'widgets/upcoming_reminders_card.dart';

import '../health/health_tracking_screen.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final userEmail = authState.userProfile?.email ?? authState.user?.email;
    final userPhone = authState.userProfile?.phone ?? authState.user?.phone;
    final displayName = authState.userProfile?.username.isNotEmpty == true
        ? authState.userProfile!.username
        : (userEmail != null
            ? userEmail.split('@').first
            : (userPhone != null ? 'User' : 'Ananya'));

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
                userName: displayName,
                isPartnerLinked: false,
                onAvatarTap: () => _showProfileDialog(context, ref, displayName, authState),
                onPartnerTap: () => _showDialogInfo(context, 'Link With Partner'),
                onNotificationTap: () => _showDialogInfo(context, 'Notifications'),
              ),
              const SizedBox(height: 20),

              // 2. HEALTH SCORE CARD (Hero Card)
              HealthScoreCard(
                score: 84,
                percentile: 78,
                title: 'Health Score',
                description: 'Your consistency is paying off.',
                onTap: () => _showDialogInfo(context, 'Health Score Details'),
                onViewReportTap: () => _showDialogInfo(context, 'View Full Report'),
                onSuggestionTap: () => _showDialogInfo(context, 'Better Sleep Suggestion'),
              ),
              const SizedBox(height: 24),

              // 3. HEALTH AT A GLANCE
              HealthDataGlanceGrid(
                onTileTap: (title) => _showDialogInfo(context, title),
                onViewAllTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthTrackingScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 4. PERIOD CYCLE OVERVIEW
              _buildSectionTitle('Period Cycle Overview'),
              const SizedBox(height: 12),
              PeriodCycleOverviewCard(
                currentPhase: 'Follicular Phase',
                currentDay: 8,
                totalDays: 28,
                daysUntilNextPeriod: 16,
                onTap: () => _showDialogInfo(context, 'Period Cycle Details'),
              ),
              const SizedBox(height: 24),

              // 5. MY DAILY INSIGHTS
              _buildSectionTitle('My Daily Insights'),
              const SizedBox(height: 12),
              DailyInsightsCard(
                onActionTap: () => _showDialogInfo(context, 'Daily Guidance'),
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

  void _showProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String userName,
    AuthState authState,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: AppColors.creamWhite,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.babyPink,
                child: Icon(Icons.person_rounded, color: AppColors.softPurple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    (authState.userProfile?.email ?? authState.user?.email) ??
                        (authState.userProfile?.phone ?? authState.user?.phone) ??
                        'HerSync Account',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.softPurple),
                const SizedBox(width: 10),
                Text(
                  'Account Status: Active',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textDark),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: AppColors.textMedium),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout_rounded, size: 18, color: Colors.white),
            label: Text(
              'Log Out',
              style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRose,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
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
