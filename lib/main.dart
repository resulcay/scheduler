import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/single_child_widget.dart';
import 'package:scheduler/constants/constant_colors.dart';

import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/date_time_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/event_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/list_type_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/onboarding_step_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/rate_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/theme_provider.dart';
import 'package:scheduler/services/event_service.dart';
import 'package:scheduler/services/firebase_analytics.dart';
import 'package:scheduler/services/list_type_service.dart';
import 'package:scheduler/services/localization.dart';
import 'package:scheduler/services/rate_service.dart';
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
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            onGenerateTitle: (context) => LocaleKeys.scheduler.tr(),
            debugShowCheckedModeBanner: false,
            navigatorObservers: [AnalyticsService.observer],
            theme: _ThemeConfiguration().lightTheme(),
            darkTheme: _ThemeConfiguration().darkTheme(),
            themeMode: themeService.isDark ? ThemeMode.dark : ThemeMode.light,
            home: isOnboardingDone
                ? const HomeScreen()
                : const OnboardingScreen(),
            routes: {
              ConstantText.mainRoute: (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
