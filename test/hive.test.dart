import 'package:flutter_test/flutter_test.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/services/event_service.dart';

void main() {
  test(
    'Hive storage test',
    () {
      EventService service = EventService();
      EventModel testModel = EventModel(
          eventTitle: 'testTitle',
          eventDate: DateTime.now(),
          color: 'testColor');
      service.storeEvent(testModel);
      //  expect(actual, matcher);
    },
  );
}
