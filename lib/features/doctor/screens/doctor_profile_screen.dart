import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../models/doctor.dart';
import '../models/doctor_review.dart';
import 'booking_screen.dart';
import 'consultation_chat_screen.dart';
import '../../auth/providers/auth_provider.dart';

class DoctorProfileScreen extends ConsumerWidget {
  final Doctor doctor;

  const DoctorProfileScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(doctorReviewsProvider(doctor.id));
    ({double? average, int count})? stats;
    List<DoctorReview>? reviews;
    reviewsAsync.maybeWhen(
      data: (value) {
        reviews = value;
        stats = DoctorReview.computeStats(value);
      },
      orElse: () {},
    );

    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'Doctor Profile',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroCard(stats: stats),
              const SizedBox(height: 16),
              _buildAboutCard(),
              const SizedBox(height: 16),
              _buildDetailsCard(),
              if (doctor.mode == ConsultationMode.offline &&
                  doctor.clinicLocation != null) ...[
                const SizedBox(height: 16),
                _buildClinicCard(),
              ],
              const SizedBox(height: 16),
              _buildReviewsCard(reviews: reviews, stats: stats),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    final user = ref.read(authNotifierProvider).userProfile;
                    final userId = user?.id ?? 'user_123';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultationChatScreen(
                          chatId: 'inquiry_${userId}_${doctor.id}',
                          patientName: doctor.name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.softLavender.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.softPurpleLight.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.softPurple,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(doctor: doctor),
                      ),
                    );
                  },
                  child: Container(
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
                      'Book Consultation',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 15,
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

  Widget _buildHeroCard({
    required ({double? average, int count})? stats,
  }) {
    final hasReviews = (stats?.count ?? 0) > 0 && stats!.average != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.softPurple, AppColors.softPurpleLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.softPurple.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: CircleAvatar(
              radius: 36,
              backgroundColor: doctor.avatarBackground,
              child: Text(
                doctor.initials,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.softPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            doctor.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            doctor.specialization,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeroPill(
                icon: hasReviews
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                iconColor: hasReviews ? const Color(0xFFFFD700) : Colors.white,
                label: hasReviews
                    ? '${stats.average!.toStringAsFixed(1)} '
                        '(${stats.count} review${stats.count == 1 ? '' : 's'})'
                    : 'No reviews yet',
              ),
              const SizedBox(width: 8),
              _buildHeroPill(
                icon: Icons.work_rounded,
                iconColor: Colors.white,
                label: doctor.experience,
              ),
              const SizedBox(width: 8),
              _buildHeroPill(
                icon: Icons.currency_rupee_rounded,
                iconColor: Colors.white,
                label: '${doctor.consultationFee}',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: doctor.availability.contains('Today')
                        ? const Color(0xFF7BE0BE)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  doctor.availability,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPill({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildAboutCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('About Doctor'),
          const SizedBox(height: 10),
          Text(
            doctor.about,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Consultation Details'),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDetailChip(
                icon: Icons.videocam_rounded,
                label: 'Online Available',
                active: doctor.mode == ConsultationMode.online,
              ),
              const SizedBox(width: 8),
              _buildDetailChip(
                icon: Icons.local_hospital_rounded,
                label: 'Clinic Visit',
                active: doctor.mode == ConsultationMode.offline,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.currency_rupee_rounded,
                size: 18,
                color: AppColors.softPurple,
              ),
              const SizedBox(width: 6),
              Text(
                '${doctor.consultationFee} per consultation',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Available Days',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.availableDays
                .map(
                  (day) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.softLavender.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.softPurple,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'Time Slots',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doctor.timeSlots
                .map(
                  (slot) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.babyPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      slot,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepRose,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? AppColors.softPurple.withValues(alpha: 0.1)
            : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: active
              ? AppColors.softPurpleLight.withValues(alpha: 0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: active ? AppColors.softPurple : AppColors.textLight,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.softPurple : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicCard() {
    return _buildCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.babyPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: AppColors.deepRose,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Clinic Location'),
                const SizedBox(height: 4),
                Text(
                  doctor.clinicLocation!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textMedium,
                  ),
                ),
                if (doctor.distanceKm != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${doctor.distanceKm} km away',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.softPurple,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Rating & Reviews section: overall rating computed from the actual
  /// submitted reviews, followed by the individual patient reviews.
  Widget _buildReviewsCard({
    List<DoctorReview>? reviews,
    required ({double? average, int count})? stats,
  }) {
    final hasReviews = (stats?.count ?? 0) > 0;

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Rating & Reviews'),
          const SizedBox(height: 12),
          if (reviews == null)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.softPurple,
                  strokeWidth: 2.4,
                ),
              ),
            )
          else if (!hasReviews) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.softLavender.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.rate_review_outlined,
                    size: 28,
                    color: AppColors.softPurple,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No reviews yet',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Reviews appear here after patients complete a consultation.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildRatingSummary(
              stats?.average ?? 0.0,
              stats?.count ?? 0,
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.borderGrey, height: 1),
            const SizedBox(height: 14),
            Text(
              'Patient Reviews',
              style: GoogleFonts.outfit(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            ...reviews.map((review) => _buildReviewTile(review)),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSummary(double average, int count) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              average.toStringAsFixed(1),
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: Color(0xFFFFD700),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    average.toStringAsFixed(1),
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '($count review${count == 1 ? '' : 's'})',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (index) {
                  final filled = (average - index).clamp(0.0, 1.0);
                  return Icon(
                    filled >= 0.75
                        ? Icons.star_rounded
                        : filled >= 0.25
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                    size: 16,
                    color: const Color(0xFFFFD700),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTile(DoctorReview review) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (index) {
                final filled = index < review.rating;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 15,
                  color: filled
                      ? const Color(0xFFFFD700)
                      : AppColors.borderGrey,
                );
              }),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '— ${review.reviewerLabel}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMedium,
                  ),
                ),
              ),
              Text(
                review.relativeTime,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          if (review.text.trim().isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(
              review.text.trim(),
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textDark,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
