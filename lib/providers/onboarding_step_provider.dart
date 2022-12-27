import 'package:flutter/foundation.dart';

class OnboardingStepProvider with ChangeNotifier {
  int onboardingStep = 0;

  changeStep(int value) {
    onboardingStep = value;
    notifyListeners();
  }
}
