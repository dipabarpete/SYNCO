import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/screens/consultation_chat_screen.dart';
import '../providers/doctor_provider.dart';
import '../screens/patient_detail_screen.dart';

/// Appointment card used across the Doctor Portal.
///
/// Matches the original consultant card visual language and exposes the same
/// actions (AI summary, decline/accept, message patient, complete) through
/// the existing [DoctorDashboardController].
class DoctorAppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final bool showActions;
  final bool showEnterChat;
  final bool showComplete;

  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    this.showActions = false,
    this.showEnterChat = false,
    this.showComplete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = appointment;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.babyPink,
                child: Text(
                  a.patientName.isNotEmpty
                      ? a.patientName.substring(0, 1).toUpperCase()
                      : 'P',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${a.formattedDateShort} • ${a.slot}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMedium,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  a.modeName,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PatientDetailScreen(
                          userId: a.userId,
                          appointmentId: a.id,
                          patientName: a.patientName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                  label: const Text('View AI Summary'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.softPurple,
                    side: const BorderSide(color: AppColors.softPurple),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (showActions) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(doctorDashboardControllerProvider)
                          .updateStatus(a.id, 'declined');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.babyPink,
                      foregroundColor: AppColors.deepRose,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(doctorDashboardControllerProvider)
                          .updateStatus(a.id, 'confirmed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B76),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
          if (showEnterChat) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConsultationChatScreen(
                        chatId: a.id,
                        patientName: a.patientName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                label: const Text('Message Patient'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
          if (showComplete) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(doctorDashboardControllerProvider)
                      .updateStatus(a.id, 'completed');
                },
                icon: const Icon(Icons.done_all_rounded, size: 16),
                label: const Text('Mark Consultation Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B76),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
