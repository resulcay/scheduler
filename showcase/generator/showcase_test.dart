// Generates store screenshots and artwork from the real app UI.
// Run through the script, one process per device:
//
//   ./scripts/generate_showcase.sh android   # phone, 7" + 10" tablet, feature graphic
//   ./scripts/generate_showcase.sh ios       # iPhone 6.9", 6.5", iPad 13", duo (on the Mac)
//
// Output goes to showcase/<platform>/... (see showcase/README.md).
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scheduler/app.dart';
import 'package:scheduler/constants/constant_texts.dart';

import 'artwork.dart';

const platform = String.fromEnvironment(
  'SHOWCASE_PLATFORM',
  defaultValue: 'android',
);
bool get isIos => platform == 'ios';

/// EasyLocalization state leaks between tests, so each device runs in its
/// own `flutter test` process (empty = icons only).
const deviceName = String.fromEnvironment('SHOWCASE_DEVICE');

class Device {
  const Device(this.name, this.canvas, {required this.radius});

  final String name;

  /// Store image size in pixels.
  final Size canvas;

  /// Screen corner radius as a fraction of the screen width.
  final double radius;
}

/// Raw captures come from these emulators/simulators (scripts/capture_screenshots.sh):
/// phone Pixel 8 Pro, tablet-7 1200x1920, tablet-10 1600x2560,
/// iPhone 16 Pro Max (6.9"), iPhone 11 Pro Max (6.5"), iPad Pro 13" (M4).
const androidDevices = [
  Device('phone', Size(1080, 1920), radius: .083),
  Device('tablet-7', Size(1080, 1920), radius: .037),
  Device('tablet-10', Size(1440, 2560), radius: .037),
];

const iosDevices = [
  Device('iphone-6.9', Size(1320, 2868), radius: .125),
  Device('iphone-6.5', Size(1284, 2778), radius: .11),
  Device('ipad-13', Size(2064, 2752), radius: .017),
];

const locales = {'en-US': enLocale, 'tr-TR': trLocale};

