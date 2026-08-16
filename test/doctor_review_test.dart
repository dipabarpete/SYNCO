import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hersync/features/doctor/models/doctor_review.dart';

DoctorReview review({
  required String id,
  required int rating,
  String text = '',
  String reviewerName = '',
  DateTime? createdAt,
}) {
  return DoctorReview(
    id: id,
    doctorId: 'doc_1',
    userId: 'usr_1',
    consultationId: id,
    rating: rating,
    text: text,
    reviewerName: reviewerName,
    createdAt: createdAt ?? DateTime.now(),
  );
}

void main() {
  group('DoctorReview.computeStats', () {
    test('returns no average for an empty list', () {
      final stats = DoctorReview.computeStats(const []);
      expect(stats.count, 0);
      expect(stats.average, isNull);
    });

    test('computes the average from actual reviews', () {
      final stats = DoctorReview.computeStats([
        review(id: 'b1', rating: 5),
        review(id: 'b2', rating: 5),
        review(id: 'b3', rating: 4),
        review(id: 'b4', rating: 5),
        review(id: 'b5', rating: 4),
      ]);
      expect(stats.count, 5);
      expect(stats.average, 4.6);
    });

    test('a single review equals its rating', () {
      final stats = DoctorReview.computeStats([review(id: 'b1', rating: 2)]);
      expect(stats.count, 1);
      expect(stats.average, 2.0);
    });

    test('handles repeated submissions without changing the average', () {
      final stats = DoctorReview.computeStats([
        review(id: 'b1', rating: 5),
        review(id: 'b2', rating: 5),
        review(id: 'b3', rating: 4),
      ]);
      expect(stats.count, 3);
      expect(stats.average, 4.7);
    });
  });

  group('DoctorReview.display', () {
    test('empty reviewerName is labelled Anonymous', () {
      expect(review(id: 'b1', rating: 5).reviewerLabel, 'Anonymous');
    });

    test('display name is used when present', () {
      expect(
        review(id: 'b1', rating: 5, reviewerName: 'Sonali').reviewerLabel,
        'Sonali',
      );
    });

    test('whitespace-only name is labelled Anonymous', () {
      expect(review(id: 'b1', rating: 5, reviewerName: '   ').reviewerLabel,
          'Anonymous');
    });
  });

  group('DoctorReview.relativeTime', () {
    test('just now for fresh reviews', () {
      final r = review(
        id: 'b1',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(seconds: 30)),
      );
      expect(r.relativeTime, 'Just now');
    });

    test('minutes ago', () {
      final r = review(
        id: 'b1',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
      );
      expect(r.relativeTime, '12 minutes ago');
    });

    test('days ago', () {
      final r = review(
        id: 'b1',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(r.relativeTime, '2 days ago');
    });

    test('weeks ago', () {
      final r = review(
        id: 'b1',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
      );
      expect(r.relativeTime, '1 week ago');
    });

    test('months ago', () {
      final r = review(
        id: 'b1',
        rating: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 70)),
      );
      expect(r.relativeTime, '2 months ago');
    });
  });

  group('DoctorReview.fromMap', () {
    test('parses a review document', () {
      final r = DoctorReview.fromMap('b1', {
        'doctorId': 'doc_1',
        'userId': 'usr_1',
        'consultationId': 'b1',
        'rating': 4,
        'text': 'Great consultation',
        'reviewerName': 'Sonali',
        'createdAt': Timestamp.fromDate(DateTime(2026, 8, 10)),
      });
      expect(r.rating, 4);
      expect(r.text, 'Great consultation');
      expect(r.reviewerName, 'Sonali');
      expect(r.consultationId, 'b1');
      expect(r.createdAt, DateTime(2026, 8, 10));
    });

    test('clamps out-of-range ratings', () {
      expect(
        DoctorReview.fromMap('b1', {'rating': 99}).rating,
        5,
      );
      expect(
        DoctorReview.fromMap('b1', {'rating': -3}).rating,
        1,
      );
    });
  });
}