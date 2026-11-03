class ConstantText {
  static const fontName = 'Righteous';
  static const playStoreLink =
      'https://play.google.com/store/apps/details?id=com.resoftware.scheduler';

  /// Numeric Apple ID from App Store Connect (App Information page).
  /// Empty until the app is created there; iOS hides "Rate" while empty.
  static const appStoreId = '6829983109';
  static const appStoreLink = 'https://apps.apple.com/app/id$appStoreId';
  static const appStoreReviewLink = '$appStoreLink?action=write-review';
  static const onboardingBoxName = 'isOnboardingCompleted';
  static const onboardingBoxKeyName = 'localData';
  static const eventBoxName = 'eventBoxName';
  static const eventBoxKeyName = 'eventBoxKeyName';
  static const themeBoxName = 'themeBoxName';
  static const themeBoxKeyName = 'themeBoxKeyName';
  static const listTypeBoxName = 'listTypeBoxName';
  static const listTypeBoxKeyName = 'listTypeBoxKeyName';
  static const rateBoxName = 'rateBoxName';
  static const rateBoxKeyName = 'rateBoxKeyName';
}
