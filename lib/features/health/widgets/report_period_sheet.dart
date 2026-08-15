import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../models/health_report_data.dart';

/// Shows the report-period chooser and resolves to the selected
/// [HealthReportPeriodType], or null when dismissed.
Future<HealthReportPeriodType?> showReportPeriodSheet(BuildContext context) {
  return showModalBottomSheet<HealthReportPeriodType>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const ReportPeriodSheet(),
  );
}

class ReportPeriodSheet extends StatefulWidget {
  const ReportPeriodSheet({super.key});

  @override
  State<ReportPeriodSheet> createState() => _ReportPeriodSheetState();
}

class _ReportPeriodSheetState extends State<ReportPeriodSheet> {
  HealthReportPeriodType? _selected;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(const Duration(days: 6));
    final weekLabel =
        '${DateFormat('d MMM').format(weekStart)} – ${DateFormat('d MMM').format(now)}';
    final monthLabel = DateFormat('MMMM yyyy').format(now);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(
                  color: AppColors.borderGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Generate Health Report',
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose the period for your report',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 18),
            _periodTile(
              type: HealthReportPeriodType.weekly,
              title: 'Weekly Report',
              subtitle: 'Last 7 days · $weekLabel',
              icon: Icons.calendar_view_week_rounded,
            ),
            const SizedBox(height: 12),
            _periodTile(
              type: HealthReportPeriodType.monthly,
              title: 'Monthly Report',
              subtitle: 'Current month · $monthLabel',
              icon: Icons.calendar_month_rounded,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context).pop(_selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  disabledBackgroundColor:
                      AppColors.softPurple.withValues(alpha: 0.35),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Generate Report',
                  style: GoogleFonts.inter(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodTile({
    required HealthReportPeriodType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selected == type;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selected = type),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.softPurple.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppColors.softPurple
                  : AppColors.borderGrey,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.softPurple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.softPurple, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: selected
                    ? AppColors.softPurple
                    : AppColors.textLight,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
