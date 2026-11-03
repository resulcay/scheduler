// The real app, remote-controlled by test_driver/screenshots_test.dart to
// take store screenshots. Run through scripts/capture_screenshots.sh.
import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scheduler/app.dart';
import 'package:scheduler/localization/texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/models/reminder_period.dart';
import 'package:scheduler/screens/create_event_screen.dart';
import 'package:scheduler/screens/event_detail_screen.dart';
import 'package:scheduler/screens/home_screen.dart';
import 'package:scheduler/services/notification_service.dart';
import 'package:scheduler/stores/event_store.dart';
import 'package:scheduler/stores/settings_store.dart';

/// (title, description, days ahead, hour, minute, color, reminder)
const demoEvents = {
  'en-US': [
    (
      'Dentist appointment',
      'Bring the insurance card. Dr. Aydin, room 4.',
      1,
      10,
      30,
      'ff009688',
      ReminderPeriod.hour1,
    ),
    (
      'Team meeting',
      'Quarterly planning with the product team.',
      1,
      14,
      0,
      'ff3f51b5',
      ReminderPeriod.hour3Hourly,
    ),
    (
      'Gym session',
      'Leg day and 20 minutes of cardio.',
      2,
      18,
      0,
      'ffff9800',
      null,
    ),
    (
      'Flight to Istanbul',
      'Gate closes 30 minutes before departure.',
      6,
      7,
      45,
      'ffe91e63',
      ReminderPeriod.day1,
    ),
    (
      'Project deadline',
      'Send the final report to the client.',
      10,
      17,
      0,
      'ff9c27b0',
      ReminderPeriod.day2,
    ),
  ],
  'tr-TR': [
    (
      'Diş hekimi randevusu',
      'Sigorta kartını unutma. Dr. Aydın, 4 numaralı oda.',
      1,
      10,
      30,
      'ff009688',
      ReminderPeriod.hour1,
    ),
    (
      'Ekip toplantısı',
      'Ürün ekibiyle çeyrek dönem planlaması.',
      1,
      14,
      0,
      'ff3f51b5',
      ReminderPeriod.hour3Hourly,
    ),
    (
      'Spor salonu',
      'Bacak günü ve 20 dakika kardiyo.',
      2,
      18,
      0,
      'ffff9800',
      null,
    ),
    (
      'İstanbul uçuşu',
      'Kapı kalkıştan 30 dakika önce kapanır.',
      6,
      7,
      45,
      'ffe91e63',
      ReminderPeriod.day1,
    ),
    (
      'Proje teslimi',
      'Final raporunu müşteriye gönder.',
      10,
      17,
      0,
      'ff9c27b0',
      ReminderPeriod.day2,
    ),
  ],
};

final _nav = GlobalKey<NavigatorState>();
late SettingsStore _settings;
late EventStore _events;
final _plugin = FlutterLocalNotificationsPlugin();

/// The driver can connect before main() has opened the stores.
final _ready = Completer<void>();

Future<void> main() async {
  enableFlutterDriverExtension(handler: (command) => _handle(command!));
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting();
  // Own folder so the user's real events on the device stay untouched.
  await Hive.initFlutter('showcase');
  Hive.registerAdapter(EventModelAdapter());
  await NotificationService.instance.init();
  _settings = await SettingsStore.open();
  await _settings.completeOnboarding();
  _events = await EventStore.open(NotificationService.instance);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // No navigation bar / tablet taskbar: its launcher icons show other brands.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
  runApp(
    localized(
      SchedulerApp(
        settings: _settings,
        events: _events,
        resyncNotifications: false,
        navigatorKey: _nav,
        home: const HomeScreen(askForRating: false),
      ),
      startLocale: enLocale,
      saveLocale: false,
    ),
  );
  // Android: pre-granted by the script. iOS simulator: tap "Allow" once.
  await NotificationService.instance.requestPermission();
  _ready.complete();
}

/// Commands: `locale:<lang>` (also seeds demo events), `home`, `notify`,
/// `create`, `detail`, `dark`, `drawer`.
Future<String> _handle(String command) async {
  await _ready.future;
  // MaterialApp is built only once the translations have loaded.
  while (_nav.currentState == null) {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  final [name, ...args] = command.split(':');
  late final first = _events.events.first;
  switch (name) {
    case 'locale':
      final lang = args.single;
      await _nav.currentContext!.setLocale(
        lang == 'tr-TR' ? trLocale : enLocale,
      );
      await _seed(lang);
      await _settings.setDark(false);
      await _settings.setStackedList(true);
    case 'home':
      _show(const HomeScreen(askForRating: false));
    case 'notify':
      _show(const HomeScreen(askForRating: false));
      await _realReminder(first);
      // Capture while the heads-up banner is still on screen.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      return 'ok';
    case 'create':
      await _plugin.cancelAll();
      // iOS keeps the banner up ~8 s even after the notification is removed.
      if (Platform.isIOS) {
        await Future<void>.delayed(const Duration(seconds: 10));
      }
      _show(
        CreateEventScreen(
          initialDate: first.eventDate,
          initialTitle: first.eventTitle,
          initialDescription: first.eventDescription,
          initialNotify: true,
          initialReminder: ReminderPeriod.hour1,
          initialColor: Colors.teal,
        ),
      );
    case 'detail':
      _show(EventDetailScreen(event: first));
    case 'dark':
      await _settings.setDark(true);
      await _settings.setStackedList(false);
      _show(const HomeScreen(askForRating: false));
    case 'drawer':
      _show(const HomeScreen(askForRating: false, drawerOpen: true));
    default:
      throw ArgumentError('unknown command $command');
  }
  // Route, theme and translation changes settle within this.
  await Future<void>.delayed(const Duration(milliseconds: 1500));
  return 'ok';
}

void _show(Widget screen) => _nav.currentState!.pushAndRemoveUntil(
  PageRouteBuilder<void>(
    pageBuilder: (_, _, _) => screen,
    transitionDuration: Duration.zero,
  ),
  (_) => false,
);

Future<void> _seed(String lang) async {
  await _events.deleteAll();
  final today = DateTime.now();
  for (final (title, desc, days, h, m, color, reminder) in demoEvents[lang]!) {
    await _events.add(
      title: title,
      description: desc,
      date: DateTime(today.year, today.month, today.day + days, h, m),
      color: color,
      notify: true,
      reminder: reminder?.name,
    );
  }
  // Only the reminder posted for the "notify" shot may show up.
  await NotificationService.instance.cancelAll();
}

/// Schedules a real "1 hour left" reminder a few seconds ahead and returns
/// once the system has posted it, so the shot shows the OS banner.
Future<void> _realReminder(EventModel like) async {
  const id = 900;
  await NotificationService.instance.scheduleEvent(
    EventModel(
      id: id,
      eventTitle: like.eventTitle,
      eventDate: DateTime.now().add(const Duration(hours: 1, seconds: 4)),
      color: like.color,
      notify: true,
      reminder: ReminderPeriod.hour1.name,
    ),
    describe: describeNotification,
    channelName: reminderChannelName(),
  );
  for (var i = 0; i < 60; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final active = await _plugin.getActiveNotifications();
    if (active.any((n) => (n.id ?? -1) ~/ slotsPerEvent == id)) {
      // The event-time slot is an hour away; drop it.
      await NotificationService.instance.cancelEvent(id);
      return;
    }
  }
  throw StateError('reminder was never posted');
}
