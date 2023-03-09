part of 'package:scheduler/main.dart';

class _AppStartConfig {
  launchConfig() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
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
        EasyLocalization(
          supportedLocales: const [
            LocaleConstant.trLocale,
            LocaleConstant.engLocale
          ],
          path: LocaleConstant.TRANSLATION_PATH,
          fallbackLocale: LocaleConstant.engLocale,
          child: MyApp(
            isOnboardingDone: value,
          ),
        ),
      ),
    );
  }
}

class _ThemeConfiguration {
  ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ConstantColor.normalOrange,
      brightness: Brightness.light,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            ConstantColor.normalOrange.withOpacity(.6),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            ConstantColor.pureWhite,
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              fontSize: 15,
              fontFamily: ConstantText.fontName,
            ),
          ),
        ),
      ),
      fontFamily: ConstantText.fontName,
    );
  }

  ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ConstantColor.normalOrange,
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
            ConstantColor.normalOrange.withOpacity(.3),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(
            ConstantColor.pureWhite,
          ),
          textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              fontSize: 15,
              fontFamily: ConstantText.fontName,
            ),
          ),
        ),
      ),
      fontFamily: ConstantText.fontName,
    );
  }
}
