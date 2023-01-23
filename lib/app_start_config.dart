part of 'package:scheduler/main.dart';

class _AppStartConfig {
  launchConfig() async {
    WidgetsFlutterBinding.ensureInitialized();
    Alarm.init();
    Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    Hive.registerAdapter(EventModelAdapter());
    ThemeService().read();
    var onboardingBox = await Hive.openBox(ConstantText.onboardingBoxName);
    bool isOnboardingDone = onboardingBox.values.isNotEmpty;

    lockDeviceUpAndLaunch(isOnboardingDone);
  }

  static lockDeviceUpAndLaunch(bool value) {
    ///
    /// Lock device to vertical orientation.
    ///
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
      (_) => runApp(
        MyApp(
          isOnboardingDone: value,
        ),
      ),
    );
  }
}
