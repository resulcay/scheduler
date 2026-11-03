enum ReminderUnit { hour, day, week, month, year }

/// How long before an event the advance reminder fires.
enum ReminderPeriod {
  hour1(1, ReminderUnit.hour),
  hour2(2, ReminderUnit.hour),
  hour3(3, ReminderUnit.hour),
  hour3Hourly(3, ReminderUnit.hour, hourly: true),
  hour6(6, ReminderUnit.hour),
  hour6Hourly(6, ReminderUnit.hour, hourly: true),
  hour9(9, ReminderUnit.hour),
  day1(1, ReminderUnit.day),
  day2(2, ReminderUnit.day),
  day3(3, ReminderUnit.day),
  week1(1, ReminderUnit.week),
  month1(1, ReminderUnit.month),
  month3(3, ReminderUnit.month),
  month6(6, ReminderUnit.month),
  year1(1, ReminderUnit.year);

  const ReminderPeriod(this.amount, this.unit, {this.hourly = false});

  final int amount;
  final ReminderUnit unit;

  /// Repeat every hour from [lead] until the event instead of firing once.
  final bool hourly;

  Duration get lead => switch (unit) {
    ReminderUnit.hour => Duration(hours: amount),
    ReminderUnit.day => Duration(days: amount),
    ReminderUnit.week => Duration(days: 7 * amount),
    ReminderUnit.month => Duration(days: 30 * amount),
    ReminderUnit.year => Duration(days: 365 * amount),
  };

  /// The first reminder must still be in the future.
  bool isAvailableFor(DateTime eventDate, DateTime now) =>
      eventDate.subtract(lead).isAfter(now);

  static ReminderPeriod? tryParse(String? name) =>
      ReminderPeriod.values.where((p) => p.name == name).firstOrNull;
}

class PlannedNotification {
  const PlannedNotification({
    required this.id,
    required this.date,
    this.amount = 0,
    this.unit,
  });

  final int id;
  final DateTime date;

  /// Time left until the event; [unit] is null for the "starts now" one.
  final int amount;
  final ReminderUnit? unit;
}

/// Each event owns notification ids `eventId * slotsPerEvent + 0..99`.
const slotsPerEvent = 100;

/// One notification at the event time plus the advance reminder(s);
/// anything already in the past is dropped.
List<PlannedNotification> planNotifications({
  required int eventId,
  required DateTime eventDate,
  ReminderPeriod? period,
  required DateTime now,
}) {
  final base = eventId * slotsPerEvent;
  return [
    PlannedNotification(id: base, date: eventDate),
    if (period != null && period.hourly)
      for (var h = period.amount; h > 0; h--)
        PlannedNotification(
          id: base + h,
          date: eventDate.subtract(Duration(hours: h)),
          amount: h,
          unit: ReminderUnit.hour,
        )
    else if (period != null)
      PlannedNotification(
        id: base + 1,
        date: eventDate.subtract(period.lead),
        amount: period.amount,
        unit: period.unit,
      ),
  ].where((n) => n.date.isAfter(now)).toList();
}
