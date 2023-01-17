part of 'package:scheduler/main.dart';

class _AppStartConfig {
  lockDeviceUpAndLaunch(bool value) {
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
