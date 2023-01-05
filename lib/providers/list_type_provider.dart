import 'package:flutter/material.dart';

class ListTypeProvider extends ChangeNotifier {
  bool switchValue = true;

  changeSwitch(bool value) {
    switchValue = value;
    notifyListeners();
  }
}