/// (headline, subline) per locale.
const captions = <String, Map<String, (String, String)>>{
  'home': {
    'en-US': ('Never miss\nwhat matters', 'All your events in one place'),
    'tr-TR': ('Önemli hiçbir\nşeyi kaçırma', 'Tüm etkinlikleriniz tek yerde'),
  },
  'reminders': {
    'en-US': (
      'Reminders,\nright on time',
      'Before it starts and when it starts',
    ),
    'tr-TR': (
      'Hatırlatmalar\ntam zamanında',
      'Başlamadan önce ve başladığında',
    ),
  },
  'create': {
    'en-US': ('Plan it\nin seconds', 'Title, date, color - done'),
    'tr-TR': ('Saniyeler\niçinde planla', 'Başlık, tarih, renk - hepsi bu'),
  },
  'detail': {
    'en-US': ('Everything\nat a glance', 'Every detail of your event'),
    'tr-TR': ('Her şey\nbir bakışta', 'Etkinliğinizin tüm detayları'),
  },
  'dark': {
    'en-US': ('Easy on\nthe eyes', 'Dark mode and list view'),
    'tr-TR': ('Gözü yormayan\ntasarım', 'Karanlık mod ve liste görünümü'),
  },
  'settings': {
    'en-US': ('Make it\nyours', 'English & Turkish, light & dark'),
    'tr-TR': ('Size göre\nayarlayın', 'Türkçe ve İngilizce, açık ve koyu'),
  },
  'duo': {
    'en-US': ('Stay organized, stay on time', 'Simple. Colorful. Reliable.'),
    'tr-TR': ('Düzenli kal, zamanında ol', 'Basit. Renkli. Güvenilir.'),
  },
  'feature': {
    'en-US': ('Scheduler', 'Events and reminders, right on time'),
    'tr-TR': ('Planlayıcı', 'Etkinlikler ve hatırlatmalar, tam zamanında'),
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  if (deviceName.isEmpty) {
    showcaseTest('app icons', (tester) async {
      final out = isIos ? 'showcase/ios/icon' : 'showcase/android/icon';
      final size = isIos ? 1024.0 : 512.0;
      final icon = await _render(
        tester,
        Size.square(size),
        const CustomPaint(painter: AppIconPainter()),
      );
      await _save(tester, icon, '$out/app-icon-${size.toInt()}.png');
      // The iOS asset catalog needs exactly this opaque 1024 icon.
      final iosIcon = size == 1024
          ? icon
          : await _render(
              tester,
              const Size.square(1024),
              const CustomPaint(painter: AppIconPainter()),
            );
      await _save(
        tester,
        iosIcon,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
      );
    });
  }

  for (final device in (isIos ? iosDevices : androidDevices).where(
    (d) => d.name == deviceName,
  )) {
    for (final lang in locales.keys) {
      showcaseTest('${device.name} $lang', (tester) async {
        final dir = 'showcase/$platform/${device.name}/$lang';
        final raw = 'showcase/raw/$platform/${device.name}/$lang';
        final shots = {
          for (final scene in [
            'home', 'notify', 'create', 'detail', 'dark', 'drawer', //
          ])
            scene: await _load(tester, '$raw/$scene.png'),
        };
        final ui.Image(:width, :height) = shots['home']!;
        final aspect = width / height;
        Future<void> frame(int n, String id, ui.Image screen, int bg) async {
          final (title, sub) = captions[id]![lang]!;
          final image = await _render(
            tester,
            device.canvas,
            _Frame(
              device: device,
              title: title,
              subtitle: sub,
              colors: backgrounds[bg],
              aspect: aspect,
              screens: [screen],
            ),
          );
          await _save(tester, image, '$dir/${'$n'.padLeft(2, '0')}_$id.png');
        }

        await frame(1, 'home', shots['home']!, 0);
        await frame(2, 'reminders', shots['notify']!, 1);
        await frame(3, 'create', shots['create']!, 2);
        if (isIos) {
          // Positions 4+5 form one panorama when swiped in the App Store.
          final (title, sub) = captions['duo']![lang]!;
          final wide = await _render(
            tester,
            Size(device.canvas.width * 2, device.canvas.height),
            _Frame(
              device: device,
              title: title,
              subtitle: sub,
              colors: backgrounds[3],
              aspect: aspect,
              screens: [shots['detail']!, shots['dark']!],
            ),
          );
          final halves = await _split(tester, wide);
          await _save(tester, halves.$1, '$dir/04_duo_left.png');
          await _save(tester, halves.$2, '$dir/05_duo_right.png');
          await frame(6, 'settings', shots['drawer']!, 5);
        } else {
          await frame(4, 'detail', shots['detail']!, 3);
          await frame(5, 'dark', shots['dark']!, 4);
          await frame(6, 'settings', shots['drawer']!, 5);
        }

        if (!isIos && device.name == 'phone') {
          final (title, sub) = captions['feature']![lang]!;
          final graphic = await _render(
            tester,
            const Size(1024, 500),
            _FeatureGraphic(
              title: title,
              subtitle: sub,
              screen: shots['home']!,
            ),
          );
          await _save(
            tester,
            graphic,
            'showcase/android/feature-graphic/$lang.png',
          );
        }
      });
    }
  }
}

/// flutter_test draws elevation as black outlines unless shadows are on;
/// the flag must be restored before the test ends.
void showcaseTest(String name, Future<void> Function(WidgetTester) body) =>
    testWidgets(name, (tester) async {
      debugDisableShadows = false;
      try {
        await body(tester);
      } finally {
        debugDisableShadows = true;
      }
    });

/// A raw capture from scripts/capture_screenshots.sh.
Future<ui.Image> _load(WidgetTester tester, String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    fail('$path is missing - run scripts/capture_screenshots.sh first');
  }
  final image = await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(await file.readAsBytes());
    return (await codec.getNextFrame()).image;
  });
  return image!;
}

