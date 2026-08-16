import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/backend.dart';
import '../../../core/services/notification_service.dart';
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
        .orderBy('timestamp', descending: false) // ASCENDING
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> sendMessage(String chatId, String senderId, String senderRole, String text) async {
    if (_firestore == null) {
      debugPrint('[ChatService] Firestore is null, cannot send message.');
      return;
    }

    try {
      final batch = _firestore!.batch();
      
      final chatRef = _firestore!.collection('chats').doc(chatId);
      final messagesRef = chatRef.collection('messages').doc();

      // Write the new message
      batch.set(messagesRef, {
        'senderId': senderId,
        'senderRole': senderRole,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the parent chat document
      batch.set(chatRef, {
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();

      if (senderRole == 'doctor') {
        final doc = await chatRef.get();
        if (doc.exists) {
          final patientId = doc.data()?['patientId'];
          if (patientId != null) {
            await NotificationService().saveAppNotification(
              userId: patientId,
              title: 'New Message from Doctor',
              subtitle: text,
              iconCode: 0xe153, // chat bubble
              iconColorHex: 'FF9C27B0',
              payload: 'chat:$chatId',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('[ChatService] Error sending message: $e');
      rethrow;
    }
  }
}
