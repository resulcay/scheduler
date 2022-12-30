import 'package:flutter/material.dart';

class DateTimeProvider with ChangeNotifier {
  DateTime eventDate = DateTime.now().add(const Duration(hours: 1));
  changeTimeRange(DateTime incomingEventTime) {
    eventDate = incomingEventTime;
    notifyListeners();
  }
}
