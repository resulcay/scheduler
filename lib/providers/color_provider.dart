import 'dart:math';

import 'package:flutter/material.dart';

class ColorProvider extends ChangeNotifier {
  Color color = randomColor();

  changeColor(Color value) {
    color = value;
    notifyListeners();
  }
}

Color randomColor() {
  var generatedColor = Random().nextInt(Colors.primaries.length);
  var finalColor = Colors.primaries[generatedColor].withOpacity(.9);

  return finalColor;
}
