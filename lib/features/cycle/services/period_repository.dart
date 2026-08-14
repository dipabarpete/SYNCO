import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
import '../../../models/period_record.dart';

void logFirebaseError(String operation, Object error) {
  debugPrint('[period_logs] $operation FAILED: type=${error.runtimeType}');
  if (error is fb.FirebaseAuthException) {
    debugPrint('[period_logs] FirebaseAuthException: code=${error.code} message=${error.message}');
  } else if (error is FirebaseException) {
    debugPrint('[period_logs] FirebaseException: code=${error.code}');
    debugPrint('[period_logs]   message: ${error.message}');
  } else {
    debugPrint('[period_logs] captured error: $error');
  }
}

class PeriodRepository {
  CollectionReference<Map<String, dynamic>>? get _periodLogsCollection {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('period_logs');
  }

  Future<List<PeriodRecord>> getPeriods() async {
    final collection = _periodLogsCollection;
    if (collection == null) {
      if (Backend.firestore == null) {
        throw StateError('Firebase client is not initialized.');
      }
      throw StateError('You are not signed in. Please sign in and try again.');
    }

    try {
      final snapshot = await collection.orderBy('start_date', descending: true).get();
      return snapshot.docs.map((doc) => PeriodRecord.fromMap({
        'id': doc.id,
        ...doc.data(),
      })).toList();
    } catch (e) {
      logFirebaseError('getPeriods', e);
      rethrow;
    }
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<PeriodRecord> createPeriod({
    required DateTime startDate,
    DateTime? endDate,
    String? flowLevel,
    int? painLevel,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    final authUser = fb.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      if (Backend.firestore == null) {
        throw StateError('Firebase client is not initialized.');
      }
      throw StateError('You are not signed in. Please sign in and try again.');
    }

    final now = DateTime.now();
    final payload = <String, dynamic>{
      'user_id': authUser.uid,
      'start_date': _formatDate(startDate),
      'end_date': endDate != null ? _formatDate(endDate) : null,
      'flow_level': flowLevel,
      'pain_level': painLevel,
      'mood': mood,
      'symptoms': symptoms ?? const [],
      'notes': notes,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    try {
      final docRef = await _periodLogsCollection!.add(payload);
      return PeriodRecord.fromMap({
        'id': docRef.id,
        ...payload,
      });
    } catch (e) {
      logFirebaseError('createPeriod', e);
      rethrow;
    }
  }

  Future<PeriodRecord> updatePeriod(
    String id, {
    required DateTime startDate,
    DateTime? endDate,
    String? flowLevel,
    int? painLevel,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    final authUser = fb.FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      if (Backend.firestore == null) {
        throw StateError('Firebase client is not initialized.');
      }
      throw StateError('You are not signed in. Please sign in and try again.');
    }

    try {
      final docRef = _periodLogsCollection!.doc(id);
      await docRef.update({
        'start_date': _formatDate(startDate),
        'end_date': endDate != null ? _formatDate(endDate) : null,
        'flow_level': flowLevel,
        'pain_level': painLevel,
        'mood': mood,
        'symptoms': symptoms ?? const [],
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      });
      final updatedDoc = await docRef.get();
      return PeriodRecord.fromMap({
        'id': id,
        ...updatedDoc.data() ?? const <String, dynamic>{},
      });
    } catch (e) {
      logFirebaseError('updatePeriod', e);
      rethrow;
    }
  }

  Future<void> deletePeriod(String id) async {
    final collection = _periodLogsCollection;
    if (collection == null) {
      if (Backend.firestore == null) {
        throw StateError('Firebase client is not initialized.');
      }
      throw StateError('You are not signed in. Please sign in and try again.');
    }
    try {
      await collection.doc(id).delete();
    } catch (e) {
      logFirebaseError('deletePeriod', e);
      rethrow;
    }
  }
}