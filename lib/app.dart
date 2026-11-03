import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/screens/home_screen.dart';
import 'package:scheduler/screens/onboarding_screen.dart';
import 'package:scheduler/stores/event_store.dart';
import 'package:scheduler/stores/settings_store.dart';

const trLocale = Locale('tr', 'TR');
const enLocale = Locale('en', 'US');

Widget localized(Widget child, {Locale? startLocale, bool saveLocale = true}) =>
    EasyLocalization(
      supportedLocales: const [enLocale, trLocale],
      path: 'assets/translations',
      fallbackLocale: enLocale,
      startLocale: startLocale,
      saveLocale: saveLocale,
      child: child,
    );

class SchedulerApp extends StatefulWidget {
  const SchedulerApp({
    super.key,
    required this.settings,
    required this.events,
    this.resyncNotifications = true,
    this.home,
    this.navigatorKey,
  });

  final SettingsStore settings;
  final EventStore events;

  /// Off for screenshot runs, where no notification plugin exists.
  final bool resyncNotifications;

  /// Replaces the start screen (screenshot runs).
  final Widget? home;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<SchedulerApp> createState() => _SchedulerAppState();
}

class _SchedulerAppState extends State<SchedulerApp> {
  Locale? _syncedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Notification texts are localised, so rebuild them on start and on
    // every language switch.
    if (widget.resyncNotifications && _syncedLocale != context.locale) {
      _syncedLocale = context.locale;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.events.resync(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.settings),
        ChangeNotifierProvider.value(value: widget.events),
      ],
      child: Consumer<SettingsStore>(
        builder: (context, settings, _) => MaterialApp(
          navigatorKey: widget.navigatorKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          onGenerateTitle: (_) => LocaleKeys.scheduler.tr(),
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: settings.themeMode,
          home:
              widget.home ??
              (settings.onboardingDone
                  ? const HomeScreen()
                  : const OnboardingScreen()),
        ),
      ),
    );
  }
}

ThemeData buildTheme(Brightness brightness) => ThemeData(
  useMaterial3: true,
  colorSchemeSeed: ConstantColor.normalOrange,
  brightness: brightness,
  fontFamily: ConstantText.fontName,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      // White on the old translucent orange was unreadable (~2:1 contrast).
      backgroundColor: ConstantColor.deepTeal,
      foregroundColor: ConstantColor.pureWhite,
      textStyle: const TextStyle(
        fontSize: 15,
        fontFamily: ConstantText.fontName,
      ),
    ),
  ),
);
