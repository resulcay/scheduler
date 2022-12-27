import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/screens/reminder_screen.dart';
import 'package:scheduler/providers/onboarding_step_provider.dart';
import 'package:scheduler/providers/time_range_provider.dart';
import 'package:scheduler/screens/onboarding_screen.dart';

import 'constants/constant_texts.dart';

void main() async {
  await Hive.initFlutter();
  var onboardingBox = await Hive.openBox(ConstantText.onboardingBoxName);
  // onboardingBox.put(ConstantText.onboardingBoxKeyName, false);
  bool isOnboardingDone = onboardingBox.values.isNotEmpty;

  WidgetsFlutterBinding.ensureInitialized();

  // Lock device to vertical orientation.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then(
    (_) => runApp(
      MyApp(
        isOnboardingDone: isOnboardingDone,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isOnboardingDone;
  const MyApp({super.key, required this.isOnboardingDone});
  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => OnboardingStepProvider()),
          ChangeNotifierProvider(create: (_) => TimeRangeProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Scheduler',
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            fontFamily: ConstantText.fontName,
          ),
          home: isOnboardingDone
              ? const ReminderScreen()
              : const OnboardingScreen(),
          routes: {
            'main': (context) => const ReminderScreen(),
          },
        ),
      );
}
