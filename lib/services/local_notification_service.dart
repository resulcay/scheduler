import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/screens/reminder_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../providers/time_range_provider.dart';

class NotificationApi {
  BuildContext context;
  NotificationApi({
    required this.context,
  });

  final _localNotificationApi = FlutterLocalNotificationsPlugin();

  Future<void> initApi() async {
    tz.initializeTimeZones();

    _localNotificationApi
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    _localNotificationApi
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions();

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _localNotificationApi.initialize(
      settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id_0',
      'Reminder',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('bell'),
      importance: Importance.max,
      priority: Priority.max,
    );
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationApi.show(id, title, body, details);
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required int hours,
    required String payload,
  }) async {
    DateTime scheduledTime =
        Provider.of<TimeRangeProvider>(context, listen: false).startTime;
    final details = await _notificationDetails();
    await _localNotificationApi.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledTime.add(Duration(hours: hours)),
        tz.local,
      ),
      details,
      payload: payload,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> periodicallyShowNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationApi.periodicallyShow(
      id,
      title,
      body,
      RepeatInterval.everyMinute,
      details,
      payload: payload,
      androidAllowWhileIdle: true,
    );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // print('id $id');
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      if (kDebugMode) {
        print('notification payload: $payload');
      }
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const ReminderScreen()),
    );
  }
}
