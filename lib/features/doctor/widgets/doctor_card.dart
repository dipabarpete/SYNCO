import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../models/doctor.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  const DoctorCard({
    super.key,
    required this.doctor,
    this.onTap,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.borderGrey.withValues(alpha: 0.6),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor.specialization,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMedium,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Row(
                          children: [
                            if (doctor.reviewCount > 0) ...[
                              _buildRatingChip(),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              '${doctor.experience} exp',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\u20B9${doctor.consultationFee}',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.softPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'per consult',
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildAvailabilityPill(),
                  const SizedBox(width: 8),
                  _buildModePill(),
                ],
              ),
              if (doctor.mode == ConsultationMode.offline &&
                  doctor.clinicLocation != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: AppColors.rosePink,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        doctor.distanceKm != null
                            ? '${doctor.distanceKm} km \u2022 ${doctor.clinicLocation}'
                            : doctor.clinicLocation!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: onBookNow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softPurple,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.softPurple.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'Book Now',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildAvatar() {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: doctor.avatarBackground,
        child: Text(
          doctor.initials,
          style: GoogleFonts.outfit(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.softPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.babyPink,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 13,
            color: Color(0xFFFFB800),
          ),
          const SizedBox(width: 2),
          Text(
            doctor.rating.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityPill() {
    final isAvailableToday = doctor.availability.contains('Today');
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isAvailableToday
              ? AppColors.mintGreen.withValues(alpha: 0.35)
              : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAvailableToday
                    ? const Color(0xFF45B69C)
                    : AppColors.textLight,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                doctor.availability,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isAvailableToday
                      ? const Color(0xFF2E8B76)
                      : AppColors.textMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModePill() {
    final isOnline = doctor.mode == ConsultationMode.online;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.softLavender.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnline ? Icons.videocam_rounded : Icons.local_hospital_rounded,
            size: 12,
            color: AppColors.softPurple,
          ),
          const SizedBox(width: 4),
          Text(
            doctor.modeLabel,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.softPurple,
            ),
          ),
        ],
      ),
    );
  }
}
