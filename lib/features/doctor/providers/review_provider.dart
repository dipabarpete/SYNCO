import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/doctor_review.dart';
import '../../auth/providers/auth_provider.dart';

final doctorReviewsProvider = StreamProvider.family<List<DoctorReview>, String>((ref, doctorId) {
  return FirebaseFirestore.instance
      .collection('doctors')
      .doc(doctorId)
      .collection('reviews')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => DoctorReview.fromMap(doc.id, doc.data())).toList());
});

final submitReviewProvider = StateNotifierProvider<SubmitReviewNotifier, AsyncValue<void>>((ref) {
  return SubmitReviewNotifier(ref);
});

class SubmitReviewNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  SubmitReviewNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> submitReview({
    required String doctorId,
    required String appointmentId,
    required int rating,
    required String comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authNotifierProvider).userProfile;
      if (user == null) {
        throw Exception("Must be logged in to submit a review.");
      }

      final batch = _db.batch();

      // 1. Create the new review document
      final reviewRef = _db.collection('doctors').doc(doctorId).collection('reviews').doc();
      final review = DoctorReview(
        id: reviewRef.id,
        doctorId: doctorId,
        patientId: user.id,
        patientName: user.username,
        appointmentId: appointmentId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      batch.set(reviewRef, review.toMap());

      // 2. Mark the appointment as reviewed
      final bookingRef = _db.collection('bookings').doc(appointmentId);
      batch.update(bookingRef, {'hasReviewed': true});

      // 3. Update the Doctor's aggregated average rating
      // We read the doctor document first to calculate the new average
      final doctorRef = _db.collection('doctors').doc(doctorId);
      
      // Note: We use a transaction instead of a batch for the aggregated score 
      // because we need to read the current rating and totalReviews safely.
      // So we will execute the transaction here.
      await _db.runTransaction((transaction) async {
        final doctorDoc = await transaction.get(doctorRef);
        if (!doctorDoc.exists) throw Exception("Doctor not found");

        final data = doctorDoc.data()!;
        final double currentRating = (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
        final int currentTotal = (data['totalReviews'] is num) ? (data['totalReviews'] as num).toInt() : 0;

        final newTotal = currentTotal + 1;
        // Running average formula: (oldAvg * oldCount + newRating) / newCount
        final newRating = ((currentRating * currentTotal) + rating) / newTotal;

        transaction.update(doctorRef, {
          'rating': newRating,
          'totalReviews': newTotal,
        });
        
        // Also apply our writes from the batch logic to the transaction to ensure atomicity
        transaction.set(reviewRef, review.toMap());
        transaction.update(bookingRef, {'hasReviewed': true});
      });

      state = const AsyncValue.data(null);
    } catch (e, st) {
      debugPrint('Error submitting review: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
