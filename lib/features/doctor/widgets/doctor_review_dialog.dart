import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/review_provider.dart';
import '../models/doctor.dart';

class DoctorReviewDialog extends ConsumerStatefulWidget {
  final Doctor doctor;
  final String appointmentId;

  const DoctorReviewDialog({
    super.key,
    required this.doctor,
    required this.appointmentId,
  });

  static Future<void> show(BuildContext context, Doctor doctor, String appointmentId) {
    return showDialog(
      context: context,
      builder: (context) => DoctorReviewDialog(
        doctor: doctor,
        appointmentId: appointmentId,
      ),
    );
  }

  @override
  ConsumerState<DoctorReviewDialog> createState() => _DoctorReviewDialogState();
}

class _DoctorReviewDialogState extends ConsumerState<DoctorReviewDialog> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) return; // Disallow 0 rating

    final error = await ref.read(submitReviewProvider.notifier).submitReview(
          doctorId: widget.doctor.id,
          appointmentId: widget.appointmentId,
          rating: _rating,
          comment: _commentController.text.trim(),
        );

    if (mounted) {
      final state = ref.read(submitReviewProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${state.error}')),
        );
      } else {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your review!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitState = ref.watch(submitReviewProvider);
    final isLoading = submitState.isLoading;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.creamWhite,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rate your visit',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How was your consultation with Dr. ${widget.doctor.name}?',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: isLoading ? null : () => setState(() => _rating = index + 1),
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < _rating ? Colors.amber : Colors.grey.shade400,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              enabled: !isLoading,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_rating == 0 || isLoading) ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.softPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Submit Review',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
