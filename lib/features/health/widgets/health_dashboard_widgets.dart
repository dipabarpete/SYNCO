import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../models/ai_insight.dart';
import '../models/health_entries.dart';
import '../services/health_analytics.dart';
import 'tracker_meta.dart';

/// Section heading used across the Health dashboard.
class HealthSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const HealthSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Hero banner for the Kyra AI pattern detection card.
///
/// When [patternCount] is provided the subtitle becomes a live heading that
/// reflects the actual number of detected patterns.
class AiHeroBanner extends StatelessWidget {
  final int? patternCount;

  const AiHeroBanner({super.key, this.patternCount});

  String get _subtitle {
    final count = patternCount;
    if (count == null) {
      return 'AI pattern detection from your health data';
    }
    if (count == 0) {
      return 'AI found no important patterns yet';
    }
    return 'AI found $count important pattern${count == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.softPurple, AppColors.softPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.softPurple.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kyra AI',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.psychology_rounded,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }
}

/// One AI insight card shown on the dashboard and in the all-insights screen.
///
/// Presented as a clean tappable row: tapping the card or the arrow on the
/// right opens that insight's own detail.
class AiInsightCard extends StatelessWidget {
  final AiInsight insight;
  final VoidCallback? onViewDetails;

  const AiInsightCard({
    super.key,
    required this.insight,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.softPurple.withValues(alpha: 0.14),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onViewDetails,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.softPurpleLight, AppColors.softPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              insight.title,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          _TrendStatusPill(trend: insight.trend),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        insight.summary,
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${insight.periodLabel}  \u00B7  ${insight.basisLabel}',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.textLight,
                        ),
                      ),
                      if (insight.suggestion != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.softLavender.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.spa_rounded,
                                size: 15,
                                color: AppColors.softPurple,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'How you can improve',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      insight.suggestion!,
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        height: 1.4,
                                        color: AppColors.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.softPurple.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.softPurple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendStatusPill extends StatelessWidget {
  final InsightTrend trend;

  const _TrendStatusPill({required this.trend});

  @override
  Widget build(BuildContext context) {
    final (emoji, label, color, background) = switch (trend) {
      InsightTrend.up => (
          '\u{1F331}',
          'Improving',
          AppColors.confirmedGreen,
          AppColors.mintGreen,
        ),
      InsightTrend.down => (
          '\u{26A0}\u{FE0F}',
          'Needs attention',
          AppColors.pendingAmber,
          AppColors.pendingAmberSoft,
        ),
      InsightTrend.neutral => (
          '\u{27A1}\u{FE0F}',
          'Stable',
          AppColors.textMedium,
          AppColors.softLavender,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the detail view for an [AiInsight] as a bottom sheet.
void showAiInsightDetails(BuildContext context, AiInsight insight) {
  showModalBottomSheet(
    context: context,
    useSafeArea: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.softPurpleLight,
                      AppColors.softPurple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.title,
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${insight.periodLabel}  \u00B7  ${insight.basisLabel}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            insight.summary,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textDark,
            ),
          ),
          if (insight.detail != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.softLavender.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                insight.detail!,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.textMedium,
                ),
              ),
            ),
          ],
          if (insight.suggestion != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.spa_rounded,
                  size: 16,
                  color: AppColors.softPurple,
                ),
                const SizedBox(width: 7),
                Text(
                  'How you can improve',
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              insight.suggestion!,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Empty state for the AI section when there is (not enough) data.
class AiEmptyState extends StatelessWidget {
  final bool hasAnyData;

  const AiEmptyState({super.key, required this.hasAnyData});

  @override
  Widget build(BuildContext context) {
    final title = hasAnyData
        ? 'Keep tracking to unlock personalized patterns.'
        : 'Your patterns will appear here.';
    final body = hasAnyData
        ? 'Once we have enough data, Kyra will start identifying patterns '
            'in your health.'
        : 'Start tracking your health to help Kyra understand your personal '
            'trends.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.softLavender.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.softPurple,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.4,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact "Today" summary card with the eight key metrics.
class TodaySummaryCard extends StatelessWidget {
  final DailySnapshot snapshot;

  const TodaySummaryCard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    final sleep = snapshot.sleep;
    final wellness = snapshot.wellness;
    final weight = snapshot.weight;

    final tiles = <_SummaryTile>[
      _SummaryTile(
        icon: TrackerMeta.sleep.icon,
        color: TrackerMeta.sleep.color,
        label: 'Sleep',
        value: sleep == null
            ? '--'
            : formatDurationMinutes(sleep.durationMinutes),
        sub: sleep?.quality ?? 'Not logged',
      ),
      _SummaryTile(
        icon: TrackerMeta.water.icon,
        color: TrackerMeta.water.color,
        label: 'Water',
        value: snapshot.water.isEmpty
            ? '--'
            : '${_cups(snapshot.totalWaterCups)} cups',
        sub: snapshot.water.isEmpty
            ? 'Not logged'
            : (snapshot.water.last.hydrationLevel),
      ),
      _SummaryTile(
        icon: TrackerMeta.steps.icon,
        color: TrackerMeta.steps.strongColor,
        label: 'Steps',
        value: snapshot.steps == null ? '--' : _thousands(snapshot.steps!.count),
        sub: snapshot.steps == null ? 'Not logged' : 'steps',
      ),
      _SummaryTile(
        icon: TrackerMeta.sugar.icon,
        color: TrackerMeta.sugar.strongColor,
        label: 'Cravings',
        value: snapshot.cravings.isEmpty
            ? '--'
            : snapshot.topCravingLevel ?? 'Logged',
        sub: snapshot.cravings.isEmpty
            ? 'Not logged'
            : '${snapshot.cravings.length} ${snapshot.cravings.length == 1 ? 'entry' : 'entries'}',
      ),
      _SummaryTile(
        icon: TrackerMeta.wellness.icon,
        color: TrackerMeta.wellness.color,
        label: 'Stress',
        value: wellness == null ? '--' : '${wellness.stressLevel}/5',
        sub: wellness == null ? 'Not logged' : 'level',
      ),
      _SummaryTile(
        icon: Icons.bolt_rounded,
        color: TrackerMeta.steps.strongColor,
        label: 'Energy',
        value: wellness == null ? '--' : '${wellness.energyLevel}/5',
        sub: wellness == null ? 'Not logged' : 'level',
      ),
      _SummaryTile(
        icon: TrackerMeta.food.icon,
        color: TrackerMeta.food.strongColor,
        label: 'Meals',
        value: snapshot.mealCount == 0 ? '--' : '${snapshot.mealCount}',
        sub: snapshot.mealCount == 0
            ? 'Not logged'
            : '${snapshot.mealCount == 1 ? 'meal' : 'meals'} logged',
      ),
      _SummaryTile(
        icon: TrackerMeta.weight.icon,
        color: TrackerMeta.weight.color,
        label: 'Weight',
        value: weight == null
            ? '--'
            : '${weight.weight % 1 == 0 ? weight.weight.toInt() : weight.weight}',
        sub: weight == null
            ? 'Not logged'
            : '${weight.unit} \u00B7 ${weight.date.day} ${_month(weight.date)}',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.healthCardGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.borderGrey.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.today_rounded,
                size: 17,
                color: AppColors.softPurple,
              ),
              const SizedBox(width: 7),
              Text(
                'TODAY',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.softPurple,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                _monthDay(snapshot.date),
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 8,
            childAspectRatio: 0.92,
            children: tiles,
          ),
        ],
      ),
    );
  }

  static String _cups(double cups) {
    final rounded = cups % 1 == 0 ? cups.toInt() : cups.toStringAsFixed(1);
    return '$rounded';
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

  static String _month(DateTime d) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1];

  static String _monthDay(DateTime d) =>
      '${d.day} ${_month(d)}, ${d.year}';
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String sub;

  const _SummaryTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(height: 5),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 9.5,
            color: AppColors.textMedium,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Grid card for a health tracker on the dashboard (2 x 4 layout).
///
/// Shows the tracker icon, title, the latest value (or a muted "Not logged"
/// empty state) and a small secondary line. Tapping the card opens the
/// tracker's logging UI.
class TrackerGridCard extends StatelessWidget {
  final HealthTrackerType type;
  final String? value;
  final String? summary;
  final VoidCallback onTap;

  const TrackerGridCard({
    super.key,
    required this.type,
    required this.value,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = TrackerMeta.of(type);
    final hasData = value != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.96),
            Color.lerp(Colors.white, meta.color, 0.12)!
                .withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: meta.color.withValues(alpha: 0.32),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: meta.strongColor.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        meta.icon,
                        color: meta.strongColor,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: meta.color.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: meta.strongColor.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            hasData ? Icons.edit_rounded : Icons.add_rounded,
                            size: 13,
                            color: meta.strongColor,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            hasData ? 'Edit' : 'Log',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: meta.strongColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  type.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Text(
                  value ?? 'Not logged',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: hasData ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  summary ?? 'Tap to log',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: hasData ? AppColors.textMedium : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}