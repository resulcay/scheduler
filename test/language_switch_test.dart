import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:scheduler/app.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/screens/home_screen.dart';
import 'package:scheduler/services/notification_service.dart';
import 'package:scheduler/stores/event_store.dart';
import 'package:scheduler/stores/settings_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SettingsStore settings;
  late EventStore events;

  setUpAll(() async {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    Hive.init((await Directory.systemTemp.createTemp('lang')).path);
    Hive.registerAdapter(EventModelAdapter());
    settings = await SettingsStore.open();
    events = EventStore(
      await Hive.openBox<EventModel>(ConstantText.eventBoxName),
      NotificationService(),
    );
  });

  /// Lets translation assets load in real time.
  Future<void> settle(WidgetTester tester, Finder until) async {
    for (var i = 0; i < 100 && until.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  testWidgets('switching language updates the settings drawer instantly', (
    tester,
  ) async {
    await tester.pumpWidget(
      localized(
        SchedulerApp(
          settings: settings,
          events: events,
          resyncNotifications: false,
          home: const HomeScreen(askForRating: false, drawerOpen: true),
        ),
        startLocale: enLocale,
        saveLocale: false,
      ),
    );
    await settle(tester, find.text('Dark Mode'));
    expect(find.text('Dark Mode'), findsOneWidget);
    expect(find.text('There is no Event at the moment'), findsOneWidget);

    await tester.tap(find.text('TR'));
    await settle(tester, find.text('Karanlık Mod'));

    for (final label in [
      'Karanlık Mod',
      'Dil',
      'Paylaş',
      'Şuan hiç etkinlik yok',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('Dark Mode'), findsNothing);
  });
}
