import 'package:cloud_firestore/cloud_firestore.dart';

/// A single patient review for a doctor.
///
/// Reviews live under `doctors/{doctorId}/reviews/{consultationId}` so that
/// the document ID itself guarantees at most one review per consultation.
///
/// Privacy: only the reviewer's display name ([reviewerName]) is stored and
/// shown. Phone numbers, emails and medical details are never part of a
/// review document.
class DoctorReview {
  /// Document ID, which is always the consultation (booking) ID.
  final String id;

  final String doctorId;
  final String userId;

  /// The completed consultation this review belongs to.
  final String consultationId;

  /// Star rating between 1 and 5.
  final int rating;

  /// Written feedback (may be empty).
  final String text;

  /// Public display name of the reviewer. Empty means "Anonymous".
  final String reviewerName;

  final DateTime createdAt;

  const DoctorReview({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.consultationId,
    required this.rating,
    required this.text,
    required this.reviewerName,
    required this.createdAt,
  });

  factory DoctorReview.fromFirestore(dynamic doc) {
    return DoctorReview.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  factory DoctorReview.fromMap(String id, Map<String, dynamic> data) {
    return DoctorReview(
      id: id,
      doctorId: data['doctorId']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      consultationId: data['consultationId']?.toString() ?? '',
      rating: (data['rating'] is num)
          ? (data['rating'] as num).toInt().clamp(1, 5)
          : 0,
      text: data['text']?.toString() ?? '',
      reviewerName: data['reviewerName']?.toString() ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'userId': userId,
      'consultationId': consultationId,
      'rating': rating,
      'text': text,
      'reviewerName': reviewerName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Public label used under a review, e.g. "— Anonymous".
  String get reviewerLabel =>
      reviewerName.trim().isEmpty ? 'Anonymous' : reviewerName.trim();

  /// Relative human date such as "2 days ago" or "1 week ago".
  String get relativeTime {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m minute${m == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '$h hour${h == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return '$d day${d == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      return '$w week${w == 1 ? '' : 's'} ago';
    }
    if (diff.inDays < 365) {
      final mo = (diff.inDays / 30).floor();
      return '$mo month${mo == 1 ? '' : 's'} ago';
    }
    final y = (diff.inDays / 365).floor();
    return '$y year${y == 1 ? '' : 's'} ago';
  }

  /// Overall rating statistics derived from the actual submitted reviews.
  ///
  /// Returns `null` for [average] when there are no reviews, so callers never
  /// display a fake/hard-coded rating.
  static ({double? average, int count}) computeStats(
    List<DoctorReview> reviews,
  ) {
    if (reviews.isEmpty) return (average: null, count: 0);
    final sum = reviews.fold<int>(0, (acc, r) => acc + r.rating);
    final avg = double.parse((sum / reviews.length).toStringAsFixed(1));
    return (average: avg, count: reviews.length);
  }
}