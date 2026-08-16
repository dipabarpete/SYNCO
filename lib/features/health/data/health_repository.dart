// Cleaned up imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
import '../models/health_entries.dart';
import 'local_health_data_repository.dart';

/// Read/write access for all health tracker entries using unified daily documents.
///
/// Every entry is stored inside `users/{uid}/daily_logs/{YYYY-MM-DD}` under its
/// specific type collection map to heavily reduce Firebase Spark plan write costs.
class HealthRepository implements HealthDataRepository {
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

  @override
  Future<List<Map<String, dynamic>>> fetch(HealthTrackerType type) async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    try {
      final snapshot = await collection.orderBy('date', descending: true).get();
      final List<Map<String, dynamic>> allEntries = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey(type.collection)) {
          final typeMap = data[type.collection] as Map<String, dynamic>;
          for (final entry in typeMap.entries) {
            final id = entry.key;
            final payload = entry.value as Map<String, dynamic>;
            final compositeId = '${doc.id}|$id';
            allEntries.add(<String, dynamic>{'id': compositeId, ...payload});
          }
        }
      }

      // Re-sort in case multiple entries on the same day are out of order
      allEntries.sort((a, b) {
        final aTime = a['created_at'] as String? ?? a['date'] as String? ?? '';
        final bTime = b['created_at'] as String? ?? b['date'] as String? ?? '';
        return bTime.compareTo(aTime);
      });

      return allEntries;
    } catch (e) {
      _logError(type, 'fetch', e);
      rethrow;
    }
  }

  String _getDateId(Map<String, dynamic> payload) {
    final dateStr = payload['date'] as String?;
    if (dateStr != null && dateStr.isNotEmpty) return dateStr.substring(0, 10);
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<Map<String, dynamic>> create(
    HealthTrackerType type,
    Map<String, dynamic> payload,
  ) async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    try {
      final dateId = _getDateId(payload);
      final uniqueId = FirebaseFirestore.instance.collection('tmp').doc().id;
      
      await collection.doc(dateId).set({
        'date': dateId,
        type.collection: {
          uniqueId: payload,
        }
      }, SetOptions(merge: true));

      final compositeId = '$dateId|$uniqueId';
      return <String, dynamic>{'id': compositeId, ...payload};
    } catch (e) {
      _logError(type, 'create', e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> update(
    HealthTrackerType type,
    String id,
    Map<String, dynamic> payload,
  ) async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    try {
      final parts = id.split('|');
      if (parts.length != 2) throw FormatException('Invalid composite ID: $id');
      final dateId = parts[0];
      final uniqueId = parts[1];

      await collection.doc(dateId).update({
        '${type.collection}.$uniqueId': payload,
      });

      return <String, dynamic>{'id': id, ...payload};
    } catch (e) {
      _logError(type, 'update', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(HealthTrackerType type, String id) async {
    final collection = _dailyLogsCollection;
    if (collection == null) _notSignedIn();

    try {
      final parts = id.split('|');
      if (parts.length != 2) return; // Silent ignore invalid IDs
      final dateId = parts[0];
      final uniqueId = parts[1];

      await collection.doc(dateId).update({
        '${type.collection}.$uniqueId': FieldValue.delete(),
      });
    } catch (e) {
      _logError(type, 'delete', e);
      rethrow;
    }
  }

  void _logError(HealthTrackerType type, String operation, Object error) {
    debugPrint('[health] daily_logs.$operation FAILED: type=${error.runtimeType}');
    if (error is FirebaseException) {
      debugPrint('[health] FirebaseException: code=${error.code} message=${error.message}');
    } else {
      debugPrint('[health] captured error: $error');
    }
  }
}