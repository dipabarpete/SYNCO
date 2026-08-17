import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor/models/appointment.dart';
import '../../doctor/models/doctor.dart';

/// Section title used across the Doctor Portal screens.
class DoctorSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const DoctorSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ],
    );
  }
}

/// Friendly empty state used when a backend-driven section has no data.
class DoctorEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const DoctorEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey.withValues(alpha: 0.6)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.softLavender,
            ),
            child: Icon(icon, size: 26, color: AppColors.softPurple),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state with a retry option for backend-driven sections.
class DoctorErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DoctorErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.babyPink,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 28,
                color: AppColors.deepRose,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.textMedium,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Small colored pill that shows an appointment's consultation mode
/// (Online / Offline), driven by the appointment's [ConsultationMode].
class DoctorModePill extends StatelessWidget {
  final ConsultationMode mode;

  const DoctorModePill({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (mode) {
      ConsultationMode.online => (
          AppColors.softLavender.withValues(alpha: 0.5),
          AppColors.softPurple,
          'Online',
        ),
      ConsultationMode.offline => (
          AppColors.pendingAmberSoft,
          AppColors.pendingAmber,
          'Offline',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg,
            ),
          ),
          const SizedBox(width: 5),
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
  }
}

/// Small colored pill that shows an appointment status.
class DoctorStatusPill extends StatelessWidget {
  final AppointmentStatus status;

  const DoctorStatusPill({super.key, required this.status});

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fg,
            ),
          ),
          const SizedBox(width: 5),
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
  }
}
