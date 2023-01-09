import 'package:hive/hive.dart';
import 'package:scheduler/providers/theme_provider.dart';

import '../constants/constant_texts.dart';

class ThemeService extends ThemeProvider {
  storeTheme(bool inComingValue) async {
    var box = await Hive.openBox(ConstantText.themeBoxName);
    box.put(ConstantText.themeBoxKeyName, inComingValue);
    notifyListeners();
  }

  Future<bool> readTheme() async {
    var box = await Hive.openBox(ConstantText.themeBoxName);
    isDark = box.get(ConstantText.themeBoxKeyName) ?? getDefaultTheme();
    notifyListeners();
    return isDark;
  }
}
