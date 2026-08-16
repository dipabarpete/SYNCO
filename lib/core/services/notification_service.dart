import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/app_notification.dart';

/// SYNCO local notification service.
///
/// Handles device notification permissions and scheduling of persistent
/// local notifications using the device's local timezone.
class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _timezonesReady = false;
  bool _pluginReady = false;
  bool _exactAlarmsAvailable = false;

  /// Fallback timezone used when the device timezone cannot be resolved.
  static const String _fallbackTimeZone = 'America/Detroit';

  // -------------------------------------------------------------------------
  // INITIALIZATION
  // -------------------------------------------------------------------------

  /// Prepares the timezone database and initializes the plugin.
  Future<void> init() async {
    await _ensureTimezonesReady();
    if (kIsWeb) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Foreground presentation is enabled through the defaultPresent* options
    // so notifications are visible even while SYNCO is open.
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    try {
      await _plugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification tapped: ${details.payload}');
        },
      );
      _pluginReady = true;
      debugPrint('[NotificationService] Initialized.');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error: $e');
    }

    await _detectExactAlarmSupport();
  }

  Future<void> _ensureTimezonesReady() async {
    if (_timezonesReady) return;
    tz_data.initializeTimeZones();

    var tzName = _fallbackTimeZone;
    if (!kIsWeb) {
      try {
        tzName = await FlutterTimezone.getLocalTimezone();
      } catch (e) {
        debugPrint(
          '[NotificationService] Device timezone lookup failed, using fallback: $e',
        );
      }
    }

    try {
      tz.setLocalLocation(tz.getLocation(tzName));
      debugPrint('[NotificationService] Local timezone set to: $tzName');
    } catch (e) {
      debugPrint('[NotificationService] Timezone "$tzName" invalid: $e');
      try {
        tz.setLocalLocation(tz.getLocation(_fallbackTimeZone));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
    }
    _timezonesReady = true;
  }

  Future<void> _ensurePluginReady() async {
    await _ensureTimezonesReady();
    if (_pluginReady || kIsWeb) return;
    await init();
  }

  Future<void> _detectExactAlarmSupport() async {
    if (kIsWeb) return;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        _exactAlarmsAvailable = await android.canScheduleExactNotifications() ??
            false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Exact alarm detection failed: $e');
    }
  }

  // -------------------------------------------------------------------------
  // PERMISSIONS
  // -------------------------------------------------------------------------

  /// Requests notification permissions on the current platform.
  /// Returns true when notifications are (or will be) permitted.
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      debugPrint(
        '[NotificationService] Web notifications are not supported, skipping request.',
      );
      return false;
    }

    await _ensurePluginReady();

    var granted = true;

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      try {
        final result = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        granted = granted && (result ?? true);
      } catch (e) {
        debugPrint('[NotificationService] iOS permission request failed: $e');
      }
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      try {
        final result = await android.requestNotificationsPermission();
        granted = granted && (result ?? true);
      } catch (e) {
        debugPrint(
          '[NotificationService] Android permission request failed: $e',
        );
      }
    }

    return granted;
  }

  /// Whether the device currently allows SYNCO to show notifications.
  Future<bool> canScheduleNotifications() async {
    if (kIsWeb) return false;
    await _ensurePluginReady();

    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final enabled = await android.areNotificationsEnabled();
        return enabled ?? true;
      }

      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final settings = await ios.checkPermissions();
        // Null means permissions were never queried; assume allowed so the
        // reminder can still be saved and will fire once permission exists.
        return settings?.isEnabled ?? true;
      }
    } catch (e) {
      debugPrint('[NotificationService] Permission check failed: $e');
    }

    return true;
  }

  /// Prompts the user (Android only) to allow exact alarms so reminders can
  /// fire at the exact scheduled time. No-op on other platforms.
  Future<void> requestExactAlarmsPermissionIfNeeded() async {
    if (kIsWeb) return;
    await _ensurePluginReady();

    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return;
      if (!(await android.canScheduleExactNotifications() ?? false)) {
        await android.requestExactAlarmsPermission();
        _exactAlarmsAvailable =
            await android.canScheduleExactNotifications() ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] Exact alarm request failed: $e');
    }
  }

  // -------------------------------------------------------------------------
  // SCHEDULING
  // -------------------------------------------------------------------------

  /// Schedules a local notification at [scheduledDate] (device local time).
  ///
  /// When [matchDateTimeComponents] is provided the notification repeats
  /// (daily, weekly, monthly...) on the matched schedule.
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    if (kIsWeb) {
      debugPrint('[NotificationService] Cannot schedule notifications on Web.');
      return;
    }

    await _ensurePluginReady();

    await _detectExactAlarmSupport();

    final androidScheduleMode = _exactAlarmsAvailable
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'synco_reminders_channel',
            'SYNCO Reminders',
            channelDescription: 'Scheduled health and wellness reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: androidScheduleMode,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: 'reminder_$id',
      );
      debugPrint(
        '[NotificationService] Scheduled notification ID: $id at '
        '${scheduledDate.toIso8601String()} (match: $matchDateTimeComponents)',
      );
    } catch (e) {
      debugPrint('[NotificationService] Schedule error for ID $id: $e');
    }
  }

  /// Cancels a single scheduled notification by ID.
  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _ensurePluginReady();
    try {
      await _plugin.cancel(id: id);
      debugPrint('[NotificationService] Canceled notification ID: $id');
    } catch (e) {
      debugPrint('[NotificationService] Cancel error for ID $id: $e');
    }
  }

  /// Cancels multiple scheduled notifications.
  Future<void> cancelAll(Iterable<int> ids) async {
    for (final id in ids) {
      await cancel(id);
    }
  }

  // -------------------------------------------------------------------------
  // TIME HELPERS (device local timezone, DST aware)
  // -------------------------------------------------------------------------

  /// Returns the next occurrence of [hour]:[minute] in the device's local
  /// timezone. When [weekday] (1 = Monday ... 7 = Sunday) or [dayOfMonth] is
  /// given, the returned date also matches that constraint.
  tz.TZDateTime nextDateTime({
    required int hour,
    required int minute,
    int weekday = 0,
    int dayOfMonth = 0,
  }) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    for (var i = 0; i < 400; i++) {
      if (!candidate.isBefore(now) &&
          (weekday == 0 || candidate.weekday == weekday) &&
          (dayOfMonth == 0 || candidate.day == dayOfMonth)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  Future<void> saveAppNotification({
    required String userId,
    required String title,
    required String subtitle,
    int iconCode = 0xe000,
    String iconColorHex = 'FF9C27B0',
    String? payload,
  }) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc();
          
      final notification = AppNotification(
        id: docRef.id,
        title: title,
        subtitle: subtitle,
        createdAt: DateTime.now(),
        iconCode: iconCode,
        iconColorHex: iconColorHex,
        isUnread: true,
        payload: payload,
      );

      await docRef.set(notification.toMap());
      debugPrint('[NotificationService] Saved notification for $userId');
    } catch (e) {
      debugPrint('[NotificationService] Failed to save notification: $e');
    }
  }

  void showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) {
    schedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
      matchDateTimeComponents: null,
    );
  }
}
