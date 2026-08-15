import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/backend.dart';

final patientSummaryProvider = FutureProvider.family<Map<String, dynamic>?, ({String userId, String appointmentId})>((ref, args) async {
  if (Backend.firestore == null) return null;
  final doc = await Backend.firestore!
      .collection('users')
      .doc(args.userId)
      .collection('health_summaries')
      .doc(args.appointmentId)
      .get();
  
  if (doc.exists) {
    return doc.data();
  }
  return null;
});

class PatientDetailScreen extends ConsumerWidget {
  final String userId;
  final String appointmentId;
  final String patientName;

  const PatientDetailScreen({
    super.key,
    required this.userId,
    required this.appointmentId,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(patientSummaryProvider((userId: userId, appointmentId: appointmentId)));

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          '$patientName - Health Summary',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softPurple)),
        error: (err, stack) => Center(child: Text('Error loading summary: $err')),
        data: (data) {
          if (data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined, size: 48, color: AppColors.textLight),
                  const SizedBox(height: 16),
                  Text(
                    'No AI Health Summary available.',
                    style: GoogleFonts.inter(color: AppColors.textMedium),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDisclaimer(),
              const SizedBox(height: 24),
              _buildSummaryContent(data),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softLavender.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.softPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This summary is AI-generated for contextual reference based on patient logs and does not constitute a definitive medical diagnosis.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryContent(Map<String, dynamic> data) {
    // Assuming the JSON has standard fields like 'symptoms', 'recentHistory', 'concerns'
    // If it's just raw JSON, we can iterate through the keys
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatKey(entry.key),
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Text(
                  _formatValue(entry.key, entry.value),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMedium,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatKey(String key) {
    // simple camelCase to Title Case
    final text = key.replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ');
    return text.isNotEmpty ? '${text[0].toUpperCase()}${text.substring(1)}' : text;
  }

  String _formatValue(String key, dynamic value) {
    final lowerKey = key.toLowerCase();
    if (lowerKey.contains('at') || lowerKey.contains('time') || lowerKey.contains('date')) {
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return DateFormat('MMM d, yyyy, h:mm a').format(parsed);
        }
      } else if (value != null && value.runtimeType.toString() == 'Timestamp') {
        // Handle Firestore Timestamp if applicable without direct dependency if possible, or assume string
        try {
          final date = (value as dynamic).toDate();
          return DateFormat('MMM d, yyyy, h:mm a').format(date);
        } catch (_) {}
      }
    }
    return value.toString();
  }
}
