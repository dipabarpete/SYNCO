import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../home/providers/dashboard_provider.dart';
import '../providers/health_data_provider.dart';
import '../widgets/health_dashboard_widgets.dart';
import '../services/pdf_report_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../doctor/services/chat_service.dart';
import '../../../providers/app_providers.dart';
import '../models/ai_insight.dart';
import '../widgets/share_report_bottom_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:printing/printing.dart';

class HealthReportScreen extends ConsumerWidget {
  const HealthReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthScore = ref.watch(healthScoreProvider);
    final aiInsights = ref.watch(aiInsightsProvider);
    final user = ref.watch(authNotifierProvider).user;

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
            onPressed: () async {
              try {
                final pdfBytes = await PdfReportService.generateHealthReport(
                  healthScore: healthScore,
                  aiInsights: aiInsights,
                  userName: user?.displayName ?? user?.email ?? 'SYNCO Patient',
                );
                await Printing.sharePdf(bytes: pdfBytes, filename: 'SYNCO_Health_Report.pdf');
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to generate PDF: $e')),
                );
              }
            },
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

            // 2. BREAKDOWN SECTION
            Text(
              'Score Breakdown',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildBreakdownCard(healthScore),
            const SizedBox(height: 32),

            // 3. RECENT KYRA AI INSIGHTS
            Text(
              'Recent AI Insights',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            if (aiInsights.isEmpty)
              const AiEmptyState(hasAnyData: true)
            else
              ...aiInsights.take(2).map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AiInsightCard(
                      insight: insight,
                      onViewDetails: () =>
                          showAiInsightDetails(context, insight),
                    ),
                  )),
            
            const SizedBox(height: 32),

            // 4. SHARE BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (_) => ShareReportBottomSheet(
                      healthScore: healthScore,
                      aiInsights: aiInsights,
                    ),
                  );
                },
                icon: const Icon(Icons.medical_services_rounded, color: Colors.white),
                label: Text(
                  'Share with Doctor',
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

  Widget _buildScoreHero(HealthScoreState state) {
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
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: state.score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  color: AppColors.softPurple,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${state.score}',
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppColors.softPurple,
                      height: 1.1,
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
          Text(
            state.score >= 80 ? 'Excellent Health' : state.score >= 60 ? 'Good Health' : 'Needs Attention',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You are in the top ${state.percentile}% of users with similar cycle profiles this week.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(HealthScoreState state) {
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
          _buildBreakdownItem(
            icon: Icons.calendar_month_rounded,
            title: 'Cycle Regularity',
            status: 'Optimal',
            statusColor: Colors.green,
            description: 'Your cycle length is highly consistent.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderGrey),
          ),
          _buildBreakdownItem(
            icon: Icons.health_and_safety_rounded,
            title: 'Symptom Severity',
            status: state.score >= 80 ? 'Low' : 'Moderate',
            statusColor: state.score >= 80 ? Colors.green : Colors.orange,
            description: 'Based on your logs over the last 7 days.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderGrey),
          ),
          _buildBreakdownItem(
            icon: Icons.water_drop_rounded,
            title: 'Hydration',
            status: 'Needs Work',
            statusColor: Colors.orange,
            description: 'You are averaging below your daily water goal.',
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required String title,
    required String status,
    required Color statusColor,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.softPurple.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.softPurple, size: 20),
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
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
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
}
