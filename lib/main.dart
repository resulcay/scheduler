import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_alarm_background_trigger/flutter_alarm_background_trigger.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/single_child_widget.dart';

import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/stand_alone_providers/alarm_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/date_time_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/event_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/list_type_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/onboarding_step_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/theme_provider.dart';
import 'package:scheduler/services/alarm_service.dart';
import 'package:scheduler/services/list_type_service.dart';
import 'package:scheduler/services/local_notification_service.dart';
import 'package:scheduler/services/theme_service.dart';
import 'package:scheduler/view/home_screen.dart';
import 'package:scheduler/view/onboarding_screen.dart';
import 'package:workmanager/workmanager.dart';
part 'package:scheduler/providers/list_of_app_providers.dart';
part 'package:scheduler/app_start_config.dart';

// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     // print("Native called background task : ");
//     await Alarm.set(
//       alarmDateTime: DateTime.now().add(
//         const Duration(seconds: 10),
//       ),
//       assetAudio: "assets/sounds/alert_in_hall.mp3",
//       notifTitle: 'Alarm notification',
//       notifBody: 'Your alarm is ringing',
//       loopAudio: false,
//       onRing: () {
//         print('Alarm ringed');
//       },
//     );
//     return Future.value(true);
//   });
// }

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
