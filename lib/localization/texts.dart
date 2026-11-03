import 'package:easy_localization/easy_localization.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/models/reminder_period.dart';

String describeNotification(PlannedNotification n) => switch (n.unit) {
  null => LocaleKeys.eventStartsNow.tr(),
  ReminderUnit.hour => LocaleKeys.leftHour.plural(n.amount),
  ReminderUnit.day => LocaleKeys.leftDay.plural(n.amount),
  ReminderUnit.week => LocaleKeys.leftWeek.plural(n.amount),
  ReminderUnit.month => LocaleKeys.leftMonth.plural(n.amount),
  ReminderUnit.year => LocaleKeys.leftYear.plural(n.amount),
};

String reminderChannelName() => LocaleKeys.reminderChannelName.tr();

String reminderLabel(ReminderPeriod? p) => switch (p) {
  null => LocaleKeys.atEventTime.tr(),
  ReminderPeriod(hourly: true) => LocaleKeys.periodHourly.tr(
    args: ['${p.amount}'],
  ),
  _ => switch (p.unit) {
    ReminderUnit.hour => LocaleKeys.periodHour.plural(p.amount),
    ReminderUnit.day => LocaleKeys.periodDay.plural(p.amount),
    ReminderUnit.week => LocaleKeys.periodWeek.plural(p.amount),
    ReminderUnit.month => LocaleKeys.periodMonth.plural(p.amount),
    ReminderUnit.year => LocaleKeys.periodYear.plural(p.amount),
  },
};

/// e.g. `14:30 - Tue, Nov 3, 2026`.
String formatEventDate(DateTime date, String locale) =>
    '${DateFormat.Hm(locale).format(date)} - '
    '${DateFormat.yMMMEd(locale).format(date)}';
