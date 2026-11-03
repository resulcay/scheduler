import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:scheduler/constants/constant_texts.dart';

/// Small user preferences. Box and key names match <= 1.0.5 so existing
/// installs keep their settings.
class SettingsStore extends ChangeNotifier {
  SettingsStore._(this._theme, this._listType, this._rate, this._onboarding);

  static Future<SettingsStore> open() async => SettingsStore._(
    await Hive.openBox(ConstantText.themeBoxName),
    await Hive.openBox(ConstantText.listTypeBoxName),
    await Hive.openBox(ConstantText.rateBoxName),
    await Hive.openBox(ConstantText.onboardingBoxName),
  );

  final Box _theme;
  final Box _listType;
  final Box _rate;
  final Box _onboarding;

  /// null = follow the system.
  bool? get isDark => _theme.get(ConstantText.themeBoxKeyName) as bool?;
  ThemeMode get themeMode => switch (isDark) {
    null => ThemeMode.system,
    true => ThemeMode.dark,
    false => ThemeMode.light,
  };

  bool get stackedList =>
      _listType.get(ConstantText.listTypeBoxKeyName) as bool? ?? true;
  bool get isRated => _rate.get(ConstantText.rateBoxKeyName) as bool? ?? false;
  bool get onboardingDone => _onboarding.isNotEmpty;

  Future<void> setDark(bool value) =>
      _put(_theme, ConstantText.themeBoxKeyName, value);
  Future<void> setStackedList(bool value) =>
      _put(_listType, ConstantText.listTypeBoxKeyName, value);
  Future<void> setRated() => _put(_rate, ConstantText.rateBoxKeyName, true);
  Future<void> completeOnboarding() =>
      _put(_onboarding, ConstantText.onboardingBoxKeyName, true);

  Future<void> _put(Box box, String key, Object value) {
    final saved = box.put(key, value);
    notifyListeners();
    return saved;
  }
}
