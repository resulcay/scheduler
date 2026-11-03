import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/components/decorated_text_field.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/localization/texts.dart';
import 'package:scheduler/models/reminder_period.dart';
import 'package:scheduler/services/notification_service.dart';
import 'package:scheduler/stores/event_store.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({
    super.key,
    this.initialDate,
    this.initialTitle,
    this.initialDescription,
    this.initialNotify = false,
    this.initialReminder,
    this.initialColor,
    this.notifications,
  });

  /// Prefill hooks for screenshot runs.
  final DateTime? initialDate;
  final String? initialTitle;
  final String? initialDescription;
  final bool initialNotify;
  final ReminderPeriod? initialReminder;
  final Color? initialColor;
  final NotificationService? notifications;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.initialTitle);
  late final _description = TextEditingController(
    text: widget.initialDescription,
  );
  late DateTime _date =
      widget.initialDate ??
      _wholeMinute(DateTime.now().add(const Duration(hours: 5)));
  late Color _color =
      widget.initialColor ??
      ConstantColor.colorList[Random().nextInt(ConstantColor.colorList.length)];
  late bool _notify = widget.initialNotify;
  late ReminderPeriod? _reminder = widget.initialReminder;
  bool _alarm = false;
  bool _saving = false;

  NotificationService get _notifications =>
      widget.notifications ?? NotificationService.instance;

  static DateTime _wholeMinute(DateTime d) =>
      DateTime(d.year, d.month, d.day, d.hour, d.minute);

  List<ReminderPeriod> get _availableReminders => ReminderPeriod.values
      .where((p) => p.isAvailableFor(_date, DateTime.now()))
      .toList();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _pickDateTime() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(now) ? now : _date,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 10),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(
      day.year,
      day.month,
      day.day,
      time.hour,
      time.minute,
    );
    if (!picked.isAfter(DateTime.now())) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: LocaleKeys.invalidDateOrTime.tr(),
        text: LocaleKeys.dateOrTimeMustBe.tr(),
        confirmBtnText: LocaleKeys.confirmOk.tr(),
      );
      return;
    }
    setState(() {
      _date = picked;
      // A reminder that would now be in the past cannot fire.
      if (_reminder != null && !_availableReminders.contains(_reminder)) {
        _reminder = null;
      }
    });
  }

  Future<void> _toggleNotify(bool? value) async {
    if (value != true) {
      setState(() => _notify = false);
      return;
    }
    if (!await _notifications.requestPermission()) {
      if (mounted) _snack(LocaleKeys.notificationsDenied.tr());
      return;
    }
    if (!mounted) return;
    setState(() => _notify = true);
    if (!await _notifications.canScheduleExact() && mounted) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.info,
        title: LocaleKeys.exactAlarmTitle.tr(),
        text: LocaleKeys.exactAlarmText.tr(),
        confirmBtnText: LocaleKeys.allow.tr(),
        cancelBtnText: LocaleKeys.later.tr(),
        showCancelBtn: true,
        onConfirmBtnTap: () {
          Navigator.pop(context);
          _notifications.requestExactAlarms();
        },
      );
    }
  }

  void _pickColor() {
    FocusManager.instance.primaryFocus?.unfocus();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.colors.tr()),
        content: BlockPicker(
          availableColors: ConstantColor.colorList,
          pickerColor: _color,
          onColorChanged: (c) {
            setState(() => _color = c);
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_saving || !_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    if (!_date.isAfter(now)) {
      _snack(LocaleKeys.dateOrTimeMustBe.tr());
      return;
    }
    // The system alarm only takes hour:minute, so it must be within a day.
    if (_alarm && _date.difference(now) > const Duration(hours: 24)) {
      _snack(LocaleKeys.alarmOnlyWithin24h.tr());
      return;
    }
    setState(() => _saving = true);
    final event = await context.read<EventStore>().add(
      title: _title.text.trim(),
      description: _description.text.trim(),
      date: _date,
      color: _color.toARGB32().toRadixString(16).padLeft(8, '0'),
      notify: _notify,
      reminder: _notify ? _reminder?.name : null,
    );
    if (_alarm) {
      FlutterAlarmClock.createAlarm(
        hour: _date.hour,
        minutes: _date.minute,
        title: event.eventTitle,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();
    final infoStyle = Theme.of(context).textTheme.bodySmall;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(Icons.chevron_left_outlined, size: 40),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: context.paddingNormalized,
            children: [
              CustomTextField(
                controller: _title,
                hint: LocaleKeys.enterTitle.tr(),
                maxLines: 1,
                textInputAction: TextInputAction.next,
                function: (text) => (text ?? '').trim().isEmpty
                    ? LocaleKeys.canNotBeEmpty.tr()
                    : null,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _description,
                hint: LocaleKeys.enterDescription.tr(),
                maxLines: 5,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event, size: 30),
                title: Text(LocaleKeys.selectedDateAndTime.tr()),
                subtitle: Text(
                  formatEventDate(_date, locale),
                  style: const TextStyle(fontSize: 18),
                ),
                trailing: ElevatedButton(
                  onPressed: _pickDateTime,
                  child: Text(LocaleKeys.pick.tr()),
                ),
              ),
              const Divider(),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.notifications_active, size: 30),
                title: Text(LocaleKeys.notifyMe.tr()),
                subtitle: Text(
                  LocaleKeys.youWillBeNotified.tr(),
                  style: infoStyle,
                ),
                value: _notify,
                onChanged: _toggleNotify,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _notify
                    ? DropdownButtonFormField<ReminderPeriod?>(
                        initialValue: _reminder,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: LocaleKeys.notification.tr(),
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final p in [null, ..._availableReminders])
                            DropdownMenuItem(
                              value: p,
                              child: Text(reminderLabel(p)),
                            ),
                        ],
                        onChanged: (p) => setState(() => _reminder = p),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              // Android's clock app is the only system alarm we can set.
              if (defaultTargetPlatform == TargetPlatform.android) ...[
                const Divider(),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.alarm, size: 30),
                  title: Text(LocaleKeys.setAlarm.tr()),
                  subtitle: Text(
                    LocaleKeys.activatesSystemsAlarm.tr(),
                    style: infoStyle,
                  ),
                  value: _alarm,
                  onChanged: (v) => setState(() => _alarm = v ?? false),
                ),
              ],
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(radius: 18, backgroundColor: _color),
                title: Text(LocaleKeys.choseEventColor.tr()),
                onTap: _pickColor,
                trailing: const Icon(Icons.palette_outlined),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(LocaleKeys.saveEvent.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
