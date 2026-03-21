import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationApi {
  final _localNotificationApi = FlutterLocalNotificationsPlugin();

  Future<void> initApi() async {
    tz.initializeTimeZones();

    // Request Android notification permission
    final androidImplementation =
        _localNotificationApi.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    // Request iOS notification permissions
    final iOSImplementation =
        _localNotificationApi.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iOSImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    DarwinInitializationSettings iosInitializationSettings =
        const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final InitializationSettings settings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _localNotificationApi.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<NotificationDetails> _notificationDetails() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id_0',
      'Reminder',
      playSound: true,
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
    await _localNotificationApi.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
    required String payload,
  }) async {
    final details = await _notificationDetails();
    await _localNotificationApi.zonedSchedule(
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(
        date,
        tz.local,
      ),
      notificationDetails: details,
      payload: payload,
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
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      id: id,
      title: title,
      body: body,
      repeatInterval: RepeatInterval.everyMinute,
      notificationDetails: details,
      payload: payload,
    );
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {}
}
