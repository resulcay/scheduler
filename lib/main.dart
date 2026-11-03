import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:scheduler/app.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/services/notification_service.dart';
import 'package:scheduler/stores/event_store.dart';
import 'package:scheduler/stores/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await initializeDateFormatting();
  // Same directory (app documents) that <= 1.0.5 used, so data is kept.
  await Hive.initFlutter();
  Hive.registerAdapter(EventModelAdapter());
  try {
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }
  final settings = await SettingsStore.open();
  final events = await EventStore.open(NotificationService.instance);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(localized(SchedulerApp(settings: settings, events: events)));
}
