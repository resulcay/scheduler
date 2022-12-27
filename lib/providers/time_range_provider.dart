import 'package:flutter/material.dart';

class TimeRangeProvider with ChangeNotifier {
  DateTime startTime = DateTime.now().add(const Duration(hours: 1));
  DateTime endTime = DateTime.now().add(const Duration(hours: 9));

  changeTimeRange(DateTime start, DateTime end) {
    startTime = start;
    notifyListeners();
    endTime = end;
    notifyListeners();
  }
}
