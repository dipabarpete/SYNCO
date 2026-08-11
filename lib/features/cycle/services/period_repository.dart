import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/backend.dart';
import '../../../models/period_record.dart';

/// Dev-only diagnostic: writes the full backend error to the debug console
/// without exposing any credential or token material.
void logSupabaseError(String operation, Object error) {
  debugPrint('[period_logs] $operation FAILED: type=${error.runtimeType}');
  if (error is PostgrestException) {
    debugPrint('[period_logs] PostgrestException: code=${error.code}');
    debugPrint('[period_logs]   message: ${error.message}');
    debugPrint('[period_logs]   details: ${error.details}');
    debugPrint('[period_logs]   hint: ${error.hint}');
  } else if (error is AuthException) {
    debugPrint('[period_logs] AuthException: status=${error.statusCode} code=${error.code} message=${error.message}');
  } else if (error is fb.FirebaseAuthException) {
    debugPrint('[period_logs] FirebaseAuthException: code=${error.code} message=${error.message}');
  } else if (error is FirebaseException) {
    debugPrint('[period_logs] FirebaseException: code=${error.code}');
    debugPrint('[period_logs]   message: ${error.message}');
  } else {
    debugPrint('[period_logs] captured error: $error');
  }
}

/// Read/write access to period logs.
///
/// Firebase backend: `users/{uid}/period_logs/{logId}` Firestore subcollection.
/// Supabase fallback: `period_logs` table (Row Level Security stays enabled).
class PeriodRepository {
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get _useFirebase => Backend.useFirebase;

  /// Resolved Firestore collection for the signed-in user, or null when
  /// Firebase is not active / the user is signed out.
  CollectionReference<Map<String, dynamic>>? get _periodLogsCollection {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('period_logs');
  }

  /// Fetches the signed-in user's period logs, newest first.
  Future<List<PeriodRecord>> getPeriods() async {
    if (_useFirebase) {
      final collection = _periodLogsCollection;
      if (collection == null) {
        if (Backend.firestore == null) {
          throw StateError('Firebase client is not initialized.');
        }
        throw StateError('You are not signed in. Please sign in and try again.');
      }

      try {
        final snapshot = await collection
            .orderBy('start_date', descending: true)
            .get();

        return snapshot.docs
            .map((doc) => PeriodRecord.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList();
      } catch (e) {
        logSupabaseError('getPeriods', e);
        rethrow;
      }
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    try {
      final response = await client
          .from('period_logs')
          .select()
          .order('start_date', ascending: false);

      return (response as List)
          .map((row) => PeriodRecord.fromMap(row))
          .toList();
    } catch (e) {
      logSupabaseError('getPeriods', e);
      rethrow;
    }
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Inserts a new period log for the currently signed-in user.
  Future<PeriodRecord> createPeriod({
    required DateTime startDate,
    DateTime? endDate,
    String? flowLevel,
    int? painLevel,
    String? mood,
    List<String>? symptoms,
    String? notes,
  }) async {
    if (_useFirebase) {
      final authUser = fb.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        if (Backend.firestore == null) {
          throw StateError('Firebase client is not initialized.');
        }
        throw StateError('You are not signed in. Please sign in and try again.');
      }

      debugPrint('[period_logs] createPeriod: user=${authUser.uid}');

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
      debugPrint('[period_logs] createPeriod payload: collection=users/'
          '${authUser.uid}/period_logs '
          'keys=${payload.keys.join(', ')}');

      try {
        final docRef = await _periodLogsCollection!.add(payload);
        return PeriodRecord.fromMap({
          'id': docRef.id,
          ...payload,
        });
      } catch (e) {
        debugPrint('CREATE PERIOD FAILED');
        logSupabaseError('createPeriod', e);
        rethrow;
      }
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw StateError('You are not signed in. Please sign in and try again.');
    }

    final session = client.auth.currentSession;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    debugPrint('[period_logs] createPeriod: user=${currentUser.id} '
        'session=${session != null ? "present" : "NULL"} '
        'expiresAt=${session?.expiresAt} now=$now '
        'expired=${session != null && session.expiresAt != null && session.expiresAt! <= now}');

    final payload = <String, dynamic>{
      'user_id': currentUser.id,
      'start_date': _formatDate(startDate),
      'end_date': endDate != null ? _formatDate(endDate) : null,
      'flow_level': flowLevel,
      'pain_level': painLevel,
      'mood': mood,
      'symptoms': symptoms ?? const [],
      'notes': notes,
    };
    debugPrint('[period_logs] createPeriod payload: table=public.period_logs '
        'keys=${payload.keys.join(', ')} '
        'start_date=${payload['start_date']} end_date=${payload['end_date']} '
        'flow_level=${payload['flow_level']} pain_level=${payload['pain_level']} '
        'mood=${payload['mood']} symptoms=${payload['symptoms']} '
        'notes=${payload['notes']}');

    try {
      final response = await client
          .from('period_logs')
          .insert(payload)
          .select()
          .single();

      return PeriodRecord.fromMap(response);
    } catch (e) {
      debugPrint('CREATE PERIOD FAILED');
      logSupabaseError('createPeriod', e);
      rethrow;
    }
  }

  /// Updates an existing period log owned by the signed-in user.
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
    if (_useFirebase) {
      final authUser = fb.FirebaseAuth.instance.currentUser;
      if (authUser == null) {
        if (Backend.firestore == null) {
          throw StateError('Firebase client is not initialized.');
        }
        throw StateError('You are not signed in. Please sign in and try again.');
      }

      try {
        final docRef =
            _periodLogsCollection!.doc(id);

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
        logSupabaseError('updatePeriod.update', e);
        rethrow;
      }
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    final currentUser = client.auth.currentUser;
    if (currentUser == null) {
      throw StateError('You are not signed in. Please sign in and try again.');
    }

    try {
      final response = await client
          .from('period_logs')
          .update({
            'start_date': _formatDate(startDate),
            'end_date': endDate != null ? _formatDate(endDate) : null,
            'flow_level': flowLevel,
            'pain_level': painLevel,
            'mood': mood,
            'symptoms': symptoms ?? const [],
            'notes': notes,
          })
          .eq('id', id)
          .select()
          .single();
      return PeriodRecord.fromMap(response);
    } catch (e) {
      logSupabaseError('updatePeriod.update', e);
      rethrow;
    }
  }

  /// Deletes an existing period log owned by the signed-in user.
  Future<void> deletePeriod(String id) async {
    if (_useFirebase) {
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
        logSupabaseError('deletePeriod', e);
        rethrow;
      }
      return;
    }

    final client = _supabase;
    if (client == null) {
      throw StateError('Supabase client is not initialized.');
    }

    try {
      await client.from('period_logs').delete().eq('id', id);
    } catch (e) {
      logSupabaseError('deletePeriod', e);
      rethrow;
    }
  }
}