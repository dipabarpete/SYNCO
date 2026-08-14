import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../models/health_entries.dart';

/// Read/write access for all health tracker entries.
///
/// Every collection is scoped to the signed-in user:
///
///  * Firebase: `users/{uid}/sleep_entries/...`, `.../water_entries/...` etc.
///  * Supabase fallback: `sleep_entries`, `water_entries`, ... tables,
///    protected by Row Level Security (`auth.uid() = user_id`).
///
/// All rows carry `user_id` so access checks are consistent across both
/// backends. The `date` field is stored as `yyyy-MM-dd` for range queries.
class HealthRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get _useFirebase => Backend.useFirebase;

  CollectionReference<Map<String, dynamic>>? _entriesCollection(
    HealthTrackerType type,
  ) {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection(type.collection);
  }

  /// Throws [StateError] to surface in the UI when the user is signed out or
  /// the backend is unavailable.
  Never _notSignedIn() {
    if (Backend.firestore == null) {
      throw StateError('Firebase client is not initialized.');
    }
    throw StateError('You are not signed in. Please sign in and try again.');
  }

  /// Fetches entries for [type], newest date first. A `from`/`to` range can
  /// be passed to limit the working set; in-memory filtering still happens in
  /// the analytics layer for exact period grouping.
  Future<List<Map<String, dynamic>>> fetch(
    HealthTrackerType type, {
    DateTime? from,
    DateTime? to,
  }) async {
    if (_useFirebase) {
      final collection = _entriesCollection(type);
      if (collection == null) {
        _notSignedIn();
      }

      var query = collection.orderBy('date', descending: true);
      if (from != null) {
        query = query.where('date', isGreaterThanOrEqualTo: healthDateKey(from));
      }
      if (to != null) {
        query = query.where('date', isLessThanOrEqualTo: healthDateKey(to));
      }

      try {
        final snapshot = await query.get();
        return snapshot.docs
            .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
            .toList();
      } catch (e) {
        _logError(type, 'fetch', e);
        rethrow;
      }
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    try {
      var query = client.from(type.collection).select();
      if (from != null) {
        query = query.gte('date', healthDateKey(from));
      }
      if (to != null) {
        query = query.lte('date', healthDateKey(to));
      }
      final response = await query.order('date', ascending: false);
      return (response as List)
          .map((row) => Map<String, dynamic>.from(row as Map))
          .toList();
    } catch (e) {
      _logError(type, 'fetch', e);
      rethrow;
    }
  }

  /// Inserts a new entry. [payload] should come from a model's `toMap()`
  /// (without `id`). Returns the full stored map including the generated id.
  Future<Map<String, dynamic>> create(
    HealthTrackerType type,
    Map<String, dynamic> payload,
  ) async {
    if (_useFirebase) {
      final collection = _entriesCollection(type);
      if (collection == null) {
        _notSignedIn();
      }

      try {
        final docRef = await collection.add(payload);
        return <String, dynamic>{'id': docRef.id, ...payload};
      } catch (e) {
        _logError(type, 'create', e);
        rethrow;
      }
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    try {
      final response = await client
          .from(type.collection)
          .insert(payload)
          .select()
          .single();
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      _logError(type, 'create', e);
      rethrow;
    }
  }

  /// Updates an existing entry owned by the signed-in user.
  Future<Map<String, dynamic>> update(
    HealthTrackerType type,
    String id,
    Map<String, dynamic> payload,
  ) async {
    if (_useFirebase) {
      final collection = _entriesCollection(type);
      if (collection == null) {
        _notSignedIn();
      }

      try {
        await collection.doc(id).update(payload);
        return <String, dynamic>{'id': id, ...payload};
      } catch (e) {
        _logError(type, 'update', e);
        rethrow;
      }
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    try {
      final response = await client
          .from(type.collection)
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return Map<String, dynamic>.from(response as Map);
    } catch (e) {
      _logError(type, 'update', e);
      rethrow;
    }
  }

  /// Deletes an existing entry owned by the signed-in user.
  Future<void> delete(HealthTrackerType type, String id) async {
    if (_useFirebase) {
      final collection = _entriesCollection(type);
      if (collection == null) {
        _notSignedIn();
      }

      try {
        await collection.doc(id).delete();
      } catch (e) {
        _logError(type, 'delete', e);
        rethrow;
      }
      return;
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    try {
      await client.from(type.collection).delete().eq('id', id);
    } catch (e) {
      _logError(type, 'delete', e);
      rethrow;
    }
  }

  void _logError(HealthTrackerType type, String operation, Object error) {
    debugPrint('[health] ${type.collection}.$operation FAILED: '
        'type=${error.runtimeType}');
    if (error is PostgrestException) {
      debugPrint('[health] PostgrestException: code=${error.code} '
          'message=${error.message}');
    } else if (error is FirebaseException) {
      debugPrint('[health] FirebaseException: code=${error.code} '
          'message=${error.message}');
    } else if (error is AuthException) {
      debugPrint('[health] Supabase AuthException: ${error.message}');
    } else {
      debugPrint('[health] captured error: $error');
    }
  }
}