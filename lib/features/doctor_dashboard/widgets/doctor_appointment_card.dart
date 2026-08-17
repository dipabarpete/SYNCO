import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/doctor.dart';
import '../../doctor/screens/consultation_chat_screen.dart';
import '../providers/doctor_provider.dart';
import '../screens/patient_health_summary_screen.dart';

/// Appointment card used across the Doctor Portal.
///
/// Matches the original consultant card visual language and exposes the same
/// actions (health summary, decline/accept, message patient, complete)
/// through the existing [DoctorDashboardController].
class DoctorAppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  final bool showActions;
  final bool showEnterChat;
  final bool showComplete;
  final bool showStatus;

  /// When true (and the appointment is confirmed with a real backend
  /// booking), the Confirmed tag becomes tappable and lets the doctor cancel
  /// the appointment through the existing appointment status update.
  final bool allowCancel;

  const DoctorAppointmentCard({
    super.key,
    required this.appointment,
    this.showActions = false,
    this.showEnterChat = false,
    this.showComplete = false,
    this.showStatus = false,
    this.allowCancel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = appointment;
    final isOnline = a.mode == ConsultationMode.online;

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
          // Patient identity row: avatar, full name with the mode and date
          // below it, and the status chip on the right of the name.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      // Full patient name - wraps gracefully instead of
                      // truncating on narrow screens.
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          isOnline
                              ? Icons.videocam_rounded
                              : Icons.location_on_outlined,
                          size: 14,
                          color: isOnline
                              ? AppColors.softPurple
                              : AppColors.pendingAmber,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isOnline
                                ? AppColors.softPurple
                                : AppColors.pendingAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.textLight,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${a.formattedDateShort} • ${a.slot}',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showStatus) ...[
                const SizedBox(width: 8),
                _StatusChip(
                  status: a.status,
                  onTap: allowCancel && a.status == AppointmentStatus.confirmed
                      ? () => _showCancelAppointmentSheet(context, ref)
                      : null,
                ),
              ],
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
                        builder: (context) => PatientHealthSummaryScreen(
                          userId: a.userId,
                          appointmentId: a.id,
                          patientName: a.patientName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                  label: const Text('View Health Summary'),
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

  /// Opens the small action sheet with the cancel option for this confirmed
  /// appointment. Cancellation still goes through the existing appointment
  /// service (same status update the rest of the portal uses).
  Future<void> _showCancelAppointmentSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final a = appointment;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.borderGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                a.patientName,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${a.formattedDateShort} • ${a.slot}',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.babyPink,
                  ),
                  child: const Icon(
                    Icons.event_busy_rounded,
                    size: 18,
                    color: AppColors.deepRose,
                  ),
                ),
                title: Text(
                  'Cancel Appointment',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepRose,
                  ),
                ),
                subtitle: Text(
                  'The patient will be notified.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, 'cancel'),
              ),
            ],
          ),
        ),
      ),
    );

    if (action == 'cancel' && context.mounted) {
      await _confirmCancellation(context, ref);
    }
  }

  /// Confirmation dialog shown before the appointment is actually cancelled.
  Future<void> _confirmCancellation(BuildContext context, WidgetRef ref) async {
    final a = appointment;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.babyPink,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: AppColors.deepRose,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cancel this appointment?',
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${a.patientName} • ${a.formattedDateShort} • ${a.slot}\n'
          'This appointment will no longer appear as confirmed.',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: AppColors.textMedium,
            height: 1.45,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Keep Appointment',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMedium,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepRose,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Cancel Appointment',
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!context.mounted) return;
      await _performCancellation(context, ref);
    }
  }

  /// Cancels the appointment through the existing backend status update and
  /// keeps the UI in sync (the appointment stream removes it automatically).
  Future<void> _performCancellation(BuildContext context, WidgetRef ref) async {
    final a = appointment;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(doctorDashboardControllerProvider)
          .updateStatus(a.id, 'cancelled');
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Appointment with ${a.patientName} cancelled.'),
          backgroundColor: AppColors.confirmedGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            "Couldn't cancel the appointment. Please try again.",
          ),
          backgroundColor: AppColors.deepRose,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Small status chip shown on the right side of the patient's name.
///
/// Follows the same colors as [DoctorStatusPill] and adds a check mark for
/// confirmed / completed appointments. For confirmed appointments with a
/// backend booking it is tappable ([onTap] != null) so the doctor can open
/// the cancel appointment action sheet.
class _StatusChip extends StatelessWidget {
  final AppointmentStatus status;
  final VoidCallback? onTap;

  const _StatusChip({required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      AppointmentStatus.requested => (
        AppColors.pendingAmberSoft,
        AppColors.pendingAmber,
        'Pending',
      ),
      AppointmentStatus.confirmed => (
        AppColors.mintGreen.withValues(alpha: 0.4),
        AppColors.confirmedGreen,
        'Confirmed',
      ),
      AppointmentStatus.declined => (
        AppColors.babyPink,
        AppColors.deepRose,
        'Declined',
      ),
      AppointmentStatus.cancelled => (
        AppColors.lightGrey,
        AppColors.textLight,
        'Cancelled',
      ),
      AppointmentStatus.completed => (
        AppColors.mintGreen.withValues(alpha: 0.4),
        AppColors.confirmedGreen,
        'Completed',
      ),
    };
    final showsCheck =
        status == AppointmentStatus.confirmed ||
        status == AppointmentStatus.completed;

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showsCheck) ...[
            Icon(Icons.check_rounded, size: 13, color: fg),
            const SizedBox(width: 3),
          ] else
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: fg),
            ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(message: 'Manage appointment', child: chip),
    );
  }
}
