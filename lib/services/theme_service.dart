import 'package:hive/hive.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/providers/stand_alone_providers/theme_provider.dart';
import 'package:scheduler/services/i_hive_service.dart';

class ThemeService extends ThemeProvider implements IHiveService {
  @override
  Future<void> write(bool inComingValue) async {
    var box = await Hive.openBox(ConstantText.themeBoxName);
    box.put(ConstantText.themeBoxKeyName, inComingValue);
    notifyListeners();
  }

  @override
  Future<bool> read() async {
    var box = await Hive.openBox(ConstantText.themeBoxName);
    isDark = box.get(ConstantText.themeBoxKeyName) ?? getDefaultTheme();
    notifyListeners();
    return isDark;
  }
}
