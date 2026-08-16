import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
import '../../../models/period_day_log.dart';
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
  CollectionReference<Map<String, dynamic>>? get _dailyLogsCollection {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('daily_logs');
  }

  Never _notSignedIn() {
    if (Backend.firestore == null) {
      throw StateError('Firebase client is not initialized.');
    }
    throw StateError('You are not signed in. Please sign in and try again.');
  }

  Future<List<PeriodRecord>> getPeriods() async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    try {
      final snapshot = await collection.orderBy('date', descending: true).get();
      final List<PeriodRecord> records = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('period_logs')) {
          final periodMap = data['period_logs'] as Map<String, dynamic>;
          for (final entry in periodMap.entries) {
            final id = entry.key;
            final payload = entry.value as Map<String, dynamic>;
            final compositeId = '${doc.id}|$id';
            records.add(PeriodRecord.fromMap({
              'id': compositeId,
              ...payload,
            }));
          }
        }
      }

      records.sort((a, b) => b.startDate.compareTo(a.startDate));
      return records;
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
    List<String>? moods,
    List<String>? symptoms,
    String? discharge,
    List<String>? digestion,
    List<String>? otherFactors,
    Map<String, PeriodDayLog>? dailyLogs,
    String? notes,
  }) async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    final now = DateTime.now();
    final authUser = fb.FirebaseAuth.instance.currentUser!;
    final dateId = _formatDate(startDate);
    
    final payload = <String, dynamic>{
      'user_id': authUser.uid,
      'start_date': dateId,
      'end_date': endDate != null ? _formatDate(endDate) : null,
      'flow_level': flowLevel,
      'pain_level': painLevel,
      'moods': moods ?? const [],
      'symptoms': symptoms ?? const [],
      'discharge': discharge,
      'digestion': digestion ?? const [],
      'other_factors': otherFactors ?? const [],
      'daily_logs': _encodeDailyLogs(dailyLogs),
      'notes': notes,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    try {
      final uniqueId = FirebaseFirestore.instance.collection('tmp').doc().id;
      
      await collection.doc(dateId).set({
        'date': dateId,
        'period_logs': {
          uniqueId: payload,
        }
      }, SetOptions(merge: true));

      return PeriodRecord.fromMap({
        'id': '$dateId|$uniqueId',
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
    List<String>? moods,
    List<String>? symptoms,
    String? discharge,
    List<String>? digestion,
    List<String>? otherFactors,
    Map<String, PeriodDayLog>? dailyLogs,
    String? notes,
  }) async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    try {
      final parts = id.split('|');
      if (parts.length != 2) throw FormatException('Invalid composite ID: $id');
      final dateId = parts[0];
      final uniqueId = parts[1];

      final payload = {
        'start_date': _formatDate(startDate),
        'end_date': endDate != null ? _formatDate(endDate) : null,
        'flow_level': flowLevel,
        'pain_level': painLevel,
        'moods': moods ?? const [],
        'symptoms': symptoms ?? const [],
        'discharge': discharge,
        'digestion': digestion ?? const [],
        'other_factors': otherFactors ?? const [],
        'daily_logs': _encodeDailyLogs(dailyLogs),
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await collection.doc(dateId).update({
        'period_logs.$uniqueId.start_date': payload['start_date'],
        'period_logs.$uniqueId.end_date': payload['end_date'],
        'period_logs.$uniqueId.flow_level': payload['flow_level'],
        'period_logs.$uniqueId.pain_level': payload['pain_level'],
        'period_logs.$uniqueId.mood': payload['mood'],
        'period_logs.$uniqueId.symptoms': payload['symptoms'],
        'period_logs.$uniqueId.notes': payload['notes'],
        'period_logs.$uniqueId.updated_at': payload['updated_at'],
      });
      
      // Return a partially reconstructed record for simplicity, UI usually refetches
      return PeriodRecord.fromMap({
        'id': id,
        ...payload,
      });
    } catch (e) {
      logFirebaseError('updatePeriod', e);
      rethrow;
    }
  }

  Future<void> deletePeriod(String id) async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    try {
      final parts = id.split('|');
      if (parts.length != 2) return;
      final dateId = parts[0];
      final uniqueId = parts[1];

      await collection.doc(dateId).update({
        'period_logs.$uniqueId': FieldValue.delete(),
      });
    } catch (e) {
      logFirebaseError('deletePeriod', e);
      rethrow;
    }
  }

  Map<String, dynamic> _encodeDailyLogs(
    Map<String, PeriodDayLog>? dailyLogs,
  ) {
    if (dailyLogs == null || dailyLogs.isEmpty) return const {};
    return dailyLogs.map((key, log) => MapEntry(key, log.toMap()));
  }
}