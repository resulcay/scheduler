import 'package:hive/hive.dart';

import '../constants/constant_texts.dart';
import '../models/event_model.dart';

class EventService {
  var exModel = EventModel(eventTitle: "23eventTitle");

  Future<void> openBox() async {
    var box = await Hive.openBox(ConstantText.eventBoxName);

    // storeEvent(box);
  }

  storeEvent(var box) {
    box.add(exModel);
    EventModel items = box.get(1);
  }

  getAllEvents() {}
}
