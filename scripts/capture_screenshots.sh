#!/usr/bin/env bash
# Captures real screenshots from the running app on one booted device into
# showcase/raw/<platform>/<device>/<lang>/, then frame them with
# ./scripts/generate_showcase.sh.
#   ./scripts/capture_screenshots.sh android phone     emulator-5554
#   ./scripts/capture_screenshots.sh android tablet-7  emulator-5556
#   ./scripts/capture_screenshots.sh android tablet-10 emulator-5558
#   ./scripts/capture_screenshots.sh ios iphone-6.9 <simulator udid>   (Mac)
# Uses its own data folder, so events already on the device are kept.
set -euo pipefail
cd "$(dirname "$0")/.."
export MSYS_NO_PATHCONV=1
PLATFORM=$1 DEVICE=$2 SERIAL=$3
APP=com.resoftware.scheduler
TARGET=test_driver/screenshots.dart
export SHOT_PLATFORM=$PLATFORM SHOT_DEVICE=$DEVICE SHOT_SERIAL=$SERIAL

if [ "$PLATFORM" = ios ]; then
  # The banner's "now" and the status bar clock follow the system language, so
  # each language is captured on a simulator rebooted into that locale. The
  # simulator's own language is put back afterwards (active on its next boot).
  prefs() { xcrun simctl spawn "$SERIAL" defaults "$1" "Apple Global Domain" "${@:2}"; }
  OLD_LANGS=$(prefs read AppleLanguages 2>/dev/null | tr -d '()",' | xargs || true)
  OLD_LOCALE=$(prefs read AppleLocale 2>/dev/null || true)
  restore() {
    xcrun simctl status_bar "$SERIAL" clear || true
    if [ -n "$OLD_LANGS" ]; then prefs write AppleLanguages -array $OLD_LANGS; fi
    if [ -n "$OLD_LOCALE" ]; then prefs write AppleLocale "$OLD_LOCALE"; fi
  }
  trap restore EXIT
  for lang in en-US tr-TR; do
    prefs write AppleLanguages -array "$lang"
    prefs write AppleLocale "${lang/-/_}"
    # shutdown can return early or fail while the device is still busy.
    until xcrun simctl list devices | grep "$SERIAL" | grep -q Shutdown; do
      xcrun simctl shutdown "$SERIAL" 2>/dev/null || sleep 1
    done
    xcrun simctl boot "$SERIAL"
    xcrun simctl bootstatus "$SERIAL" >/dev/null
    # Apple's marketing status bar: 9:41, full signal and battery (no bolt).
    xcrun simctl status_bar "$SERIAL" override --time 9:41 --dataNetwork wifi \
      --wifiMode active --wifiBars 3 --cellularMode active --cellularBars 4 \
      --batteryState discharging --batteryLevel 100
    # Without --keep-app-running flutter drive uninstalls the app, wiping the
    # events of an installed copy.
    SHOT_LANGS=$lang flutter drive -d "$SERIAL" -t $TARGET \
      --driver=test_driver/screenshots_test.dart --keep-app-running
  done
  exit
fi

APK=build/app/outputs/flutter-apk/app-debug.apk
flutter build apk --debug -t $TARGET --target-platform android-x64
adb -s "$SERIAL" install -r -t -g "$APK"
adb -s "$SERIAL" shell appops set $APP SCHEDULE_EXACT_ALARM allow
# The app hides the nav bar; skip Android's one-time "Viewing full screen" hint.
adb -s "$SERIAL" shell settings put secure immersive_mode_confirmations confirmed

# Clean status bar (System UI demo mode): 09:41, full battery, no extra icons.
demo() { adb -s "$SERIAL" shell am broadcast -a com.android.systemui.demo -e command "$@" >/dev/null; }
adb -s "$SERIAL" shell settings put global sysui_demo_allowed 1
demo enter
demo clock -e hhmm 0941
demo battery -e level 100 -e plugged false
demo network -e wifi show -e level 4 -e fully true
demo network -e mobile show -e datatype none -e level 4 -e fully true
demo notifications -e visible false
trap 'demo exit' EXIT

flutter drive -d "$SERIAL" -t $TARGET --driver=test_driver/screenshots_test.dart \
  --use-application-binary="$APK"
