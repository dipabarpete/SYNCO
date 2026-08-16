import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/notification_service.dart';

final appointmentListenerProvider = Provider<void>((ref) {
  final user = ref.watch(authNotifierProvider).userProfile;
  if (user == null) return;

  // We keep a cache of known appointment statuses to detect transitions
  final Map<String, String> _statusCache = {};
  
  final subscription = FirebaseFirestore.instance
      .collection('bookings')
      .where('userId', isEqualTo: user.id)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          final doc = change.doc;
          final currentStatus = doc.data()?['status'] as String?;
          final appointmentId = doc.id;
          
          if (change.type == DocumentChangeType.added) {
            _statusCache[appointmentId] = currentStatus ?? 'requested';
          } else if (change.type == DocumentChangeType.modified) {
            final previousStatus = _statusCache[appointmentId];
            
            // Check for transition from 'requested' to 'confirmed'
            if (previousStatus == 'requested' && currentStatus == 'confirmed') {
              final payload = jsonEncode({'appointmentId': appointmentId});
              
              // We could also get the doctorId and fetch the doctor name, but we can just use a generic message.
              // To get doctor name, we'd need another fetch. For simplicity, we just say 'A doctor'.
              NotificationService().saveAppNotification(
                userId: user.id,
                title: 'Appointment Confirmed! ✅',
                subtitle: 'Your request has been accepted. Tap to complete your payment.',
                payload: payload,
              );
              
              // Assuming NotificationService has a way to show a local notification immediately
              // Since NotificationService handles scheduled ones, we might need a direct show method.
              // We will just call saveAppNotification for now, but to show banner:
              _showImmediateNotification(
                id: appointmentId.hashCode, 
                title: 'Appointment Confirmed! ✅',
                body: 'Your request has been accepted. Tap to complete your payment.',
                payload: payload,
              );
            }
            
            _statusCache[appointmentId] = currentStatus ?? 'requested';
          }
        }
      });
      
  ref.onDispose(() {
    subscription.cancel();
  });
});

void _showImmediateNotification({
  required int id,
  required String title,
  required String body,
  required String payload,
}) {
  // Let's add a `showImmediateNotification` method to NotificationService
  NotificationService().showImmediateNotification(
    id: id,
    title: title,
    body: body,
    payload: payload,
  );
}
