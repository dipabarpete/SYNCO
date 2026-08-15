import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/health_report_data.dart';

/// Builds a professional, printable SYNCO health report PDF entirely on the
/// device from a [HealthReportData] snapshot. No network calls are made and
/// no user data leaves the device.
class HealthReportPdfGenerator {
  static const PdfColor _brandPurple = PdfColor.fromInt(0xFF7B4397);
  static const PdfColor _textDark = PdfColor.fromInt(0xFF2D2335);
  static const PdfColor _textMedium = PdfColor.fromInt(0xFF6E617A);
  static const PdfColor _textLight = PdfColor.fromInt(0xFF9E93A8);
  static const PdfColor _borderGrey = PdfColor.fromInt(0xFFE5E7EB);
  static const PdfColor _tintPurple = PdfColor.fromInt(0xFFF3EEF9);
  static const PdfColor _tintPink = PdfColor.fromInt(0xFFFBF0F3);

  Future<Uint8List> generate(HealthReportData data) async {
    final doc = pw.Document(
      title: 'SYNCO Personal Health Report',
      author: 'SYNCO',
      subject: _t('${data.periodLabel} — ${data.dateRangeLabel}'),
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
        italic: pw.Font.helveticaOblique(),
        boldItalic: pw.Font.helveticaBoldOblique(),
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(36, 44, 36, 40),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => <pw.Widget>[
          _buildCover(data),
          pw.SizedBox(height: 22),
          _sectionTitle('1. Health Overview'),
          _buildHealthOverview(data),
          pw.SizedBox(height: 20),
          _sectionTitle('2. Score Breakdown'),
          _buildBreakdown(data),
          pw.SizedBox(height: 20),
          _sectionTitle('3. Health Tracking'),
          ..._buildTracking(data),
          pw.SizedBox(height: 20),
          _sectionTitle('4. Period & Cycle'),
          _buildCycle(data),
          pw.SizedBox(height: 20),
          _sectionTitle('5. Symptom Assessment'),
          _buildAssessments(data),
          pw.SizedBox(height: 20),
          _sectionTitle('6. AI Insights'),
          ..._buildInsights(data),
          pw.SizedBox(height: 20),
          _sectionTitle('7. Health Summary'),
          _buildSummary(data),
        ],
      ),
    );

