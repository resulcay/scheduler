import 'package:hive/hive.dart';

part 'event_model.g.dart';

// Field numbers are persisted on users' devices: never renumber, only append.
@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String eventTitle;

  @HiveField(2)
  String? eventDescription;

  @HiveField(3)
  DateTime eventDate;

  /// ARGB hex, e.g. `ff2196f3`.
  @HiveField(4)
  String color;

  /// Whether reminders are scheduled for this event (absent in <= 1.0.5 data).
  @HiveField(5)
  bool notify;

  /// [ReminderPeriod.name] of the advance reminder, null = only at event time.
  @HiveField(6)
  String? reminder;

  EventModel({
    required this.id,
    required this.eventTitle,
    this.eventDescription,
    required this.eventDate,
    required this.color,
    this.notify = false,
    this.reminder,
  });
}
