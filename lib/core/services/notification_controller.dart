import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/auth/providers/auth_provider.dart';
import '../../features/doctor/models/appointment.dart';
import 'notification_service.dart';

final notificationControllerProvider = Provider<NotificationController>((ref) {
  final controller = NotificationController(ref);
  ref.onDispose(() => controller.dispose());
  return controller;
});

class NotificationController {
  final Ref _ref;
  bool _isInitialized = false;

  /// Tracks scheduled consultation reminders per booking so a reminder is
  /// never scheduled twice for the same appointment.
  final Map<String, int> _scheduledReminderIds = {};

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

    // We can't do an OR query efficiently in Firestore snapshots for two
    // different fields easily, so we set up two listeners and check if the
    // user is a doctor or patient.

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
        _syncConsultationReminders(snapshot, user.id, isPatient: true);
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
        _syncConsultationReminders(snapshot, user.id, isPatient: false);
    });
  }

  /// Schedules (or cancels) the "consultation starting now" reminder for
  /// every confirmed appointment of the current user, based on the real
  /// booking date/time. The payload `consultation:<bookingId>` lets the tap
  /// open the correct Consultation Room.
  void _syncConsultationReminders(
    QuerySnapshot<Map<String, dynamic>> snapshot,
    String userId, {
    required bool isPatient,
  }) {
    final seen = <String>{};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final bookingId = doc.id;
      final status = data['status'];
      if (status == 'confirmed') {
        seen.add(bookingId);
        _scheduleConsultationReminder(
          bookingId: bookingId,
          data: data,
          isPatient: isPatient,
        );
      } else if (status == 'completed' ||
          status == 'cancelled' ||
          status == 'declined') {
        _cancelConsultationReminder(bookingId);
      }
    }
    // Cancel reminders for bookings that disappeared from the query.
    _scheduledReminderIds.removeWhere((id, _) => !seen.contains(id));
  }

  Future<void> _scheduleConsultationReminder({
    required String bookingId,
    required Map<String, dynamic> data,
    required bool isPatient,
  }) async {
    final reminderId = bookingId.hashCode & 0x7fffffff;
    if (_scheduledReminderIds[bookingId] == reminderId) return;

    final start = _appointmentStart(data);
    if (start == null || !start.isAfter(DateTime.now())) return;

    _scheduledReminderIds[bookingId] = reminderId;

    final String body;
    if (isPatient) {
      final doctorName = await _doctorName(data['doctorId']?.toString());
      body = 'Your consultation with $doctorName is starting now.';
    } else {
      final patientName = data['patientName']?.toString() ?? 'Your patient';
      body = "$patientName's appointment is starting now.";
    }

    await NotificationService().schedule(
      id: reminderId,
      title: 'SYNCO Consultation Reminder',
      body: body,
      scheduledDate: tz.TZDateTime(
        tz.local,
        start.year,
        start.month,
        start.day,
        start.hour,
        start.minute,
      ),
      payload: 'consultation:$bookingId',
    );
  }

  void _cancelConsultationReminder(String bookingId) {
    final reminderId = _scheduledReminderIds.remove(bookingId);
    if (reminderId != null) {
      NotificationService().cancel(reminderId);
    }
  }

  /// Combines the booking's date and slot into the scheduled start time.
  DateTime? _appointmentStart(Map<String, dynamic> data) {
    final rawDate = data['date']?.toString();
    if (rawDate == null) return null;
    final date = DateTime.tryParse(rawDate);
    if (date == null) return null;
    final slot = (data['time'] ?? data['slot'])?.toString() ?? '';
    return consultationSlotDateTime(date, slot);
  }

  Future<String> _doctorName(String? doctorId) async {
    if (doctorId == null) return 'your doctor';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();
      if (!doc.exists) return 'your doctor';
      final name = doc.data()?['name']?.toString() ?? 'your doctor';
      final lower = name.trim().toLowerCase();
      if (lower.startsWith('dr ') || lower.startsWith('dr.')) return name.trim();
      return 'Dr. $name';
    } catch (e) {
      debugPrint('[NotificationController] Doctor name lookup failed: $e');
      return 'your doctor';
    }
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