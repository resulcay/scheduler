import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/color_provider.dart';
import 'package:scheduler/providers/event_provider.dart';
import 'package:scheduler/screens/home_screen.dart';
import 'package:scheduler/providers/onboarding_step_provider.dart';
import 'package:scheduler/providers/date_time_provider.dart';
import 'package:scheduler/screens/onboarding_screen.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import 'constants/constant_texts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Directory directory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.registerAdapter(EventModelAdapter());

  var onboardingBox = await Hive.openBox(ConstantText.onboardingBoxName);
  bool isOnboardingDone = onboardingBox.values.isNotEmpty;

  _lockDeviceUpAndLaunch(isOnboardingDone);
}

class MyApp extends StatelessWidget {
  final bool isOnboardingDone;
  const MyApp({super.key, required this.isOnboardingDone});
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: _providers,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Scheduler',
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            fontFamily: ConstantText.fontName,
          ),
          home:
              isOnboardingDone ? const HomeScreen() : const OnboardingScreen(),
          routes: {
            'main': (context) => const HomeScreen(),
          },
        ),
      );
}

_lockDeviceUpAndLaunch(bool value) {
  // Lock device to vertical orientation.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
    (_) => runApp(
      MyApp(
        isOnboardingDone: value,
      ),
    ),
  );
}

List<SingleChildWidget> _providers = [
  ChangeNotifierProvider(create: (_) => OnboardingStepProvider()),
  ChangeNotifierProvider(create: (_) => DateTimeProvider()),
  ChangeNotifierProvider(create: (_) => ColorProvider()),
  ChangeNotifierProvider(create: (_) => EventProvider()),
];
