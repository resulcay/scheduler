import 'package:hive/hive.dart';
import 'package:scheduler/providers/list_type_provider.dart';

import '../constants/constant_texts.dart';

class ListTypeService extends ListTypeProvider {
  storeListType(bool inComingValue) async {
    var box = await Hive.openBox(ConstantText.listTypeBoxName);
    box.put(ConstantText.listTypeBoxKeyName, inComingValue);
    notifyListeners();
  }

  Future<bool> readListType() async {
    var box = await Hive.openBox(ConstantText.listTypeBoxName);
    switchValue = box.get(ConstantText.listTypeBoxKeyName) ?? true;
    notifyListeners();
    return switchValue;
  }
}
