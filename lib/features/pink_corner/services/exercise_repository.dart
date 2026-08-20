import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
import 'exercise_local_store.dart';

/// Firestore repository for Exercise & Movement sessions and achievements.
class ExerciseRepository {
  CollectionReference<Map<String, dynamic>>? get _sessionsCollection {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('exercise_sessions');
  }

  DocumentReference<Map<String, dynamic>>? get _achievementsDoc {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('exercise_achievements').doc('unlocked');
  }

  /// Streams saved exercise sessions, newest first.
  Stream<List<ExerciseSession>> streamSessions() {
    final collection = _sessionsCollection;
    if (collection == null) {
      return Stream.fromFuture(ExerciseLocalStore.loadSessions());
    }

    return collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final sessions = snapshot.docs
          .map((doc) => ExerciseSession.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      sessions.sort((a, b) => b.date.compareTo(a.date));
      return sessions;
    });
  }

  /// Saves a newly completed exercise session.
  Future<void> saveSession(ExerciseSession session) async {
    // Always keep local store updated for offline/fallback capability
    await ExerciseLocalStore.saveSession(session);

    final collection = _sessionsCollection;
    if (collection == null) return;

    try {
      final docId = session.id.isNotEmpty
          ? session.id
          : FirebaseFirestore.instance.collection('tmp').doc().id;

      final payload = session.toJson()..['id'] = docId;
      await collection.doc(docId).set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[exercise] saveSession failed: $e');
    }
  }

  /// Streams unlocked achievements.
  Stream<Set<String>> streamUnlockedAchievements() {
    final doc = _achievementsDoc;
    if (doc == null) {
      return Stream.fromFuture(ExerciseLocalStore.loadUnlockedAchievements());
    }

    return doc.snapshots().map((snapshot) {
      if (!snapshot.exists) return <String>{};
      final data = snapshot.data();
      final list = (data?['unlocked_ids'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toSet();
      return list;
    });
  }

  /// Saves unlocked achievements.
  Future<void> saveUnlockedAchievements(Set<String> unlockedIds) async {
    await ExerciseLocalStore.saveUnlockedAchievements(unlockedIds);

    final doc = _achievementsDoc;
    if (doc == null) return;

    try {
      await doc.set({
        'unlocked_ids': unlockedIds.toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[exercise] saveUnlockedAchievements failed: $e');
    }
  }
}