Future<ui.Image> _render(WidgetTester tester, Size size, Widget child) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: DefaultTextStyle(
        style: const TextStyle(fontFamily: ConstantText.fontName),
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox.fromSize(size: size, child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await tester.runAsync(() => boundary.toImage());
  tester.view.reset();
  return image!;
}

Future<(ui.Image, ui.Image)> _split(WidgetTester tester, ui.Image wide) async {
  final half = wide.width ~/ 2;
  ui.Image crop(int left) {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawImage(wide, Offset(-left.toDouble(), 0), Paint());
    return recorder.endRecording().toImageSync(half, wide.height);
  }

  return (crop(0), crop(half));
}

Future<void> _save(WidgetTester tester, ui.Image image, String path) => tester
    .runAsync(() async {
      final rgba = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(encodeRgbPng(rgba!, image.width, image.height));
    })
    .then((_) {});

/// flutter test renders unknown fonts as boxes; load the bundled ones and
/// use Righteous for the platform default families too.
Future<void> _loadFonts() async {
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final name = family['family'] as String;
    final assets = [
      for (final f in (family['fonts'] as List).cast<Map<String, dynamic>>())
        f['asset'] as String,
    ];
    for (final alias in [
      name,
      if (name == ConstantText.fontName) ...[
        'Roboto',
        'CupertinoSystemText',
        'CupertinoSystemDisplay',
        '.SF UI Text',
        '.SF UI Display',
      ],
    ]) {
      final loader = FontLoader(alias);
      for (final a in assets) {
        loader.addFont(rootBundle.load(a));
      }
      await loader.load();
    }
  }
}

/// Marketing frame: gradient background, caption, device(s) with the screen.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.device,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.aspect,
    required this.screens,
  });

  final Device device;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final List<ui.Image> screens;

  /// Width / height of the raw captures.
  final double aspect;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        // One "page" is a single store screenshot; duo frames have two.
        final pageW = box.maxWidth / screens.length;
        final h = box.maxHeight;
        final captionH = h * .2;
        final deviceH = h * .7;
        final deviceW = (deviceH * aspect).clamp(0, pageW * .84).toDouble();

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: h * .045,
                height: captionH,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: pageW * .085,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: h * .012),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .85),
                        fontSize: pageW * .042,
                      ),
                    ),
                  ],
                ),
              ),
              for (final (i, screen) in screens.indexed)
                Positioned(
                  left: pageW * i + (pageW - deviceW) / 2,
                  top: h * .045 + captionH + h * .02,
                  width: deviceW,
                  height: deviceW / aspect,
                  child: _DeviceMockup(
                    screen: screen,
                    radius: device.radius * deviceW,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _DeviceMockup extends StatelessWidget {
  const _DeviceMockup({required this.screen, required this.radius});

  final ui.Image screen;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final bezel = radius * .28 + 6;
    return Container(
      padding: EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF111214),
        borderRadius: BorderRadius.circular(radius + bezel),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 40,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: RawImage(
          image: screen,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

/// Google Play feature graphic (1024x500).
class _FeatureGraphic extends StatelessWidget {
  const _FeatureGraphic({
    required this.title,
    required this.subtitle,
    required this.screen,
  });

  final String title;
  final String subtitle;
  final ui.Image screen;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: backgrounds[0]),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: 56,
            top: 0,
            bottom: 0,
            width: 560,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: const SizedBox.square(
                    dimension: 120,
                    child: CustomPaint(painter: AppIconPainter()),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 64),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .9),
                    fontSize: 26,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 70,
            top: 40,
            width: 300,
            height: 300 * screen.height / screen.width,
            child: Transform.rotate(
              angle: .12,
              child: _DeviceMockup(screen: screen, radius: 26),
            ),
          ),
        ],
      ),
    );
  }
}
