import 'package:flutter/material.dart';
import 'package:scheduler/models/event_model.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> items = [];

  changeEvent(var object) {
    items.add(object);
    notifyListeners();
  }
}
