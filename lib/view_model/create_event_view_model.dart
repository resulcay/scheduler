import 'package:alarm/alarm.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/date_time_provider.dart';
import 'package:scheduler/services/alarm_service.dart';
import 'package:scheduler/services/event_service.dart';
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
    Intl.defaultLocale = 'en_US';
    notificationApi = NotificationApi(context: context);
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
    eventTimeAsDayMonthYear = DateFormat.yMMMEd('en_EN').format(eventDate);

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
        title: const Text('Colors'),
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
            child: const Text("OK"),
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

  Widget customTimerCheckBox() {
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
          child: const Text('Chose Event Color')),
    );
  }

  Widget dateTimePicking() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          textAlign: TextAlign.center,
          'Selected Date and Time\n$eventTimeAsHourAndMinute\n$eventTimeAsDayMonthYear',
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 24,
            height: 1.4,
          ),
        ),
        Material(
          color: ConstantColor.darkBrown,
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
              child: const Center(
                child: Text(
                  "Pick",
                  style: TextStyle(
                    color: ConstantColor.pureWhite,
                    fontWeight: FontWeight.w400,
                    fontSize: 36,
                  ),
                ),
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
          locale: const Locale('en', 'US'),
          type: DateTimePickerType.dateTimeSeparate,
          dateMask: 'd MMM, yyyy',
          initialValue: eventDate.toString(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          icon: const Icon(Icons.event),
          dateLabelText: 'Date',
          timeLabelText: 'Hour',
          onChanged: (value) {
            DateTime date = DateTime.parse(value);
            if (date.isBefore(DateTime.now())) {
              QuickAlert.show(
                  onConfirmBtnTap: () {
                    Navigator.pop(context);
                  },
                  context: context,
                  type: QuickAlertType.error,
                  title: 'Invalid Date or Time',
                  text: 'Date or Time must be before current!');
            } else {
              Provider.of<DateTimeProvider>(context, listen: false)
                  .changeTimeRange(date);

              QuickAlert.show(
                  onConfirmBtnTap: () {
                    Navigator.pop(context);
                  },
                  context: context,
                  type: QuickAlertType.success,
                  title: 'Success',
                  text: 'Date and time are adjusted!');
            }
          },
        );
      },
    );
  }

  void _invalidPeriod() {
    SnackBar errorMessage = const SnackBar(content: Text('Invalid period'));
    ScaffoldMessenger.of(context).showSnackBar(errorMessage);
  }

  void saveEvent() {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (formKey.currentState!.validate()) {
        EventModel model = EventModel(
          eventTitle: titleTextController.text.trim(),
          eventDescription: descTextController.text,
          eventDate: eventDate,
          color: pickerColor.toString(),
        );

        eventService.storeEvent(model);

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
                    payload: 'payload example',
                  );
                } else if (current.isBefore(assumedDate)) {
                  for (int i = periodInitialValue; i > 0; --i) {
                    notificationApi.showScheduledNotification(
                      id: i,
                      title: model.eventTitle,
                      body: '$i hour(s) left',
                      date: eventDate.subtract(Duration(hours: i)),
                      payload: 'payload exx',
                    );
                  }
                } else {
                  _invalidPeriod();
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
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
                  return;
                }
                break;
              // week
              case 'w':
                var assumedDate =
                    eventDate.subtract(Duration(days: periodInitialValue * 7));

                if (current.isBefore(assumedDate)) {
                  notificationApi.showScheduledNotification(
                    id: 0,
                    title: model.eventTitle,
                    body: '$periodInitialValue week(s) left',
                    date: assumedDate,
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
                  return;
                }
                break;
              // month
              case 'm':
                var assumedDate =
                    eventDate.subtract(Duration(days: periodInitialValue * 30));

                if (current.isBefore(assumedDate)) {
                  notificationApi.showScheduledNotification(
                    id: 0,
                    title: model.eventTitle,
                    body: '$periodInitialValue month(s) left',
                    date: assumedDate,
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
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
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
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
                    payload: 'payload example',
                  );
                } else if (current.isBefore(assumedDate)) {
                  for (int i = periodInitialValue; i > 0; --i) {
                    notificationApi.showScheduledNotification(
                      id: i,
                      title: model.eventTitle,
                      body: '$i saat kaldı',
                      date: eventDate.subtract(Duration(hours: i)),
                      payload: 'payload exx',
                    );
                  }
                } else {
                  _invalidPeriod();
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
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
                  return;
                }
                break;
              // week
              case 'h':
                var assumedDate =
                    eventDate.subtract(Duration(days: periodInitialValue * 7));

                if (current.isBefore(assumedDate)) {
                  notificationApi.showScheduledNotification(
                    id: 0,
                    title: model.eventTitle,
                    body: '$periodInitialValue hafta kaldı',
                    date: assumedDate,
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
                  return;
                }
                break;
              // month
              case 'a':
                var assumedDate =
                    eventDate.subtract(Duration(days: periodInitialValue * 30));

                if (current.isBefore(assumedDate)) {
                  notificationApi.showScheduledNotification(
                    id: 0,
                    title: model.eventTitle,
                    body: '$periodInitialValue ay kaldı',
                    date: assumedDate,
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
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
                    payload: 'payload exx',
                  );
                } else {
                  _invalidPeriod();
                  return;
                }
                break;
              default:
            }
          }
        }

        if (isAlarmChecked) {
          Alarm.set(
            alarmDateTime: eventDate,
            assetAudio: "assets/sounds/alert_in_hall.mp3",
            notifTitle: 'Alarm notification',
            notifBody: 'Your alarm is ringing',
            loopAudio: true,
            onRing: () {
              AlarmService().write(true);
            },
          );
        }

        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Success',
            text: 'Successfully Saved!');

        titleTextController.clear();
        descTextController.clear();
      }
    } catch (e) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: 'Unexpected Error Occurred!');
    }
  }
}
