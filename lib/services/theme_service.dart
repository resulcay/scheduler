import 'package:hive/hive.dart';
import 'package:scheduler/providers/theme_provider.dart';

import '../constants/constant_texts.dart';

class ThemeService extends ThemeProvider {
  storeTheme(bool inComingValue) async {
    await Hive.openBox(ConstantText.themeBoxName).then((value) {
      value.put(ConstantText.themeBoxKeyName, inComingValue);
      notifyListeners();
    });
    notifyListeners();
  }

  readTheme() async {
    await Hive.openBox(ConstantText.themeBoxName).then((value) {
      isDark = value.get(ConstantText.themeBoxKeyName) ?? getDefaultTheme();
      notifyListeners();
    });
    notifyListeners();
  }
}
