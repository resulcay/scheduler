# Store showcase

Store screenshots made from **real captures of the running app** (emulator /
simulator), framed with a caption. Two steps:

1. `scripts/capture_screenshots.sh` runs the app (`test_driver/screenshots.dart`)
   under flutter_driver. The app seeds demo events, switches language and opens
   each screen. The host takes full-screen shots with `adb screencap` or
   `simctl io screenshot` into `raw/`. The reminder shot shows a **real system
   notification** that was scheduled through the app's own notification service.
2. `scripts/generate_showcase.sh` frames the raw shots (`generator/showcase_test.dart`)
   into the exact store sizes. It also writes the feature graphic and the icons.

The capture app uses its own data folder (`showcase` Hive dir), so events
already on the emulator are kept.

```
showcase/
├── raw/<platform>/<device>/<lang>/   home, notify, create, detail, dark, drawer (.png)
├── generator/                        composer + icon painter + RGB PNG encoder
├── store-listing/                    copy-paste texts for both stores + privacy policy
├── android/
│   ├── icon/                 app-icon-512.png
│   ├── feature-graphic/      en-US.png, tr-TR.png            1024×500
│   ├── phone/<lang>/         01..06                          1080×1920
│   ├── tablet-7/<lang>/      01..06                          1080×1920
│   └── tablet-10/<lang>/     01..06                          1440×2560
└── ios/                      (generate on the Mac)
    ├── icon/                 app-icon-1024.png
    ├── iphone-6.9/<lang>/    01..06                          1320×2868
    ├── iphone-6.5/<lang>/    01..06                          1284×2778
    └── ipad-13/<lang>/       01..06                          2064×2752
```

## Android (Windows / any OS)

Emulators used (`avdmanager`, image `android-34;google_apis;x86_64`):

| device | AVD | screen |
|---|---|---|
| phone | Pixel_8_Pro_API_34 | 1344×2992 |
| tablet-7 | Showcase_Tablet_7_API_34 | 1200×1920 @320dpi |
| tablet-10 | Showcase_Tablet_10_API_34 (pixel_tablet) | 1600×2560 @320dpi |

```bash
emulator -avd Pixel_8_Pro_API_34 &          # likewise for the tablets
./scripts/capture_screenshots.sh android phone     emulator-5554
./scripts/capture_screenshots.sh android tablet-7  emulator-5556
./scripts/capture_screenshots.sh android tablet-10 emulator-5558
./scripts/generate_showcase.sh android
```

The script puts System UI into demo mode (09:41, full battery and signal, no
notification icons). The app hides the navigation bar and tablet taskbar, so no
launcher or third-party app icons get into a shot.

## iOS (on the Mac)

Simulators: **iPhone 16 Pro Max** (6.9", 1320×2868), **iPhone 11 Pro Max**
(6.5", 1242×2688, framed onto 1284×2778) and **iPad Pro 13-inch (M4)** (2064×2752).

```bash
xcrun simctl boot "iPhone 16 Pro Max"   # then: xcrun simctl list devices booted
./scripts/capture_screenshots.sh ios iphone-6.9 <udid>
./scripts/capture_screenshots.sh ios iphone-6.5 <udid>
./scripts/capture_screenshots.sh ios ipad-13    <udid>
./scripts/generate_showcase.sh ios
```

Before the first run, allow notifications for Scheduler once in the simulator
(Settings › Notifications), or tap "Allow" when asked. `simctl status_bar`
sets Apple's 9:41 marketing status bar.

## Screens

| # | Android | iOS |
|---|---|---|
| 01 | Home – event cards | Home – event cards *(search result)* |
| 02 | Real reminder notification | Real reminder notification *(search result)* |
| 03 | Create event with reminder | Create event with reminder *(search result)* |
| 04 | Event detail | **Duo** left – event detail |
| 05 | Dark mode + list view | **Duo** right – dark mode list |
| 06 | Settings drawer | Settings drawer |

- **Search screenshots**: App Store search results show the first three portrait
  screenshots, so 01–03 carry the core message.
- **Duo**: 04 and 05 are one panorama split in half. Upload them in this order,
  next to each other.

## Rejection checklist (what the generator already guarantees)

Google Play
- JPEG or 24-bit PNG, **no alpha**. Each side 320–3840 px, and the long side
  at most 2× the short side. Raw Pixel 8 Pro shots (2.23:1) would fail this,
  which is why only the framed 9:16 images are uploaded.
- Phone: 2–8 screenshots, ≥1080 px, for promotion eligibility. 7" and 10" tablet:
  9:16, 1080–7680 px.
- Feature graphic 1024×500, no alpha. Icon 512×512.
- Content: only the real app UI. Frames are a neutral, generic bezel (no
  hardware of any brand). No other apps' icons or brands, no store badges,
  no ranking/price/"best"/"#1"/"free"/"download now" claims.

App Store
- PNG/JPEG, RGB, **no alpha** (App Store Connect rejects alpha), exact pixel sizes
  as listed above. 1–10 per device size. 6.9" is required for iPhone, and
  13" iPad is required because the app runs on iPad.
- Guideline 2.3.3: show the app in use. Every image is a real capture.
- Guideline 2.3.10: no Android devices or references, and no other platforms'
  status bars. iOS images must come from the iOS simulator (status bar, notification
  banner), never from the Android raw set.
- The iOS frame is a plain generic rounded bezel, with no imitation of Apple
  hardware buttons or the Dynamic Island.

All output is opaque 24-bit PNG (the generator writes RGB with no alpha channel).
