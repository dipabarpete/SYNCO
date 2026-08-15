import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/whisper_post.dart';

final globalWhisperFeedProvider = StreamProvider<List<WhisperPost>>((ref) {
  return FirebaseFirestore.instance
      .collection('whisper_posts')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => WhisperPost.fromFirestore(doc)).toList();
  });
});
