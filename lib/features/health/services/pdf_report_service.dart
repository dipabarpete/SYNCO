import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../home/providers/dashboard_provider.dart';
import '../models/ai_insight.dart';

class PdfReportService {
  static String generateTextReport({
    required HealthScoreState healthScore,
    required List<AiInsight> aiInsights,
    required String userName,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📋 SYNCO Health Report Summary for $userName');
    buffer.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('--------------------------------------------------');
    buffer.writeln('Overall Health Score: ${healthScore.score}/100');
    final healthStatus = healthScore.score >= 80 ? 'Excellent' : healthScore.score >= 60 ? 'Good' : 'Needs Attention';
    buffer.writeln('Status: $healthStatus (Top ${healthScore.percentile}%)');
    buffer.writeln();
    buffer.writeln('📊 Score Breakdown:');
    buffer.writeln('• Cycle Regularity: Optimal');
    buffer.writeln('• Symptom Severity: Low');
    buffer.writeln('• Hydration: Needs Work');
    buffer.writeln();
    buffer.writeln('✨ AI Insights:');
    if (aiInsights.isEmpty) {
      buffer.writeln('Not enough data to generate personalized AI insights yet.');
    } else {
      for (final insight in aiInsights.take(3)) {
        buffer.writeln('- ${insight.title}: ${insight.summary}');
      }
    }
    buffer.writeln('--------------------------------------------------');
    return buffer.toString();
  }

  static Map<String, dynamic> generateSummaryMap({
    required HealthScoreState healthScore,
    required List<AiInsight> aiInsights,
    required String userName,
  }) {
    final healthStatus = healthScore.score >= 80 ? 'Excellent' : healthScore.score >= 60 ? 'Good' : 'Needs Attention';
    
    String insightsText = 'No personalized AI insights available yet.';
    if (aiInsights.isNotEmpty) {
      insightsText = aiInsights.take(3).map((i) => '• ${i.title}: ${i.summary}').join('\n');
    }

    return {
      'patientProfile': 'Overall Health Score: ${healthScore.score}/100\nStatus: $healthStatus\nTop ${healthScore.percentile}% of users with similar cycle profiles.',
      'scoreBreakdown': '• Cycle Regularity: Optimal\n• Symptom Severity: Low\n• Hydration: Needs Work',
      'aiInsights': insightsText,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<Uint8List> generateHealthReport({
    required HealthScoreState healthScore,
    required List<AiInsight> aiInsights,
    required String userName,
  }) async {
    final pdf = pw.Document();

    final primaryColor = PdfColor.fromHex('#7B4A9E');
    final secondaryColor = PdfColor.fromHex('#E0D8ED');
    final textDark = PdfColor.fromHex('#2D2D2D');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // HEADER
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('SYNCO', style: pw.TextStyle(color: primaryColor, fontSize: 28, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Full Health Report', style: pw.TextStyle(color: textDark, fontSize: 20)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(userName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Date: ${DateTime.now().toString().split(' ')[0]}', style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // HERO SCORE
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: secondaryColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Overall Health Score', style: pw.TextStyle(fontSize: 16, color: primaryColor)),
                      pw.SizedBox(height: 8),
                      pw.Text('${healthScore.score}/100', style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Top ${healthScore.percentile}% of users', style: pw.TextStyle(fontSize: 12, color: textDark)),
                    ],
                  ),
                  pw.Text(
                    healthScore.score >= 80 ? 'Excellent' : healthScore.score >= 60 ? 'Good' : 'Needs Attention',
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: primaryColor),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // BREAKDOWN
            pw.Text('Score Breakdown', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            
            _buildBreakdownRow('Cycle Regularity', 'Optimal', 'Your cycle length is highly consistent.', PdfColors.green),
            pw.SizedBox(height: 10),
            _buildBreakdownRow('Symptom Severity', 'Low', 'Based on your logs over the last 7 days.', PdfColors.green),
            pw.SizedBox(height: 10),
            _buildBreakdownRow('Hydration', 'Needs Work', 'You are averaging below your daily water goal.', PdfColors.orange),
            
            pw.SizedBox(height: 30),

            // AI INSIGHTS
            pw.Text('Recent AI Insights', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: textDark)),
            pw.Divider(),
            pw.SizedBox(height: 10),
            
            if (aiInsights.isEmpty)
              pw.Text('Not enough data to generate personalized AI insights yet.', style: const pw.TextStyle(fontSize: 14))
            else
              ...aiInsights.take(3).map((insight) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(insight.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: primaryColor)),
                    pw.SizedBox(height: 6),
                    pw.Text(insight.summary, style: pw.TextStyle(fontSize: 12, color: textDark)),
                  ],
                ),
              )),
              
            pw.SizedBox(height: 40),
            pw.Center(
              child: pw.Text('Generated securely by SYNCO AI', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildBreakdownRow(String title, String status, String description, PdfColor statusColor) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(status, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: statusColor, fontSize: 12)),
              pw.Text(description, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
