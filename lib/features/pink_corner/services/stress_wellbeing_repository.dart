import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../../../core/backend.dart';
import 'stress_wellbeing_local_store.dart';

/// Firestore repository for Stress & Wellbeing journal entries and check-in records.
class StressWellbeingRepository {
  CollectionReference<Map<String, dynamic>>? get _journalsCollection {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('stress_journals');
  }

  CollectionReference<Map<String, dynamic>>? get _checkinsCollection {
    final firestore = Backend.firestore;
    if (firestore == null) return null;
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return firestore.collection('users').doc(uid).collection('stress_checkins');
  }

  /// Streams saved stress journal entries, newest date first.
  Stream<List<StressJournalEntry>> streamJournals() {
    final collection = _journalsCollection;
    if (collection == null) {
      return Stream.fromFuture(StressWellbeingLocalStore.loadJournals());
    }

    return collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final entries = snapshot.docs
          .map((doc) => StressJournalEntry.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    });
  }

  /// Saves a new stress journal entry.
  Future<void> saveJournal(StressJournalEntry entry) async {
    await StressWellbeingLocalStore.saveJournal(entry);

    final collection = _journalsCollection;
    if (collection == null) return;

    try {
      final docId = entry.id.isNotEmpty
          ? entry.id
          : FirebaseFirestore.instance.collection('tmp').doc().id;

      final payload = entry.toJson()..['id'] = docId;
      await collection.doc(docId).set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[stress_wellbeing] saveJournal failed: $e');
    }
  }

  /// Deletes a stress journal entry.
  Future<void> deleteJournal(String id) async {
    await StressWellbeingLocalStore.deleteJournal(id);

    final collection = _journalsCollection;
    if (collection == null) return;

    try {
      await collection.doc(id).delete();
    } catch (e) {
      debugPrint('[stress_wellbeing] deleteJournal failed: $e');
    }
  }

  /// Streams saved stress check-in records, newest date first.
  Stream<List<StressCheckInRecord>> streamCheckIns() {
    final collection = _checkinsCollection;
    if (collection == null) {
      return Stream.fromFuture(StressWellbeingLocalStore.loadCheckIns());
    }

    return collection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final records = snapshot.docs
          .map((doc) => StressCheckInRecord.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
      records.sort((a, b) => b.date.compareTo(a.date));
      return records;
    });
  }

  /// Saves a new stress check-in record.
  Future<void> saveCheckIn(StressCheckInRecord record) async {
    await StressWellbeingLocalStore.saveCheckIn(record);

    final collection = _checkinsCollection;
    if (collection == null) return;

    try {
      final docId = record.id.isNotEmpty
          ? record.id
          : FirebaseFirestore.instance.collection('tmp').doc().id;

      final payload = record.toJson()..['id'] = docId;
      await collection.doc(docId).set(payload, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[stress_wellbeing] saveCheckIn failed: $e');
    }
  }
}
