import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'notification_service.dart';

final notificationControllerProvider = Provider<NotificationController>((ref) {
  final controller = NotificationController(ref);
  ref.onDispose(() => controller.dispose());
  return controller;
});

class NotificationController {
  final Ref _ref;
  bool _isInitialized = false;
  
  NotificationController(this._ref) {
    _init();
  }

  Future<void> _init() async {
    if (kIsWeb) return; // Local notifications are tricky on Web, skip for now.

    await NotificationService().init();
    await NotificationService().requestPermissions();
    _isInitialized = true;
    _listenToAppointments();
  }

  void _listenToAppointments() {
    final user = _ref.read(authNotifierProvider).user;
    if (user == null || !_isInitialized) return;

    // Listen to bookings where the user is either the patient OR the doctor
    final db = FirebaseFirestore.instance;
    
    // We can't do an OR query efficiently in Firestore snapshots for two different fields easily
    // So we just set up two listeners, but check if the user is a doctor or patient.
    // In our app, we can just check 'userId' (for patients) and 'doctorId' (for doctors)

    // 1. Patient Listener
    db.collection('bookings')
      .where('userId', isEqualTo: user.id)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.modified) {
            final data = change.doc.data();
            if (data != null) {
              final status = data['status'];
              final doctorId = data['doctorId'];
              debugPrint('[NotificationController] Doctor $doctorId booking changed to $status');
              // Show notification if status changed to confirmed or declined
              if (status == 'confirmed') {
                _showNotification('Appointment Confirmed!', 'Your appointment has been confirmed.');
              } else if (status == 'declined') {
                _showNotification('Appointment Declined', 'Your appointment request was declined.');
              }
            }
          }
        }
    });

    // 2. Doctor Listener
    db.collection('bookings')
      .where('doctorId', isEqualTo: user.id)
      .snapshots()
      .listen((snapshot) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final data = change.doc.data();
            if (data != null) {
              final status = data['status'];
              final patientName = data['patientName'] ?? 'A patient';
              // If it's a newly added requested appointment
              if (status == 'requested') {
                _showNotification('New Appointment Request', '$patientName requested an appointment.');
              }
            }
          }
        }
    });
  }

  Future<void> _showNotification(String title, String body) async {
    if (kIsWeb) {
      debugPrint('[NotificationController] Web: $title - $body');
      return;
    }

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'synco_alerts_channel', 'SYNCO Alerts',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true);
            
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics, iOS: DarwinNotificationDetails());
        
    await flutterLocalNotificationsPlugin.show(
        id: DateTime.now().millisecond,
        title: title,
        body: body,
        notificationDetails: platformChannelSpecifics);
  }

  void dispose() {
    // In a production app, cancel streams here.
  }
}
