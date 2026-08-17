import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../doctor/models/patient_health_summary.dart';
import '../providers/doctor_provider.dart';

/// Doctor-facing Patient Health Summary.
///
/// Opens from an appointment card's "View Health Summary" action and shows
/// the patient's real, existing SYNCO data (cycle, symptoms, screening
/// indicators, health score, reports and concern). Sections without data
/// render empty states - nothing is fabricated. Access is limited to the
/// doctor attached to the appointment via [patientHealthSummaryProvider].
class PatientHealthSummaryScreen extends ConsumerWidget {
  final String userId;
  final String appointmentId;
  final String patientName;

  const PatientHealthSummaryScreen({
    super.key,
    required this.userId,
    required this.appointmentId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(
      patientHealthSummaryProvider(
        (appointmentId: appointmentId, userId: userId),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Patient Health Summary',
              style: GoogleFonts.outfit(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            if (patientName.isNotEmpty)
              Text(
                patientName,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.textMedium,
                ),
              ),
          ],
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.softPurple),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "Couldn't load this patient's health summary. "
              'Please try again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textMedium),
            ),
          ),
        ),
        data: (summary) => _buildContent(summary),
      ),
    );
  }

  Widget _buildContent(PatientHealthSummary? summary) {
    if (summary == null || !summary.authorized) {
      return const _UnavailableState(
        icon: Icons.lock_outline_rounded,
        title: 'Health summary unavailable',
        subtitle: 'You can only view summaries for your own appointments.',
      );
    }
    if (summary.hasNoData) {
      return const _UnavailableState(
        icon: Icons.health_and_safety_outlined,
        title: 'No health data yet',
        subtitle: 'This patient has not logged health data yet.',
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _SummaryHeader(summary: summary),
        const SizedBox(height: 16),
        if (summary.hasCycleHistory) ...[
          _SectionCard(
            icon: Icons.track_changes_rounded,
            title: 'Cycle',
            child: _CycleSection(summary: summary),
          ),
          const SizedBox(height: 14),
        ],
        _SectionCard(
          icon: Icons.healing_rounded,
          title: 'Recent Symptoms',
          child: summary.recentSymptoms.isEmpty
              ? const _EmptyRow('No recent symptoms logged')
              : _BulletList(items: summary.recentSymptoms),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.assignment_turned_in_outlined,
          title: 'Screening',
          child: summary.screeningIndicators.isEmpty
              ? const _EmptyRow('No screening results available')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final indicator in summary.screeningIndicators)
                      _IndicatorRow(indicator: indicator),
                    const SizedBox(height: 10),
                    Text(
                      'Screening indicators, not a diagnosis. Review with '
                      'the patient before concluding.',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textLight,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.monitor_heart_outlined,
          title: 'Health Score',
          child: summary.healthScore == null
              ? const _EmptyRow('No health score available')
              : _HealthScoreRow(score: summary.healthScore!),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          icon: Icons.description_outlined,
          title: 'Recent Reports',
          child: summary.reports.isEmpty
              ? const _EmptyRow('No recent reports uploaded')
              : Column(
                  children: [
                    for (final report in summary.reports)
                      _ReportRow(report: report),
                  ],
                ),
        ),
        if (summary.concern != null) ...[
          const SizedBox(height: 14),
          _SectionCard(
            icon: Icons.chat_outlined,
            title: "Patient's Concern",
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softLavender.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.softPurple.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                '"${summary.concern}"',
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: AppColors.textDark,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Small header card with the patient's name and consultation context.
class _SummaryHeader extends StatelessWidget {
  final PatientHealthSummary summary;

  const _SummaryHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final detailLines = <String>[
      if (summary.hasCycleHistory &&
          summary.currentPhaseLabel != null)
        'Currently ${summary.currentPhaseLabel}',
      if (summary.healthScore != null)
        'Health Score ${summary.healthScore}/100',
      if (summary.recentSymptomChange != null)
        'Symptom change: ${summary.recentSymptomChange}',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.babyPink,
            child: Text(
              summary.patientName.isNotEmpty
                  ? summary.patientName.substring(0, 1).toUpperCase()
                  : 'P',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                color: AppColors.softPurple,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.patientName.isNotEmpty
                      ? summary.patientName
                      : 'Patient',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                if (detailLines.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detailLines.join('  ·  '),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMedium,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// White card used for every summary section.
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.softLavender,
                ),
                child: Icon(icon, size: 16, color: AppColors.softPurple),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _CycleSection extends StatelessWidget {
  final PatientHealthSummary summary;

  const _CycleSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CycleLine(
          label: '${summary.averageCycleLength}-day average',
          detail: '${summary.averagePeriodDuration}-day period',
        ),
        if (summary.currentPhaseLabel != null) ...[
          const SizedBox(height: 10),
          _CycleLine(
            label: 'Currently: ${summary.currentPhaseLabel}',
            detail: 'Estimated from logged period history',
            isPhase: true,
          ),
        ],
        if (summary.lastPeriodStartLabel != null) ...[
          const SizedBox(height: 10),
          _CycleLine(
            label: 'Last period started ${summary.lastPeriodStartLabel}',
          ),
        ],
      ],
    );
  }
}

class _CycleLine extends StatelessWidget {
  final String label;
  final String? detail;
  final bool isPhase;

  const _CycleLine({
    required this.label,
    this.detail,
    this.isPhase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isPhase
              ? Icons.circle
              : Icons.calendar_today_rounded,
          size: 14,
          color: isPhase ? AppColors.softPurple : AppColors.textLight,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(
                  detail!,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.softPurple,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: AppColors.textDark,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  final PatientScreeningIndicator indicator;

  const _IndicatorRow({required this.indicator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.medical_information_outlined,
            size: 16,
            color: AppColors.softPurple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: indicator.name,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextSpan(
                    text: ' — ${indicator.levelLabel}',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthScoreRow extends StatelessWidget {
  final int score;

  const _HealthScoreRow({required this.score});

  @override
  Widget build(BuildContext context) {
    final accent = score >= 80
        ? AppColors.confirmedGreen
        : score >= 60
            ? AppColors.pendingAmber
            : AppColors.deepRose;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$score / 100',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Based on the patient\'s logged symptoms.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  final PatientReport report;

  const _ReportRow({required this.report});

  @override
  Widget build(BuildContext context) {
    final uploadedLabel = report.uploadedAt != null
        ? _formatUploadedAt(report.uploadedAt!)
        : 'Uploaded';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(
            Icons.upload_file_rounded,
            size: 16,
            color: AppColors.softPurple,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              report.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            uploadedLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatUploadedAt(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return 'Uploaded';
    return 'Uploaded · ${DateFormat('d MMM yyyy').format(parsed)}';
  }
}

class _EmptyRow extends StatelessWidget {
  final String message;

  const _EmptyRow(this.message);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.info_outline_rounded,
          size: 15,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textMedium,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _UnavailableState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _UnavailableState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softLavender,
              ),
              child: Icon(icon, size: 28, color: AppColors.softPurple),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
