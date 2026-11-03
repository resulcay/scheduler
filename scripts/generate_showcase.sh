#!/usr/bin/env bash
# Regenerates store screenshots/artwork into showcase/<platform>/.
#   ./scripts/generate_showcase.sh android
#   ./scripts/generate_showcase.sh ios      (on the Mac)
set -euo pipefail
cd "$(dirname "$0")/.."
PLATFORM=${1:-android}
case $PLATFORM in
  android) DEVICES="phone tablet-7 tablet-10" ;;
  ios) DEVICES="iphone-6.9 iphone-6.3 iphone-6.5 ipad-13" ;;
  *) echo "usage: $0 android|ios" >&2; exit 1 ;;
esac
GEN=showcase/generator/showcase_test.dart
flutter test $GEN --dart-define=SHOWCASE_PLATFORM=$PLATFORM
for d in $DEVICES; do
  echo "== $PLATFORM $d"
  flutter test $GEN --dart-define=SHOWCASE_PLATFORM=$PLATFORM --dart-define=SHOWCASE_DEVICE=$d
done
