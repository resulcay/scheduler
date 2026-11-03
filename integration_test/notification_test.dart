import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/models/reminder_period.dart';
import 'package:scheduler/services/notification_service.dart';

/// End-to-end on a real device/emulator: a reminder scheduled through the
/// app's service must actually be posted by the OS.
/// Run with `scripts/test_notifications.sh` (grants the permissions first).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final plugin = FlutterLocalNotificationsPlugin();
  final service = NotificationService(plugin);

  setUpAll(service.init);
  tearDown(plugin.cancelAll);

  testWidgets('permissions needed for on-time reminders are granted', (
    _,
  ) async {
    expect(await service.requestPermission(), isTrue);
    expect(await service.canScheduleExact(), isTrue);
  });

  testWidgets('a scheduled reminder is delivered by the system', (_) async {
    final event = EventModel(
      id: 9999,
      eventTitle: 'Integration test',
      eventDate: DateTime.now().add(const Duration(seconds: 8)),
      color: 'ff297373',
      notify: true,
    );
    await service.scheduleEvent(
      event,
      describe: (_) => 'Starting now',
      channelName: 'Event reminders',
    );

    final pending = await plugin.pendingNotificationRequests();
    expect(pending.map((p) => p.id), contains(9999 * slotsPerEvent));

    List<ActiveNotification> delivered = [];
    for (var i = 0; i < 40 && delivered.isEmpty; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      delivered = (await plugin.getActiveNotifications())
          .where((n) => n.id == 9999 * slotsPerEvent)
          .toList();
    }
    expect(delivered, hasLength(1), reason: 'notification never fired');
    expect(delivered.single.title, 'Integration test');
    expect(delivered.single.body, 'Starting now');
    if (defaultTargetPlatform == TargetPlatform.android) {
      expect(delivered.single.channelId, NotificationService.channelId);
    }
    expect(await plugin.pendingNotificationRequests(), isEmpty);
  });

  testWidgets('deleting an event removes its pending reminders', (_) async {
    final event = EventModel(
      id: 9998,
      eventTitle: 'Cancelled',
      eventDate: DateTime.now().add(const Duration(days: 2)),
      color: 'ff297373',
      notify: true,
      reminder: ReminderPeriod.day1.name,
    );
    await service.scheduleEvent(
      event,
      describe: (_) => '',
      channelName: 'Event reminders',
    );
    expect(await plugin.pendingNotificationRequests(), hasLength(2));
    await service.cancelEvent(event.id);
    expect(await plugin.pendingNotificationRequests(), isEmpty);
  });
}
