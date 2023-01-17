import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/single_child_widget.dart';

import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/date_time_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/event_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/list_type_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/onboarding_step_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/theme_provider.dart';
import 'package:scheduler/services/list_type_service.dart';
import 'package:scheduler/services/theme_service.dart';
import 'package:scheduler/view/home_screen.dart';
import 'package:scheduler/view/onboarding_screen.dart';

part 'package:scheduler/providers/list_of_app_providers.dart';
part 'package:scheduler/app_start_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(EventModelAdapter());
  ThemeService().read();
  var onboardingBox = await Hive.openBox(ConstantText.onboardingBoxName);
  bool isOnboardingDone = onboardingBox.values.isNotEmpty;
  _AppStartConfig().lockDeviceUpAndLaunch(isOnboardingDone);
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
              brightness:
                  themeService.isDark ? Brightness.dark : Brightness.light,
              primarySwatch: Colors.blueGrey,
              fontFamily: ConstantText.fontName,
            ),
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
