// Host side of the screenshot run: drives test_driver/screenshots.dart and
// grabs full-screen shots with adb / simctl into showcase/raw/.
// Env (set by scripts/capture_screenshots.sh): SHOT_PLATFORM, SHOT_DEVICE,
// SHOT_SERIAL.
import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';

const scenes = ['home', 'notify', 'create', 'detail', 'dark', 'drawer'];
const languages = ['en-US', 'tr-TR'];

Future<void> main() async {
  final env = Platform.environment;
  final platform = env['SHOT_PLATFORM']!;
  final device = env['SHOT_DEVICE']!;
  final serial = env['SHOT_SERIAL']!;
  final driver = await FlutterDriver.connect();

  Future<void> capture(String path) async {
    await File(path).parent.create(recursive: true);
    if (platform == 'ios') {
      final r = await Process.run('xcrun', [
        'simctl', 'io', serial, 'screenshot', path, //
      ]);
      if (r.exitCode != 0) throw Exception(r.stderr);
    } else {
      final r = await Process.run('adb', [
        '-s', serial, 'exec-out', 'screencap', '-p', //
      ], stdoutEncoding: null);
      if (r.exitCode != 0) throw Exception(r.stderr);
      await File(path).writeAsBytes(r.stdout as List<int>);
    }
  }

  try {
    for (final lang in languages) {
      await driver.requestData('locale:$lang');
      for (final scene in scenes) {
        await driver.requestData(scene);
        final path = 'showcase/raw/$platform/$device/$lang/$scene.png';
        await capture(path);
        stdout.writeln('captured $path');
      }
    }
  } finally {
    await driver.close();
  }
}
