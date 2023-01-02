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
  double value = Random().nextDouble();
  if (value < .2) {
    value += .7;
  }
  var generatedColor = Random().nextInt(Colors.primaries.length);
  var finalColor = Colors.primaries[generatedColor].withOpacity(value);

  return finalColor;
}
