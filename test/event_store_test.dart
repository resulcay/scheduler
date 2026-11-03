import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/models/reminder_period.dart';
import 'package:scheduler/services/notification_service.dart';
import 'package:scheduler/stores/event_store.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The adapter shipped in <= 1.0.5 (5 fields), to prove upgrades keep data.
class _LegacyAdapter extends TypeAdapter<EventModel> {
  @override
  final int typeId = 0;

  @override
  EventModel read(BinaryReader reader) => throw UnimplementedError();

  @override
  void write(BinaryWriter writer, EventModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.eventTitle)
      ..writeByte(2)
      ..write(obj.eventDescription)
      ..writeByte(3)
      ..write(obj.eventDate)
      ..writeByte(4)
      ..write(obj.color);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory dir;
  late List<MethodCall> calls;
  late List<Map<String, Object?>> pending;

  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
  });

  tearDownAll(() => debugDefaultTargetPlatformOverride = null);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('scheduler_test');
    Hive.init(dir.path);
    calls = [];
    pending = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return switch (call.method) {
        'canScheduleExactNotifications' => true,
        'pendingNotificationRequests' => pending,
        _ => null,
      };
    });
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(channel, null);
    await Hive.close();
    await dir.delete(recursive: true);
  });

  List<int> ids(String method) => [
    for (final c in calls.where((c) => c.method == method))
      (c.arguments as Map)['id'] as int,
  ];

  test('events saved by 1.0.5 still load after the upgrade', () async {
    Hive.registerAdapter(_LegacyAdapter(), override: true);
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);
    await box.add(
      EventModel(
        id: 0,
        eventTitle: 'Old event',
        eventDescription: null,
        eventDate: DateTime(2027, 1, 2, 3, 4),
        color: 'e6f44336',
      ),
    );
    await box.close();

    Hive.registerAdapter(EventModelAdapter(), override: true);
    box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);
    final event = box.values.single;
    expect(event.eventTitle, 'Old event');
    expect(event.eventDate, DateTime(2027, 1, 2, 3, 4));
    expect(event.notify, isFalse);
    expect(event.reminder, isNull);
  });

  test('add stores the event and schedules its notifications', () async {
    Hive.registerAdapter(EventModelAdapter(), override: true);
    final store = await EventStore.open(
      NotificationService(FlutterLocalNotificationsPlugin()),
      describe: (n) => '${n.amount}',
    );
    final date = DateTime.now().add(const Duration(days: 3));

    final first = await store.add(title: 'A', date: date, color: 'ff000000');
    final second = await store.add(
      title: 'B',
      date: date,
      color: 'ff000000',
      notify: true,
      reminder: ReminderPeriod.day1.name,
    );

    expect(store.count, 2);
    expect([first.id, second.id], [0, 1]);
    // Only the event with reminders turned on is scheduled.
    expect(ids('zonedSchedule'), [100, 101]);
  });

  test('ids keep growing after deletes so notifications never clash', () async {
    Hive.registerAdapter(EventModelAdapter(), override: true);
    final store = await EventStore.open(
      NotificationService(FlutterLocalNotificationsPlugin()),
      describe: (n) => '${n.amount}',
    );
    final date = DateTime.now().add(const Duration(days: 1));
    final a = await store.add(title: 'A', date: date, color: 'ff000000');
    final b = await store.add(title: 'B', date: date, color: 'ff000000');
    await store.delete(a);
    final c = await store.add(title: 'C', date: date, color: 'ff000000');
    expect(c.id, b.id + 1);
  });

  test(
    'delete cancels the event\'s notifications, deleteAll cancels all',
    () async {
      Hive.registerAdapter(EventModelAdapter(), override: true);
      final store = await EventStore.open(
        NotificationService(FlutterLocalNotificationsPlugin()),
        describe: (n) => '${n.amount}',
      );
      final date = DateTime.now().add(const Duration(days: 2));
      final a = await store.add(
        title: 'A',
        date: date,
        color: 'ff000000',
        notify: true,
        reminder: ReminderPeriod.day1.name,
      );
      pending = [
        for (final id in [0, 1, 100])
          {'id': id, 'title': '', 'body': '', 'payload': ''},
      ];

      await store.delete(a);
      expect(ids('cancel'), [0, 1]);
      expect(store.count, 0);

      await store.deleteAll();
      expect(calls.last.method, 'cancelAllPendingNotifications');
    },
  );

  test('upcoming events come first, soonest first; past ones last', () async {
    Hive.registerAdapter(EventModelAdapter(), override: true);
    final store = await EventStore.open(
      NotificationService(FlutterLocalNotificationsPlugin()),
      describe: (n) => '${n.amount}',
    );
    final now = DateTime.now();
    for (final (title, offset) in [
      ('past-old', -48),
      ('later', 48),
      ('past-recent', -1),
      ('soon', 1),
    ]) {
      await store.add(
        title: title,
        date: now.add(Duration(hours: offset)),
        color: 'ff000000',
      );
    }
    expect(store.events.map((e) => e.eventTitle), [
      'soon',
      'later',
      'past-recent',
      'past-old',
    ]);
  });
}
