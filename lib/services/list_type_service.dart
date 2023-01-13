import 'package:hive/hive.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/providers/list_type_provider.dart';
import 'package:scheduler/services/i_hive_service.dart';

class ListTypeService extends ListTypeProvider implements IHiveService {
  @override
  Future<void> write(bool inComingValue) async {
    var box = await Hive.openBox(ConstantText.listTypeBoxName);
    box.put(ConstantText.listTypeBoxKeyName, inComingValue);
    notifyListeners();
  }

  @override
  Future<bool> read() async {
    var box = await Hive.openBox(ConstantText.listTypeBoxName);
    switchValue = box.get(ConstantText.listTypeBoxKeyName) ?? true;
    notifyListeners();
    return switchValue;
  }
}
