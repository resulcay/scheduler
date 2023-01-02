import 'package:hive/hive.dart';
import 'package:scheduler/providers/event_provider.dart';

import '../constants/constant_texts.dart';
import '../models/event_model.dart';

class EventService extends EventProvider {
  Future<void> openBox() async {
    await Hive.openBox(ConstantText.eventBoxName);
  }

  deleteAllEvents() async {
    Box<dynamic> box = await Hive.openBox(ConstantText.eventBoxName);
    box.clear();
  }

  storeEvent(EventModel eventModel) async {
    Box<dynamic> box = await Hive.openBox(ConstantText.eventBoxName);
    box.add(eventModel);
    print('successfully saved');
  }

  Future<List<EventModel>> getAllEvents() async {
    await Hive.openBox(ConstantText.eventBoxName).then((value) {
      List listOfValues = value.values.toList();

      if (items.isEmpty) {
        for (var element in listOfValues) {
          changeEvent(element);
        }
      }
    });

    return items;
  }
}
