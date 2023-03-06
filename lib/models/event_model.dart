import 'package:hive_flutter/adapters.dart';

part 'event_model.g.dart';

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

  @HiveField(4)
  String color;

  EventModel({
    required this.id,
    required this.eventTitle,
    this.eventDescription,
    required this.eventDate,
    required this.color,
  });
}
