import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/appointment.dart';

/// Lets a user rate and review a doctor after a completed consultation.
///
/// Available only from a completed appointment; the rating (1–5) is required,
/// while the written feedback is optional.
class ReviewDoctorScreen extends ConsumerStatefulWidget {
  final Appointment appointment;

  const ReviewDoctorScreen({super.key, required this.appointment});

  @override
  ConsumerState<ReviewDoctorScreen> createState() => _ReviewDoctorScreenState();
}

class _ReviewDoctorScreenState extends ConsumerState<ReviewDoctorScreen> {
  final TextEditingController _textController = TextEditingController();
  int _rating = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5) {
      _showMessage('Please select a rating to continue.');
      return;
    }

    final auth = ref.read(authNotifierProvider);
    final profileName = auth.userProfile?.username ?? '';
    final fallbackName = auth.user?.displayName ?? '';
    final reviewerName =
        (profileName.isNotEmpty ? profileName : fallbackName).trim();
    final userId = auth.user?.id ?? auth.userProfile?.id;
    if (userId == null || userId.isEmpty) {
      _showMessage('Please sign in to submit a review.');
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(doctorServiceProvider).submitDoctorReview(
            doctorId: widget.appointment.doctor.id,
            consultationId: widget.appointment.id,
            userId: userId,
            rating: _rating,
            text: _textController.text.trim(),
            reviewerName: reviewerName,
          );

      if (!mounted) return;

      // Refresh every screen that depends on reviews/rating.
      ref.invalidate(
        doctorReviewForConsultationProvider(
          (
            doctorId: widget.appointment.doctor.id,
            consultationId: widget.appointment.id,
          ),
        ),
      );
      ref.invalidate(doctorReviewsProvider(widget.appointment.doctor.id));
      ref.invalidate(doctorsProvider);

      Navigator.pop(context);
      _showMessage('Review submitted. Thank you for your feedback!');
    } on ArgumentError catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (e) {
      debugPrint('[ReviewDoctor] Failed to submit review: $e');
      if (mounted) _showMessage('Could not submit the review. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.softPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamWhite,
      appBar: AppBar(
        title: Text(
          'Rate & Review Doctor',
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDoctorCard(),
              const SizedBox(height: 18),
              _buildRatingSection(),
              const SizedBox(height: 20),
              _buildTextSection(),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
          child: GestureDetector(
            onTap: _submitting ? null : _submit,
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
              child: _submitting
                  ? const Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.4,
                        ),
                      ),
                    )
                  : Text(
                      'Submit Review',
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
      ),
    );
  }

  Widget _buildDoctorCard() {
    final doctor = widget.appointment.doctor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: CircleAvatar(
              radius: 24,
              backgroundColor: doctor.avatarBackground,
              child: Text(
                doctor.initials,
                style: GoogleFonts.outfit(
                  fontSize: 15,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${doctor.specialization} \u2022 ${widget.appointment.formattedDateShort}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF7BE0BE),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Completed',
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
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

  Widget _buildRatingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
        children: [
          Text(
            'Rate your experience',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = starIndex <= _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = starIndex),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 42,
                    color: isFilled
                        ? const Color(0xFFFFD700)
                        : AppColors.borderGrey,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _rating == 0
                ? 'Tap a star to rate'
                : _rating == 5
                    ? 'Excellent \u2014 thank you!'
                    : _rating == 4
                        ? 'Good'
                        : _rating == 3
                            ? 'Average'
                            : _rating == 2
                                ? 'Poor'
                                : 'Very Poor',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _rating == 0 ? AppColors.textLight : AppColors.softPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share your experience',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderGrey.withValues(alpha: 0.6),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'How was your consultation experience?',
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textLight,
              ),
              counterStyle: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textLight,
              ),
            ),
            style: GoogleFonts.inter(
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}