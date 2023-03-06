import 'package:hive/hive.dart';
import 'package:scheduler/providers/stand_alone_providers/event_provider.dart';
import '../constants/constant_texts.dart';
import '../models/event_model.dart';

class EventService extends EventProvider {
  deleteAllEvents() async {
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);
    box.clear();
  }

  deleteEventById(int id) async {
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);

    final Map<dynamic, EventModel> deliveriesMap = box.toMap();
    dynamic desiredKey;
    deliveriesMap.forEach((key, value) {
      if (value.id == id) desiredKey = key;
    });
    box.delete(desiredKey);
    notifyListeners();
  }

  storeEvent(EventModel eventModel) async {
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);
    box.add(eventModel);
    notifyListeners();
  }

  Future<int> generateEventId() async {
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);
    return box.values.length;
  }
}
