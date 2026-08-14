import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/health_data_provider.dart';
import '../services/health_analytics.dart';
import '../widgets/health_dashboard_widgets.dart';

/// Full list of AI pattern insights derived from the user's own stored data.
class AiInsightsScreen extends ConsumerWidget {
  const AiInsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(healthDataProvider);
    final insights = ref.watch(aiInsightsProvider);
    final dataDays = HealthAnalytics.dataDaysLastDays(
      data.allEntries,
      DateTime.now(),
      days: 30,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 20,
              color: AppColors.softPurple,
            ),
            const SizedBox(width: 8),
            Text(
              'Kyra AI',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
      body: insights.isEmpty || dataDays < 3
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const AiHeroBanner(),
                const SizedBox(height: 14),
                AiEmptyState(hasAnyData: dataDays > 0),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: insights.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildDisclaimer(context),
                  );
                }
                final insight = insights[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AiInsightCard(
                    insight: insight,
                    onViewDetails: () =>
                        showAiInsightDetails(context, insight),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softLavender.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.softPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Insights are observations of your own logged data and are '
              'not medical advice. Correlations in your data are not '
              'diagnoses.',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                height: 1.4,
                color: AppColors.textMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}