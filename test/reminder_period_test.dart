import 'package:flutter_test/flutter_test.dart';
import 'package:scheduler/models/reminder_period.dart';

void main() {
  final now = DateTime(2026, 11, 3, 9);
  final event = DateTime(2026, 11, 10, 18, 30);

  group('planNotifications', () {
    test('always notifies at the event time', () {
      final plan = planNotifications(eventId: 7, eventDate: event, now: now);
      expect(plan, hasLength(1));
      expect(plan.single.id, 700);
      expect(plan.single.date, event);
      expect(plan.single.unit, isNull);
    });

    test('adds one advance reminder for a single period', () {
      final plan = planNotifications(
        eventId: 7,
        eventDate: event,
        period: ReminderPeriod.day2,
        now: now,
      );
      expect(plan.map((n) => n.id), [700, 701]);
      expect(plan[1].date, DateTime(2026, 11, 8, 18, 30));
      expect((plan[1].amount, plan[1].unit), (2, ReminderUnit.day));
    });

    test('hourly periods fire every hour up to the event', () {
      final plan = planNotifications(
        eventId: 3,
        eventDate: event,
        period: ReminderPeriod.hour3Hourly,
        now: now,
      );
      expect(plan.map((n) => n.id), [300, 303, 302, 301]);
      expect(plan.skip(1).map((n) => n.date), [
        DateTime(2026, 11, 10, 15, 30),
        DateTime(2026, 11, 10, 16, 30),
        DateTime(2026, 11, 10, 17, 30),
      ]);
      expect(plan.skip(1).map((n) => n.amount), [3, 2, 1]);
    });

    test('drops reminders that are already in the past', () {
      final soon = now.add(const Duration(hours: 2));
      final plan = planNotifications(
        eventId: 1,
        eventDate: soon,
        period: ReminderPeriod.hour6Hourly,
        now: now,
      );
      // 6h..2h before are past; only "1 hour left" and the event remain.
      expect(plan.map((n) => n.id), [100, 101]);
      expect(planNotifications(eventId: 1, eventDate: now, now: now), isEmpty);
    });

    test('ids belong to their event and are unique within it', () {
      for (final p in [null, ...ReminderPeriod.values]) {
        final plan = planNotifications(
          eventId: 42,
          eventDate: DateTime(2030),
          period: p,
          now: now,
        );
        expect(plan.map((n) => n.id ~/ slotsPerEvent).toSet(), {42});
        expect(plan.map((n) => n.id).toSet(), hasLength(plan.length));
      }
    });

    test('ids stay inside 32-bit range for large event ids', () {
      final plan = planNotifications(
        eventId: 20000000,
        eventDate: event,
        period: ReminderPeriod.hour6Hourly,
        now: now,
      );
      expect(plan.every((n) => n.id < 0x7fffffff), isTrue);
    });
  });

  group('ReminderPeriod', () {
    test('is available only while its first reminder is in the future', () {
      final event = now.add(const Duration(hours: 5));
      expect(ReminderPeriod.hour3.isAvailableFor(event, now), isTrue);
      expect(ReminderPeriod.hour6.isAvailableFor(event, now), isFalse);
      expect(ReminderPeriod.day1.isAvailableFor(event, now), isFalse);
    });

    test('lead durations', () {
      expect(ReminderPeriod.week1.lead, const Duration(days: 7));
      expect(ReminderPeriod.month3.lead, const Duration(days: 90));
      expect(ReminderPeriod.year1.lead, const Duration(days: 365));
    });

    test('tryParse round-trips names and rejects junk', () {
      for (final p in ReminderPeriod.values) {
        expect(ReminderPeriod.tryParse(p.name), p);
      }
      expect(ReminderPeriod.tryParse(null), isNull);
      expect(ReminderPeriod.tryParse('last 1 hour'), isNull);
    });
  });
}
