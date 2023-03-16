import 'package:date_time_picker/date_time_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/date_time_provider.dart';
import 'package:scheduler/services/event_service.dart';
import 'package:scheduler/services/firebase_analytics.dart';
import 'package:scheduler/services/local_notification_service.dart';
import 'package:scheduler/view/create_event_screen.dart';

abstract class CreateEventViewModel extends State<CreateEventScreen> {
  late final NotificationApi notificationApi;
  final formKey = GlobalKey<FormState>();
  late TextEditingController titleTextController;
  late TextEditingController descTextController;
  late String eventTimeAsHourAndMinute;
  late String eventTimeAsDayMonthYear;
  late EventService eventService;
  late Color pickerColor;
  late DateTime currentDate;
  late DateTime eventDate;
  late int differenceAsHour;
  late int differenceAsSecond;
  bool isAlarmChecked = false;
  bool isNotificationChecked = false;
  String period = '';

  @override
  void initState() {
    titleTextController = TextEditingController();
    descTextController = TextEditingController();
    eventService = EventService();
    notificationApi = NotificationApi();
    notificationApi.initApi();
    initializeDateFormatting();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    pickerColor = Provider.of<ColorProvider>(context).color;
    eventDate = Provider.of<DateTimeProvider>(context).eventDate;
    currentDate = DateTime.now();
    differenceAsHour = eventDate.difference(currentDate).inHours;
    differenceAsSecond = eventDate.difference(currentDate).inSeconds;
    eventTimeAsHourAndMinute = DateFormat.Hm().format(eventDate);
    eventTimeAsDayMonthYear = widget.isLocale
        ? DateFormat.yMMMEd('en_EN').format(eventDate)
        : DateFormat.yMMMEd('tr_TR').format(eventDate);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    titleTextController.dispose();
    descTextController.dispose();

    super.dispose();
  }

