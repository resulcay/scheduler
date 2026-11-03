import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/models/reminder_period.dart';
import 'package:scheduler/services/notification_service.dart';
import 'package:timezone/timezone.dart' as tz;

/// Drives the real flutter_local_notifications Dart code and checks exactly
/// what reaches the native side over its method channel.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pluginChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  const tzChannel = MethodChannel('flutter_timezone');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> calls;
  late bool exactAllowed;
  late bool permissionGranted;
  late List<Map<String, Object?>> pending;
  late Object? timezone;

  String describe(PlannedNotification n) =>
      n.unit == null ? 'starts now' : '${n.amount} ${n.unit!.name} left';

  EventModel event({
    int id = 4,
    required DateTime date,
    bool notify = true,
    ReminderPeriod? reminder,
  }) => EventModel(
    id: id,
    eventTitle: 'Dentist',
    eventDate: date,
    color: 'ff2196f3',
    notify: notify,
    reminder: reminder?.name,
  );

  List<MethodCall> scheduled() =>
      calls.where((c) => c.method == 'zonedSchedule').toList();

  Map<String, Object?> args(MethodCall c) =>
      Map<String, Object?>.from(c.arguments as Map);

  Future<NotificationService> initService() async {
    final service = NotificationService(FlutterLocalNotificationsPlugin());
    await service.init();
    calls.clear();
    return service;
  }

  setUp(() {
    calls = [];
    exactAllowed = true;
    permissionGranted = true;
    pending = [];
    timezone = 'Europe/Istanbul';
    messenger.setMockMethodCallHandler(pluginChannel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'initialize' => true,
        'canScheduleExactNotifications' => exactAllowed,
        'requestNotificationsPermission' ||
        'requestPermissions' => permissionGranted,
        'pendingNotificationRequests' => pending,
        _ => null,
      };
    });
    messenger.setMockMethodCallHandler(tzChannel, (call) async {
      if (timezone is Exception) throw timezone!;
      return timezone;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(pluginChannel, null);
    messenger.setMockMethodCallHandler(tzChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  group('Android', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      AndroidFlutterLocalNotificationsPlugin.registerWith();
    });

    test('init uses the device time zone and the monochrome icon', () async {
      final service = NotificationService(FlutterLocalNotificationsPlugin());
      await service.init();
      expect(tz.local.name, 'Europe/Istanbul');
      final init = calls.singleWhere((c) => c.method == 'initialize');
      expect(args(init)['defaultIcon'], 'ic_notification');
    });

    test('init falls back to a fixed offset for unknown zones', () async {
      timezone = 'Mars/Olympus_Mons';
      await initService();
      expect(tz.local.name, 'Local');
      final now = DateTime.now();
      expect(
        tz.TZDateTime.from(now, tz.local).millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
    });

    test(
      'schedules the event and its hourly reminders at the right instants',
      () async {
        final service = await initService();
        final date = DateTime.now().add(const Duration(days: 2));
        await service.scheduleEvent(
          event(date: date, reminder: ReminderPeriod.hour3Hourly),
          describe: describe,
          channelName: 'Event reminders',
        );

        final calls = scheduled();
        expect(calls.map((c) => args(c)['id']), [400, 403, 402, 401]);
        expect(calls.map((c) => args(c)['body']), [
          'starts now',
          '3 hour left',
          '2 hour left',
          '1 hour left',
        ]);
        for (final (i, hoursBefore) in [(0, 0), (1, 3), (2, 2), (3, 1)]) {
          final a = args(calls[i]);
          expect(a['title'], 'Dentist');
          expect(a['payload'], '4');
          expect(a['timeZoneName'], 'Europe/Istanbul');
          expect(
            DateTime.parse(a['scheduledDateTimeISO8601']! as String).toUtc(),
            date.subtract(Duration(hours: hoursBefore)).toUtc(),
          );
          final specifics = Map<String, Object?>.from(
            a['platformSpecifics']! as Map,
          );
          expect(specifics['channelId'], NotificationService.channelId);
          expect(specifics['channelName'], 'Event reminders');
          expect(specifics['scheduleMode'], 'exactAllowWhileIdle');
        }
      },
    );

    test(
      'falls back to inexact alarms when exact ones are not allowed',
      () async {
        exactAllowed = false;
        final service = await initService();
        await service.scheduleEvent(
          event(date: DateTime.now().add(const Duration(hours: 1))),
          describe: describe,
          channelName: 'x',
        );
        final specifics = args(scheduled().single)['platformSpecifics']! as Map;
        expect(specifics['scheduleMode'], 'inexactAllowWhileIdle');
      },
    );

    test(
      'schedules nothing when reminders are off or the event is past',
      () async {
        final service = await initService();
        await service.scheduleEvent(
          event(
            date: DateTime.now().add(const Duration(days: 1)),
            notify: false,
          ),
          describe: describe,
          channelName: 'x',
        );
        await service.scheduleEvent(
          event(date: DateTime.now().subtract(const Duration(minutes: 1))),
          describe: describe,
          channelName: 'x',
        );
        expect(scheduled(), isEmpty);
      },
    );

    test('cancelEvent cancels only that event\'s notifications', () async {
      final service = await initService();
      pending = [
        for (final id in [400, 401, 500, 4000, 399])
          {'id': id, 'title': '', 'body': '', 'payload': ''},
      ];
      await service.cancelEvent(4);
      final cancelled = calls
          .where((c) => c.method == 'cancel')
          .map((c) => args(c)['id']);
      expect(cancelled, [400, 401]);
    });

    test(
      'rescheduleAll clears pending ones and re-creates them by date',
      () async {
        final service = await initService();
        final now = DateTime.now();
        await service.rescheduleAll(
          [
            event(id: 1, date: now.add(const Duration(days: 3))),
            event(id: 2, date: now.add(const Duration(days: 1)), notify: false),
            event(
              id: 3,
              date: now.add(const Duration(days: 2)),
              reminder: ReminderPeriod.day1,
            ),
            event(id: 5, date: now.subtract(const Duration(days: 1))),
          ],
          describe: describe,
          channelName: 'x',
        );
        expect(calls.first.method, 'cancelAllPendingNotifications');
        // Soonest first: event 3's day-before, event 3, event 1.
        expect(scheduled().map((c) => args(c)['id']), [301, 300, 100]);
      },
    );

    test('rescheduleAll caps the number of pending notifications', () async {
      final service = await initService();
      final now = DateTime.now();
      await service.rescheduleAll(
        [
          for (var i = 0; i < 100; i++)
            event(
              id: i,
              date: now.add(Duration(days: 2, hours: i)),
              reminder: ReminderPeriod.hour6Hourly,
            ),
        ],
        describe: describe,
        channelName: 'x',
      );
      expect(scheduled(), hasLength(NotificationService.maxPending));
    });

    test('requestPermission reports the user\'s answer', () async {
      final service = await initService();
      expect(await service.requestPermission(), isTrue);
      permissionGranted = false;
      expect(await service.requestPermission(), isFalse);
    });
  });

  group('iOS', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      IOSFlutterLocalNotificationsPlugin.registerWith();
    });

    test('init does not prompt; permission is asked on demand', () async {
      final service = NotificationService(FlutterLocalNotificationsPlugin());
      await service.init();
      final init = args(calls.singleWhere((c) => c.method == 'initialize'));
      expect(init['requestAlertPermission'], isFalse);

      expect(await service.requestPermission(), isTrue);
      final request = calls.lastWhere((c) => c.method == 'requestPermissions');
      expect(args(request), containsPair('alert', true));
    });

    test('scheduled notifications show as banners with sound', () async {
      final service = await initService();
      await service.scheduleEvent(
        event(date: DateTime.now().add(const Duration(hours: 2))),
        describe: describe,
        channelName: 'x',
      );
      final specifics = Map<String, Object?>.from(
        args(scheduled().single)['platformSpecifics']! as Map,
      );
      expect(specifics['presentBanner'], isTrue);
      expect(specifics['presentSound'], isTrue);
      expect(specifics['presentList'], isTrue);
    });

    test('iOS keeps the pending queue under its 64 request limit', () {
      expect(NotificationService.maxPending, lessThanOrEqualTo(64));
    });
  });
}
