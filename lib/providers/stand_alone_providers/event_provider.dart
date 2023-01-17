import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:scheduler/models/event_model.dart';

import '../../constants/constant_texts.dart';

class EventProvider with ChangeNotifier {
  List<EventModel> items = [];

  getAllEvents() async {
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);

    items = box.values.toList();
    notifyListeners();

    return items;
  }
}
