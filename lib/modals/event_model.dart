class EventModel {
  final int eventId;
  String eventTitle;
  String? eventDescription;
  DateTime? eventDate;

  EventModel(
      {required this.eventId,
      required this.eventTitle,
      this.eventDescription,
      this.eventDate});
}
