import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/doctor.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Doctor doctor;
  final ConsultationMode mode;
  final DateTime date;
  final String slot;
  final int fee;

  const BookingConfirmationScreen({
    super.key,
    required this.doctor,
    required this.mode,
    required this.date,
    required this.slot,
    required this.fee,
  });

  String get _formattedDate {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${weekdays[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String get _bookingId {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'SYN${timestamp % 1000000}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Success Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mintGreen.withValues(alpha: 0.4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF45B69C).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: Color(0xFF2E8B76),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Appointment Confirmed!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your consultation has been booked. '
                'The doctor has been notified.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textMedium,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Card
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
                      value: mode == ConsultationMode.online
                          ? 'Online'
                          : 'Offline',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Date',
                      value: _formattedDate,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      icon: Icons.schedule_rounded,
                      label: 'Time',
                      value: slot,
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Consultation Fee',
                      value: '\u20B9$fee',
                    ),
                  ],
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
                  'Booking ID: $_bookingId',
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
