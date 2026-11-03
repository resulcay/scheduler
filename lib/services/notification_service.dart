import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/models/reminder_period.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Localised notification body for a planned notification.
typedef DescribeNotification = String Function(PlannedNotification n);

class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final instance = NotificationService();

  static const channelId = 'event_reminders';

  /// iOS silently drops everything beyond the 64 soonest pending requests.
  static int get maxPending =>
      defaultTargetPlatform == TargetPlatform.iOS ? 60 : 400;

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(await _localLocation());
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        // Permission is asked when the user turns reminders on, not at launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }

  static Future<tz.Location> _localLocation() async {
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      return tz.getLocation(info.identifier);
    } catch (_) {
      // Unknown id: a fixed offset still yields the right instant (no DST).
      final offset = DateTime.now().timeZoneOffset;
      return tz.Location('Local', [tz.minTime], [0], [
        tz.TimeZone(offset, isDst: false, abbreviation: 'LOCAL'),
      ]);
    }
  }

  /// Asks for permission to post notifications; returns whether granted.
  Future<bool> requestPermission() async {
    final android = _android;
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return await _ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  /// Android 14+ denies exact alarms by default; iOS is always exact.
  Future<bool> canScheduleExact() async =>
      await _android?.canScheduleExactNotifications() ?? true;

  Future<void> requestExactAlarms() async =>
      _android?.requestExactAlarmsPermission();

  Future<void> scheduleEvent(
    EventModel event, {
    required DescribeNotification describe,
    required String channelName,
  }) async {
    if (!event.notify) return;
    await _scheduleAll(
      _plan(event, DateTime.now()),
      event: (_) => event,
      describe: describe,
      channelName: channelName,
    );
  }

  /// Rebuilds every pending notification, e.g. after an update, a language
  /// change or for data written by older versions.
  Future<void> rescheduleAll(
    Iterable<EventModel> events, {
    required DescribeNotification describe,
    required String channelName,
  }) async {
    await _plugin.cancelAllPendingNotifications();
    final now = DateTime.now();
    final byId = <int, EventModel>{};
    final planned = <PlannedNotification>[];
    for (final e in events.where((e) => e.notify)) {
      byId[e.id] = e;
      planned.addAll(_plan(e, now));
    }
    planned.sort((a, b) => a.date.compareTo(b.date));
    await _scheduleAll(
      planned.take(maxPending),
      event: (n) => byId[n.id ~/ slotsPerEvent]!,
      describe: describe,
      channelName: channelName,
    );
  }

  Future<void> cancelEvent(int eventId) async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending) {
      if (p.id ~/ slotsPerEvent == eventId) await _plugin.cancel(id: p.id);
    }
  }

  Future<void> cancelAll() => _plugin.cancelAllPendingNotifications();

  List<PlannedNotification> _plan(EventModel e, DateTime now) =>
      planNotifications(
        eventId: e.id,
        eventDate: e.eventDate,
        period: ReminderPeriod.tryParse(e.reminder),
        now: now,
      );

  Future<void> _scheduleAll(
    Iterable<PlannedNotification> planned, {
    required EventModel Function(PlannedNotification) event,
    required DescribeNotification describe,
    required String channelName,
  }) async {
    if (planned.isEmpty) return;
    final mode = await canScheduleExact()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    for (final n in planned) {
      final e = event(n);
      await _plugin.zonedSchedule(
        id: n.id,
        title: e.eventTitle,
        body: describe(n),
        scheduledDate: tz.TZDateTime.from(n.date, tz.local),
        notificationDetails: _details(channelName, e.color),
        androidScheduleMode: mode,
        payload: '${e.id}',
      );
    }
  }

  NotificationDetails _details(String channelName, String argbHex) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          color: Color(int.tryParse(argbHex, radix: 16) ?? 0xFF297373),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
        ),
      );
}