    return doc.save();
  }

  // ---------------------------------------------------------------------------
  // HEADER / FOOTER (repeat on every page)
  // ---------------------------------------------------------------------------

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _borderGrey, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SYNCO',
            style: pw.TextStyle(
              color: _brandPurple,
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 2.2,
            ),
          ),
          pw.Text(
            'Personal Health Report',
            style: pw.TextStyle(
              color: _textMedium,
              fontSize: 9.5,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _borderGrey, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'SYNCO · Your health, understood.',
            style: pw.TextStyle(color: _textLight, fontSize: 8.5),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(color: _textLight, fontSize: 8.5),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // COVER BLOCK
  // ---------------------------------------------------------------------------

  pw.Widget _buildCover(HealthReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [_tintPurple, _tintPink],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(14),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SYNCO',
            style: pw.TextStyle(
              color: _brandPurple,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'PERSONAL HEALTH REPORT',
            style: pw.TextStyle(
              color: _textDark,
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            children: [
              _chip(_t(data.periodLabel)),
              pw.SizedBox(width: 8),
              _chip(_t(data.dateRangeLabel)),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            _t('Report period: ${data.periodLabel.toLowerCase()} · '
                '${data.dateRangeLabel}'),
            style: pw.TextStyle(color: _textMedium, fontSize: 10.5),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            _t('Generated on ${data.generatedAtLabel}'
                '${data.userName.isEmpty ? '' : ' for ${data.userName}'}'),
            style: pw.TextStyle(color: _textMedium, fontSize: 10.5),
          ),
        ],
      ),
    );
  }

  String _t(String text) => text
      .replaceAll('\u2013', '-')
      .replaceAll('\u2014', '-')
      .replaceAll('\u2018', "'")
      .replaceAll('\u2019', "'")
      .replaceAll('\u201c', '"')
      .replaceAll('\u201d', '"')
      .replaceAll('\u2026', '...');

  pw.Widget _chip(String label) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFFFFF),
        borderRadius: pw.BorderRadius.circular(20),
      ),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          color: _brandPurple,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SECTIONS
  // ---------------------------------------------------------------------------

  pw.Widget _sectionTitle(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: _brandPurple,
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  pw.Widget _buildHealthOverview(HealthReportData data) {
    final statusColor = PdfColor.fromInt(data.healthColorArgb);
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFFFFF),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderGrey, width: 1),
      ),
      child: pw.Row(
        children: [
          pw.Container(
            width: 84,
            height: 84,
            alignment: pw.Alignment.center,
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              border: pw.Border.all(color: statusColor, width: 6),
            ),
            child: pw.Text(
              '${data.healthScore}',
              style: pw.TextStyle(
                color: _textDark,
                fontSize: 30,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 18),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding:
                      const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: _tintPurple,
                    borderRadius: pw.BorderRadius.circular(14),
                  ),
                  child: pw.Text(
                    _t(data.healthStatus),
                    style: pw.TextStyle(
                      color: statusColor,
                      fontSize: 10.5,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Overall Health Score: ${data.healthScore}/100',
                  style: pw.TextStyle(
                    color: _textDark,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _t(data.healthMessage),
                  style: pw.TextStyle(color: _textMedium, fontSize: 10.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildBreakdown(HealthReportData data) {
    if (data.breakdown.isEmpty) {
      return _emptyNote('No score breakdown available for this period.');
    }
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFFFFF),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderGrey, width: 1),
      ),
      child: pw.Column(
        children: [
          for (var i = 0; i < data.breakdown.length; i++) ...[
            if (i > 0) pw.Divider(color: _borderGrey, height: 1),
            _breakdownRow(data.breakdown[i]),
          ],
        ],
      ),
    );
  }

  pw.Widget _breakdownRow(ScoreBreakdownRow row) {
    final statusColor = PdfColor.fromInt(row.statusColorArgb);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              _t(row.title),
              style: pw.TextStyle(
                color: _textDark,
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              _t(row.value),
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(color: _textMedium, fontSize: 10),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF3F4F6),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Text(
              _t(row.statusLabel),
              style: pw.TextStyle(
                color: statusColor,
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<pw.Widget> _buildTracking(HealthReportData data) {
    if (data.tracking.isEmpty) {
      return [_emptyNote('No health tracking data for this period.')];
    }
    return [
      for (final section in data.tracking) _trackingCard(section),
    ];
  }

  pw.Widget _trackingCard(TrackingSection section) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFFFFF),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _borderGrey, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _t(section.title),
                style: pw.TextStyle(
                  color: _textDark,
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                _t(section.summary),
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  color: _brandPurple,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          if (section.details.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            for (final detail in section.details)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 1),
                child: pw.Text(
                  _t(detail),
                  style: pw.TextStyle(color: _textMedium, fontSize: 9.5),
                ),
              ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildCycle(HealthReportData data) {
    final cycle = data.cycle;
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFFFFF),
        borderRadius: pw.BorderRadius.circular(12),
        border: pw.Border.all(color: _borderGrey, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _cycleRow(
            'Current phase',
            cycle.currentPhaseLabel,
            'Day ${cycle.currentDayOfCycle} of cycle',
          ),
          _cycleRow(
            'Average cycle length',
            '${cycle.averageCycleLength} days',
            'Average period: ${cycle.averagePeriodDuration} days',
          ),
          if (cycle.lastPeriodStartDate != null)
            _cycleRow(
              'Last period start',
              cycle.lastPeriodStartDate!.friendly,
              'Cycle #${cycle.cycleNumber}',
            ),
          if (cycle.predictedNextPeriod != null)
            _cycleRow(
              'Next period (predicted)',
              cycle.predictedNextPeriod!.friendly,
              cycle.daysUntilNextPeriod != null
                  ? 'In about ${cycle.daysUntilNextPeriod! < 0 ? 0 : cycle.daysUntilNextPeriod} days'
                  : '',
            ),
          if (cycle.estimatedOvulation != null)
            _cycleRow(
              'Estimated ovulation',
              cycle.estimatedOvulation!.friendly,
              'Estimate based on your cycle history',
            ),
          if (cycle.fertileWindowStart != null &&
              cycle.fertileWindowEnd != null)
            _cycleRow(
              'Estimated fertile window',
              '${cycle.fertileWindowStart!.friendly} - ${cycle.fertileWindowEnd!.friendly}',
              'Estimated window around ovulation',
            ),
          pw.Divider(color: _borderGrey, height: 16),
          pw.Text(
            'PERIOD HISTORY (this period)',
            style: pw.TextStyle(
              color: _textLight,
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          pw.SizedBox(height: 5),
          if (cycle.periodHistoryLines.isEmpty)
            pw.Text(
              'No periods logged in this period.',
              style: pw.TextStyle(color: _textMedium, fontSize: 9.5),
            )
          else
            for (final line in cycle.periodHistoryLines)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 2),
                child: pw.Text(
                  _t(line),
                  style: pw.TextStyle(color: _textDark, fontSize: 9.5),
                ),
              ),
          pw.SizedBox(height: 8),
          pw.Text(
            'Ovulation, fertile window and next-period dates are estimates '
            'derived from your logged cycle history. They are predictions, '
            'not guaranteed biological dates.',
            style: pw.TextStyle(color: _textLight, fontSize: 8.5),
          ),
        ],
      ),
    );
  }

  pw.Widget _cycleRow(String label, String value, [String? note]) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              label,
              style: pw.TextStyle(color: _textMedium, fontSize: 9.5),
            ),
          ),
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                color: _textDark,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          if (note != null && note.isNotEmpty) ...[
            pw.SizedBox(width: 6),
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                note,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(color: _textLight, fontSize: 8.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _buildAssessments(HealthReportData data) {
    if (data.assessments.isEmpty) {
      return _emptyNote('No symptom assessments completed yet.');
    }
    return pw.Column(
      children: [
        for (final assessment in data.assessments)
          pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 8),
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFFFFFFF),
              borderRadius: pw.BorderRadius.circular(10),
              border: pw.Border.all(color: _borderGrey, width: 1),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        _t(assessment.title),
                        style: pw.TextStyle(
                          color: _textDark,
                          fontSize: 10.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        _t(assessment.completedLabel),
                        style: pw.TextStyle(color: _textLight, fontSize: 8.5),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      assessment.scoreLabel,
                      style: pw.TextStyle(
                        color: _brandPurple,
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      assessment.levelLabel,
                      style: pw.TextStyle(color: _textMedium, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<pw.Widget> _buildInsights(HealthReportData data) {
    if (data.insights.isEmpty) {
      return [_emptyNote('No AI insights available for this period.')];
    }
    return [
      for (final insight in data.insights)
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 10),
          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFFFFFFF),
            borderRadius: pw.BorderRadius.circular(10),
            border: pw.Border.all(color: _borderGrey, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    _t('${insight.kindLabel} · ${insight.categoryLabel}'),
                    style: pw.TextStyle(
                      color: _brandPurple,
                      fontSize: 8.5,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  pw.Text(
                    _t(insight.periodLabel),
                    style: pw.TextStyle(color: _textLight, fontSize: 8.5),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _t(insight.title),
                style: pw.TextStyle(
                  color: _textDark,
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                _t(insight.summary),
                style: pw.TextStyle(
                  color: _textMedium,
                  fontSize: 9.5,
                  height: 1.35,
                ),
              ),
              if (insight.detail != null && insight.detail!.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  _t(insight.detail!),
                  style: pw.TextStyle(
                    color: _textMedium,
                    fontSize: 9,
                    height: 1.35,
                  ),
                ),
              ],
              pw.SizedBox(height: 3),
              pw.Text(
                _t(insight.basisLabel),
                style: pw.TextStyle(color: _textLight, fontSize: 8.5),
              ),
            ],
          ),
        ),
    ];
  }

  pw.Widget _buildSummary(HealthReportData data) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _tintPurple,
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _t(data.summaryNote),
            style: pw.TextStyle(
              color: _textDark,
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'SYNCO - Your health, understood.',
            style: pw.TextStyle(
              color: _brandPurple,
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _emptyNote(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFAF8F5),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: _borderGrey, width: 1),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(color: _textMedium, fontSize: 10),
      ),
    );
  }
}

extension on DateTime {
  /// Formats a date like `12 Aug 2026` for PDF display.
  String get friendly {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '$day ${months[month - 1]} $year';
  }
}

extension on HealthReportData {
  /// "Generated on 16 Aug 2026, 10:30 AM" style label.
  String get generatedAtLabel {
    String two(int n) => n.toString().padLeft(2, '0');
    final t = generatedAt;
    final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '${t.day} ${_months[t.month - 1]} ${t.year}, '
        '${two(h12)}:${two(t.minute)} $ampm';
  }
}

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];
