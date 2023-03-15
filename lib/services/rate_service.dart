import 'package:hive/hive.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/providers/stand_alone_providers/rate_provider.dart';
import 'package:scheduler/services/i_hive_service.dart';

class RateService extends RateProvider implements IHiveService {
  @override
  Future<void> write(bool inComingValue) async {
    var box = await Hive.openBox(ConstantText.rateBoxName);
    box.put(ConstantText.rateBoxKeyName, inComingValue);
    notifyListeners();
  }

  @override
  Future<bool> read() async {
    var box = await Hive.openBox(ConstantText.rateBoxName);
    isRated = box.get(ConstantText.rateBoxKeyName) ?? false;
    notifyListeners();
    return isRated;
  }
}
