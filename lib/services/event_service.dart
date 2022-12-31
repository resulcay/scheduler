import 'package:hive/hive.dart';

import '../constants/constant_texts.dart';
import '../models/event_model.dart';

class EventService {
  Future<void> openBox() async {
    await Hive.openBox(ConstantText.eventBoxName);
  }

  storeEvent(EventModel eventModel) async {
    Box<dynamic> box = await Hive.openBox(ConstantText.eventBoxName);
    box.add(eventModel);
    getAllEvents();
  }

  getAllEvents() async {
    Box<dynamic> box = await Hive.openBox(ConstantText.eventBoxName);
    EventModel item = box.get(1);
    print(item.eventTitle);
    print(item.eventDescription);
    print(item.eventDate);
    return box.values.toList();
  }
}