  Future<dynamic> pickColor() {
    FocusManager.instance.primaryFocus?.unfocus();
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(LocaleKeys.colors).tr(),
        content: BlockPicker(
          availableColors: ConstantColor.colorList,
          pickerColor: pickerColor,
          onColorChanged: (value) {
            Provider.of<ColorProvider>(context, listen: false)
                .changeColor(value);
          },
        ),
        actions: [
          TextButton(
            child: const Text(LocaleKeys.ok).tr(),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> showCustomModalBottomSheet() {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      context: context,
      builder: (context) => dateTimePicking(),
    );
  }

  Widget customAlarmCheckBox() {
    return Checkbox(
      value: isAlarmChecked,
      activeColor: Colors.indigo,
      onChanged: (value) {
        setState(() {
          isAlarmChecked = value ?? false;
        });
      },
    );
  }

  Widget customNotificationCheckBox() {
    return Checkbox(
      value: isNotificationChecked,
      activeColor: Colors.indigo,
      onChanged: (value) {
        setState(() {
          isNotificationChecked = value ?? false;
        });
      },
    );
  }

  Widget gradientButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: ConstantColor.colorList,
        ),
        color: Colors.deepPurple.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            minimumSize: MaterialStateProperty.all(const Size(50, 50)),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
          ),
          onPressed: () => pickColor(),
          child: const Text(LocaleKeys.choseEventColor).tr()),
    );
  }

  Widget dateTimePicking() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          textAlign: TextAlign.center,
          '${LocaleKeys.selectedDateAndTime.tr()}\n$eventTimeAsHourAndMinute\n$eventTimeAsDayMonthYear',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 24,
            height: 1.4,
          ),
        ),
        Material(
          color: ConstantColor.deepTeal,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () async => selectDateTime(),
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              height: 50,
              width: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: const Text(
                  LocaleKeys.pick,
                  style: TextStyle(
                    color: ConstantColor.pureWhite,
                    fontWeight: FontWeight.w400,
                    fontSize: 36,
                  ),
                ).tr(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> selectDateTime() {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return DateTimePicker(
          locale: context.locale,
          type: DateTimePickerType.dateTimeSeparate,
          dateMask: 'd MMM, yyyy',
          initialValue: eventDate.toString(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          icon: const Icon(Icons.event),
          dateLabelText: LocaleKeys.date.tr(),
          timeLabelText: LocaleKeys.time.tr(),
          onChanged: (value) {
            DateTime date = DateTime.parse(value);
            if (date.isBefore(DateTime.now())) {
              QuickAlert.show(
                confirmBtnText: LocaleKeys.confirmOk.tr(),
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                },
                context: context,
                type: QuickAlertType.error,
                title: LocaleKeys.invalidDateOrTime.tr(),
                text: LocaleKeys.dateOrTimeMustBe.tr(),
              );
            } else {
              Provider.of<DateTimeProvider>(context, listen: false)
                  .changeTimeRange(date);

              QuickAlert.show(
                onConfirmBtnTap: () {
                  Navigator.pop(context);
                },
                context: context,
                type: QuickAlertType.success,
                title: LocaleKeys.success.tr(),
                text: LocaleKeys.dateAndTimeAreAdjusted.tr(),
                confirmBtnText: LocaleKeys.confirmOk.tr(),
              );
            }
          },
        );
      },
    );
  }

  void _invalidConfigForCheckBox(String snackBarMessage) {
    SnackBar errorMessage = SnackBar(content: Text(snackBarMessage));
    ScaffoldMessenger.of(context).showSnackBar(errorMessage);
  }

  void saveEvent() {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (formKey.currentState!.validate()) {
        eventService.getAllEvents().then((value) async {
          EventModel model = EventModel(
            id: value.length,
            eventTitle: titleTextController.text.trim(),
            eventDescription: descTextController.text.trim(),
            eventDate: eventDate,
            color: pickerColor.toString(),
          );

          if (isNotificationChecked) {
            ///
            /// for English period initials. (last ...)
            ///
            if (period.startsWith('l')) {
              DateTime current = DateTime.now();
              String periodInitial = period[7];
              int periodInitialValue = int.parse(period[5]);

              switch (periodInitial) {
                // hour
                case 'h':
                  var assumedDate =
                      eventDate.subtract(Duration(hours: periodInitialValue));

                  if (current.isBefore(assumedDate) && period.length < 12) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue hour(s) left',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else if (current.isBefore(assumedDate)) {
                    for (int i = periodInitialValue; i > 0; --i) {
                      notificationApi.showScheduledNotification(
                        id: i,
                        title: model.eventTitle,
                        body: '$i hour(s) left',
                        date: eventDate.subtract(Duration(hours: i)),
                        payload: 'payload',
                      );
                    }
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }

                  break;
                // day
                case 'd':
                  var assumedDate =
                      eventDate.subtract(Duration(days: periodInitialValue));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue day(s) left',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                // week
                case 'w':
                  var assumedDate = eventDate
                      .subtract(Duration(days: periodInitialValue * 7));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue week(s) left',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                // month
                case 'm':
                  var assumedDate = eventDate
                      .subtract(Duration(days: periodInitialValue * 30));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue month(s) left',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                // year
                case 'y':
                  var assumedDate = eventDate
                      .subtract(Duration(days: periodInitialValue * 365));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue year left',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                default:
              }
            }

            ///
            /// for Turkish period initials. (son ...)
            ///
            if (period.startsWith('s')) {
              DateTime current = DateTime.now();
              String periodInitial = period[6];
              int periodInitialValue = int.parse(period[4]);

              switch (periodInitial) {
                // hour
                case 's':
                  var assumedDate =
                      eventDate.subtract(Duration(hours: periodInitialValue));

                  if (current.isBefore(assumedDate) && period.length < 12) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue saat kaldı',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else if (current.isBefore(assumedDate)) {
                    for (int i = periodInitialValue; i > 0; --i) {
                      notificationApi.showScheduledNotification(
                        id: i,
                        title: model.eventTitle,
                        body: '$i saat kaldı',
                        date: eventDate.subtract(Duration(hours: i)),
                        payload: 'payload',
                      );
                    }
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }

                  break;
                // day
                case 'g':
                  var assumedDate =
                      eventDate.subtract(Duration(days: periodInitialValue));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue gün kaldı',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                // week
                case 'h':
                  var assumedDate = eventDate
                      .subtract(Duration(days: periodInitialValue * 7));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue hafta kaldı',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                // month
                case 'a':
                  var assumedDate = eventDate
                      .subtract(Duration(days: periodInitialValue * 30));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue ay kaldı',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                // year
                case 'y':
                  var assumedDate = eventDate
                      .subtract(Duration(days: periodInitialValue * 365));

                  if (current.isBefore(assumedDate)) {
                    notificationApi.showScheduledNotification(
                      id: 0,
                      title: model.eventTitle,
                      body: '$periodInitialValue yıl kaldı',
                      date: assumedDate,
                      payload: 'payload',
                    );
                  } else {
                    _invalidConfigForCheckBox(LocaleKeys.invalidPeriod.tr());
                    return;
                  }
                  break;
                default:
              }
            }
          }

          if (isAlarmChecked) {
            if (DateTime.now().isBefore(eventDate)) {
              FlutterAlarmClock.createAlarm(
                eventDate.hour,
                eventDate.minute,
                title: model.eventTitle,
              );
            } else {
              _invalidConfigForCheckBox(LocaleKeys.invalidAlarm.tr());
              return;
            }
          }

          eventService.storeEvent(model);

          AnalyticsService.analytics.logEvent(name: "event_store", parameters: {
            "event_id": model.id.toString(),
            "event_date": model.eventDate.toString(),
            "event_alarm": isAlarmChecked.toString(),
            "event_notification": isNotificationChecked.toString(),
          });

          setState(() {
            isNotificationChecked = false;
            isAlarmChecked = false;
            titleTextController.clear();
            descTextController.clear();
          });

          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: LocaleKeys.success.tr(),
            confirmBtnText: LocaleKeys.confirmOk.tr(),
            text: LocaleKeys.successfullySaved.tr(),
          );
        });
      }
    } catch (e) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: LocaleKeys.error.tr(),
        confirmBtnText: LocaleKeys.confirmOk.tr(),
        text: LocaleKeys.unExpectedErrorOccurred.tr(),
      );
    }
  }
}
