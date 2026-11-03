#!/usr/bin/env bash
# On-device notification tests: a reminder scheduled by the app must really be
# delivered by the OS. Needs one booted emulator/device.
#   Android: ./scripts/test_notifications.sh [android-x64|android-arm64]
#   iOS simulator: flutter test integration_test/notification_test.dart
#                  (tap "Allow" on the first permission prompt)
set -euo pipefail
cd "$(dirname "$0")/.."
export MSYS_NO_PATHCONV=1
APP=com.resoftware.scheduler
ABI=${1:-android-x64}
TEST=integration_test/notification_test.dart
APK=build/app/outputs/flutter-apk/app-debug.apk

flutter build apk --debug -t $TEST --target-platform "$ABI"
# -g grants POST_NOTIFICATIONS so no dialog blocks the test.
adb install -r -t -g "$APK"
adb shell appops set $APP SCHEDULE_EXACT_ALARM allow
flutter drive --driver=test_driver/integration_test.dart -t $TEST \
  --use-application-binary="$APK"
