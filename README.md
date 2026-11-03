# scheduler

### An offline event-tracking mobile app for Android and iOS.
### Android: https://play.google.com/store/apps/details?id=com.resoftware.scheduler
### iOS: https://apps.apple.com/app/id6829983109 (live once App Review approves 1.1.0)

Runs on Android phones and tablets, and on iPhone and iPad (iOS 15.0+).

## Architecture : Stores (ChangeNotifier) + screens
## State-Management : Provider, Default(setState)
## Design : Material-3
## Localization : Easy Localization
## Routing : Default (Navigator)
## Caching : Hive
## Notification : flutter_local_notifications
## Illustrations : Undraw

😎---ScreenShots & Media---😎

<img src="assets/pr/1.png" width="350">  |  <img src="assets/pr/2.png" width="350">  |
<img src="assets/pr/3.png" width="350">  |  <img src="assets/pr/4.png" width="350">  |
<img src="assets/pr/5.png" width="350">  |  <img src="assets/pr/6.png" width="350">  |
<img src="assets/pr/7.png" width="350">  |  <img src="assets/pr/8.png" width="350">  |
<img src="assets/pr/9.png" width="350">  |  <img src="assets/pr/10.png" width="350"> |

👇---Youtube Video---👇

[![Scheduler app](http://img.youtube.com/vi/WpBWiJPj3cw/0.jpg)](http://www.youtube.com/watch?v=WpBWiJPj3cw)

## Notifications

Reminders are scheduled locally with `flutter_local_notifications`
(`lib/services/notification_service.dart`). Each event gets a notification at its
start time plus an optional advance reminder (`lib/models/reminder_period.dart`).
All pending reminders are rebuilt on every launch and language change.

Android needs the scheduled-notification receivers in `AndroidManifest.xml`; their
absence was why reminders never arrived in 1.0.5 and earlier.

iOS keeps only the 64 soonest pending notifications, so the service schedules at most the
60 nearest and refills on launch. `AppDelegate.swift` sets the
`UNUserNotificationCenter` delegate so reminders also show while the app is open.

## Running on iOS

```bash
flutter pub get
(cd ios && pod install)              # LANG=en_US.UTF-8 if CocoaPods complains about encoding
flutter run -d <simulator or device>
```

In Xcode keep *User Script Sandboxing* set to **No** (Runner › Build Settings);
Flutter's build scripts fail with it on.

## Tests

```bash
flutter test                         # unit + platform-config tests
./scripts/test_notifications.sh      # Android emulator/device: a real reminder must be delivered
flutter test integration_test/notification_test.dart -d <ios simulator>   # same on iOS
```

## Privacy and support

[Privacy policy](PRIVACY.md) · [Support](SUPPORT.md)

## Store assets

Google Play and App Store screenshots, header and listing texts: see
[showcase/README.md](showcase/README.md).
