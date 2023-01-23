import 'package:hive/hive.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/providers/stand_alone_providers/alarm_provider.dart';
import 'package:scheduler/services/i_hive_service.dart';

class AlarmService extends AlarmProvider implements IHiveService {
  @override
  Future<void> write(bool inComingValue) async {
    var box = await Hive.openBox(ConstantText.alarmBoxName);
    box.put(ConstantText.alarmBoxKeyName, inComingValue);
    notifyListeners();
  }

  @override
  Future<bool> read() async {
    var box = await Hive.openBox(ConstantText.alarmBoxName);
    isAlarm = box.get(ConstantText.alarmBoxKeyName) ?? false;
    notifyListeners();
    return isAlarm;
  }
}
