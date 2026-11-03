import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the native setup whose absence made notifications silently fail
/// on Android in <= 1.0.5.
void main() {
  test('AndroidManifest registers the scheduled-notification receivers', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    for (final needed in [
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver',
      'com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver',
      'android.intent.action.BOOT_COMPLETED',
      'android.intent.action.MY_PACKAGE_REPLACED',
      'android.permission.POST_NOTIFICATIONS',
      'android.permission.RECEIVE_BOOT_COMPLETED',
      'android.permission.SCHEDULE_EXACT_ALARM',
    ]) {
      expect(manifest, contains(needed));
    }
  });

  test('notification icon exists and is protected from resource shrinking', () {
    expect(
      File(
        'android/app/src/main/res/drawable/ic_notification.xml',
      ).existsSync(),
      isTrue,
    );
    expect(
      File('android/app/src/main/res/raw/keep.xml').readAsStringSync(),
      contains('@drawable/ic_notification'),
    );
  });

  test(
    'desugaring stays enabled (required by flutter_local_notifications)',
    () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      expect(gradle, contains('isCoreLibraryDesugaringEnabled = true'));
      expect(gradle, contains('desugar_jdk_libs'));
    },
  );

  test('iOS app delegate forwards notifications to the plugin', () {
    final delegate = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(delegate, contains('UNUserNotificationCenter.current().delegate'));
  });

  test('iOS app icon is declared and opaque', () {
    final contents = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json',
    ).readAsStringSync();
    expect(contents, contains('Icon-App-1024x1024@1x.png'));
    final png = File(
      'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
    ).readAsBytesSync();
    // IHDR colour type 2 = RGB without alpha; App Store rejects alpha icons.
    expect(png[25], 2);
  });
}
