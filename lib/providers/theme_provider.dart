import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDark = false;

  bool getDefaultTheme() {
    var theme = SchedulerBinding.instance.platformDispatcher.platformBrightness;

    return theme == Brightness.dark;
  }
}
