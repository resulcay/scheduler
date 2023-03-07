import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/single_child_widget.dart';
import 'package:scheduler/constants/constant_colors.dart';

import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/date_time_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/event_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/list_type_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/onboarding_step_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/theme_provider.dart';
import 'package:scheduler/services/list_type_service.dart';
import 'package:scheduler/services/local_notification_service.dart';
import 'package:scheduler/services/theme_service.dart';
import 'package:scheduler/view/home_screen.dart';
import 'package:scheduler/view/onboarding_screen.dart';
part 'package:scheduler/providers/list_of_app_providers.dart';
part 'package:scheduler/app_start_config.dart';

void main() async {
  _AppStartConfig().launchConfig();
}

class MyApp extends StatelessWidget {
  final bool isOnboardingDone;

  const MyApp({
    super.key,
    required this.isOnboardingDone,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _AppProviders().providers,
      child: Consumer<ThemeService>(
        builder: (_, themeService, __) {
          return MaterialApp(
            localizationsDelegates: const [
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('tr', 'TR'),
            ],
            debugShowCheckedModeBanner: false,
            title: 'Scheduler',
            theme: ThemeData(
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
            ),
            darkTheme: ThemeData(
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
            ),
            themeMode: themeService.isDark ? ThemeMode.dark : ThemeMode.light,
            home: isOnboardingDone
                ? const HomeScreen()
                : const OnboardingScreen(),
            routes: {
              'main': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
