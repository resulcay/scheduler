import 'package:hive/hive.dart';
import 'package:scheduler/modals/event_model.dart';

import '../constants/constant_texts.dart';

class EventService {
  EventModel? eventModel;
  EventService({
    this.eventModel,
  });

  Future<void> openBox() async {
    var eventBox = await Hive.openBox(ConstantText.eventBoxName);
  }
}
