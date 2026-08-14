import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/appointment.dart';
import 'my_appointments_screen.dart';

/// Shown immediately after the user taps "Book Appointment".
///
/// Communicates that a REQUEST has been sent and is pending doctor approval -
/// the appointment is NOT yet confirmed.
class RequestSentScreen extends StatelessWidget {
  final Appointment appointment;

  const RequestSentScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final doctor = appointment.doctor;

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Request Sent Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.pendingAmberSoft,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pendingAmber.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.schedule_send_rounded,
                  size: 42,
                  color: AppColors.pendingAmber,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Appointment Request Sent',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your consultation request has been sent to ${doctor.name}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 24),

              // Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.pureWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.borderGrey.withValues(alpha: 0.6),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.primaryGradient,
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: doctor.avatarBackground,
                            child: Text(
                              doctor.initials,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.softPurple,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                doctor.specialization,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  color: AppColors.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppColors.borderGrey, height: 1),
                    ),
                    _buildSummaryRow(
                      icon: Icons.videocam_rounded,
                      label: 'Consultation Type',
                      value: appointment.modeName,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: appointment.formattedDate,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      icon: Icons.schedule_rounded,
                      label: 'Time',
                      value: appointment.slot,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Consultation Fee',
                      value: '\u20B9${appointment.fee}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Pending Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.pendingAmberSoft,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.pendingAmber.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.pendingAmber,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Pending Doctor Approval',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pendingAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your appointment will be confirmed once the doctor accepts '
                'your request.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  height: 1.4,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 16),

              // Booking ID Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.softLavender.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Request ID: ${appointment.id}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.softPurple,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              GestureDetector(
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blushPink.withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Done',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MyAppointmentsScreen(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.softPurple,
                      width: 1.3,
                    ),
                  ),
                  child: Text(
                    'View My Appointments',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.softPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.babyPink,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: AppColors.deepRose),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            color: AppColors.textMedium,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
