import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/backend.dart';
import '../models/chat_message.dart';

class ChatService {
  FirebaseFirestore? get _firestore => Backend.firestore;

  Stream<List<ChatMessage>> getMessages(String chatId) {
    if (_firestore == null) {
      debugPrint('[ChatService] Firestore is null, returning empty stream.');
      return Stream.value([]);
    }

    return _firestore!
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> sendMessage(String chatId, String senderId, String text) async {
    if (_firestore == null) {
      debugPrint('[ChatService] Firestore is null, cannot send message.');
      return;
    }

    try {
      await _firestore!
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[ChatService] Error sending message: $e');
      rethrow;
    }
  }
}
