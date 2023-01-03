import 'package:hive_flutter/adapters.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  String eventTitle;

  @HiveField(1)
  String? eventDescription;

  @HiveField(2)
  DateTime? eventDate;

  @HiveField(3)
  String color;

  EventModel({
    required this.eventTitle,
    this.eventDescription,
    this.eventDate,
    required this.color,
  });
}
