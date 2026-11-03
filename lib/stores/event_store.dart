import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/localization/texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/services/notification_service.dart';

/// Single source of truth for events; keeps notifications in sync with them.
class EventStore extends ChangeNotifier {
  EventStore(
    this._box,
    this._notifications, {
    this.describe = describeNotification,
    this.channelName = reminderChannelName,
  });

  static Future<EventStore> open(
    NotificationService notifications, {
    DescribeNotification describe = describeNotification,
  }) async => EventStore(
    await Hive.openBox<EventModel>(ConstantText.eventBoxName),
    notifications,
    describe: describe,
  );

  final Box<EventModel> _box;
  final NotificationService _notifications;
  final DescribeNotification describe;
  final String Function() channelName;

  /// Upcoming events soonest first, then past events most recent first.
  List<EventModel> get events {
    final now = DateTime.now();
    final upcoming = _box.values.where((e) => !e.eventDate.isBefore(now));
    final past = _box.values.where((e) => e.eventDate.isBefore(now));
    return [
      ...upcoming.toList()..sort((a, b) => a.eventDate.compareTo(b.eventDate)),
      ...past.toList()..sort((a, b) => b.eventDate.compareTo(a.eventDate)),
    ];
  }

  int get count => _box.length;

  /// Ids used to be the list length, so they could repeat after deletes.
  int get _nextId =>
      _box.values.fold(-1, (max, e) => e.id > max ? e.id : max) + 1;

  Future<EventModel> add({
    required String title,
    String? description,
    required DateTime date,
    required String color,
    bool notify = false,
    String? reminder,
  }) async {
    final event = EventModel(
      id: _nextId,
      eventTitle: title,
      eventDescription: description,
      eventDate: date,
      color: color,
      notify: notify,
      reminder: reminder,
    );
    await _box.add(event);
    notifyListeners();
    await _guard(
      () => _notifications.scheduleEvent(
        event,
        describe: describe,
        channelName: channelName(),
      ),
    );
    return event;
  }

  Future<void> delete(EventModel event) async {
    await _guard(() => _notifications.cancelEvent(event.id));
    await event.delete();
    notifyListeners();
  }

  Future<void> deleteAll() async {
    await _guard(_notifications.cancelAll);
    await _box.clear();
    notifyListeners();
  }

  /// Re-creates all pending notifications in the current language.
  Future<void> resync() => _guard(
    () => _notifications.rescheduleAll(
      _box.values,
      describe: describe,
      channelName: channelName(),
    ),
  );

  /// A notification failure must never lose the user's event.
  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e, s) {
      debugPrint('Notification error: $e\n$s');
    }
  }
}
