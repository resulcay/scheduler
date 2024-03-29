part of 'package:scheduler/main.dart';

class _AppProviders {
  final List<SingleChildWidget> providers = [
    ChangeNotifierProvider(create: (_) => OnboardingStepProvider()),
    ChangeNotifierProvider(create: (_) => DateTimeProvider()),
    ChangeNotifierProvider(create: (_) => ColorProvider()),
    ChangeNotifierProvider(create: (_) => EventProvider()),
    ChangeNotifierProvider(create: (_) => EventService()),
    ChangeNotifierProvider(create: (_) => ListTypeService()),
    ChangeNotifierProvider(create: (_) => ListTypeProvider()),
    ChangeNotifierProvider(create: (_) => RateProvider()),
    ChangeNotifierProvider(create: (_) => RateService()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => ThemeService()),
  ];
}
