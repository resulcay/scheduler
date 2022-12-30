import 'package:f_datetimerangepicker/f_datetimerangepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../constants/constant_colors.dart';
import '../constants/constant_texts.dart';
import '../providers/date_time_provider.dart';
import '../services/local_notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  late final NotificationApi notificationApi;

  @override
  void initState() {
    notificationApi = NotificationApi(context: context);
    notificationApi.initApi();
    initializeDateFormatting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime eventDate =
        Provider.of<DateTimeProvider>(context, listen: true).eventDate;

    String eventTimeAsHourAndMinute = DateFormat.Hm().format(eventDate);
    String eventTimeAsDayMonthYear =
        DateFormat.yMMMEd('tr_TR').format(eventDate);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              textAlign: TextAlign.center,
              'Selected Date and Time\n$eventTimeAsHourAndMinute\n$eventTimeAsDayMonthYear',
              style: const TextStyle(
                color: ConstantColor.pureBlack,
                fontWeight: FontWeight.w400,
                fontSize: 24,
                fontFamily: ConstantText.fontName,
              ),
            ),
            Material(
              color: ConstantColor.darkBrown,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () async {
                  _selectDateTime(context);
                },
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
                        fontFamily: ConstantText.fontName,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: ConstantColor.darkBrown,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("DateTime Setup"),
                        content: const Text('Date and time are adjusted!'),
                        actions: [
                          TextButton(
                            child: const Text("OK"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
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
                      "Save",
                      style: TextStyle(
                        color: ConstantColor.pureWhite,
                        fontWeight: FontWeight.w400,
                        fontSize: 36,
                        fontFamily: ConstantText.fontName,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> dateAdjusted(
      BuildContext context, String title, String text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  timePicker(BuildContext context, DateTime startTime, DateTime endTime) async {
    DateTimeRangePicker(
        startText: "From",
        endText: "To",
        doneText: "Yes",
        cancelText: "Cancel",
        interval: 1,
        initialStartTime: startTime,
        initialEndTime: endTime,
        mode: DateTimeRangePickerMode.dateAndTime,
        minimumTime: DateTime.now().subtract(const Duration(hours: 1)),
        maximumTime: DateTime.now().add(const Duration(days: 10)),
        use24hFormat: false,
        onConfirm: (start, end) {
          if (!start.isAfter(DateTime.now())) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Time Selection Error"),
                  content: const Text('Start time must be after Now!'),
                  actions: [
                    TextButton(
                      child: const Text("OK"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
          if (end.isAfter(start) && start.isAfter(DateTime.now())) {
            // Provider.of<TimeRangeProvider>(context, listen: false)
            //     .changeTimeRange(start, end);
          }
        }).showPicker(context);
  }
}

Future<void> _selectDateTime(BuildContext context) async {
  await DatePicker.showDateTimePicker(
    locale: LocaleType.tr,
    context,
    onConfirm: (time) {
      if (time.isBefore(DateTime.now())) {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Error',
            text: 'Date or time must be before now!');
      } else {
        Provider.of<DateTimeProvider>(context, listen: false)
            .changeTimeRange(time);

        QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Success',
            text: 'Date and time are adjusted!');
      }
    },
  );
}
