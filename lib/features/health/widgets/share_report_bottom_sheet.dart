import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../doctor/services/chat_service.dart';
import '../services/pdf_report_service.dart';
import '../../home/providers/dashboard_provider.dart';
import '../../auth/providers/auth_provider.dart';

import '../models/ai_insight.dart';

class ShareReportBottomSheet extends ConsumerWidget {
  final HealthScoreState healthScore;
  final List<AiInsight> aiInsights;

  const ShareReportBottomSheet({
    super.key,
    required this.healthScore,
    required this.aiInsights,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAppointmentsAsync = ref.watch(patientActiveDoctorsProvider);
    final user = ref.watch(authNotifierProvider).user;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select Doctor',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          activeAppointmentsAsync.when(
            data: (appointments) {
              if (appointments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'You do not have any active appointments to share this report with.',
                    style: GoogleFonts.inter(color: AppColors.textMedium),
                  ),
                );
              }
              
              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final apt = appointments[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppColors.softPurple.withValues(alpha: 0.2),
                        child: Text(apt.doctor.name[0], style: const TextStyle(color: AppColors.softPurple)),
                      ),
                      title: Text(
                        apt.doctor.name,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
                      subtitle: Text(
                        apt.doctor.specialization,
                        style: GoogleFonts.inter(color: AppColors.textMedium, fontSize: 13),
                      ),
                      trailing: const Icon(Icons.send_rounded, color: AppColors.softPurple, size: 20),
                      onTap: () async {
                        Navigator.pop(context);
                        
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('You must be logged in to send reports.')),
                          );
                          return;
                        }

                        try {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sending report to Doctor Dashboard...')),
                          );

                          final textReport = PdfReportService.generateTextReport(
                            healthScore: healthScore,
                            aiInsights: aiInsights,
                            userName: user.displayName ?? user.email ?? 'SYNCO Patient',
                          );
                          
                          final summaryMap = PdfReportService.generateSummaryMap(
                            healthScore: healthScore,
                            aiInsights: aiInsights,
                            userName: user.displayName ?? user.email ?? 'SYNCO Patient',
                          );
                          
                          // 1. Overwrite the Appointment's AI Summary in the Dashboard
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id) // This is the patientId
                              .collection('health_summaries')
                              .doc(apt.id) // appointmentId
                              .set(summaryMap);
                          
                          // 2. Ensure Chat Room exists
                          await FirebaseFirestore.instance.collection('chats').doc(apt.id).set({
                            'patientId': user.id,
                            'doctorId': apt.doctor.id,
                            'lastMessageAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          // 3. Send Message to the Chat Room
                          await ChatService().sendMessage(apt.id, user.id, textReport);
                          
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Report synced with Doctor Dashboard successfully!'),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to sync report: $e')),
                          );
                        }
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.softPurple)),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Error loading appointments: $err'),
            ),
          ),
        ],
      ),
    );
  }
}
