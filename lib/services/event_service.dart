import 'package:hive/hive.dart';
import 'package:scheduler/providers/event_provider.dart';
import '../constants/constant_texts.dart';
import '../models/event_model.dart';

class EventService extends EventProvider {
  deleteAllEvents() async {
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);
    box.clear();
  }

  storeEvent(EventModel eventModel) async {
    var box = await Hive.openBox<EventModel>(ConstantText.eventBoxName);
    box.add(eventModel);
    notifyListeners();
  }
}
