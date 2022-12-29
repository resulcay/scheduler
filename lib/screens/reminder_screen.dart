import 'package:f_datetimerangepicker/f_datetimerangepicker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/constant_colors.dart';
import '../constants/constant_texts.dart';
import '../providers/time_range_provider.dart';
import '../services/local_notification_service.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime startTime =
        Provider.of<TimeRangeProvider>(context, listen: true).startTime;

    String startTimeAsHourAndMinute = DateFormat.Hm().format(startTime);

    DateTime endTime =
        Provider.of<TimeRangeProvider>(context, listen: true).endTime;
    String endTimeAsHourAndMinute = DateFormat.Hm().format(endTime);

    int notificationCount = endTime.difference(startTime).inHours;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'You will be notified $notificationCount times.',
              style: const TextStyle(
                color: ConstantColor.pureBlack,
                fontWeight: FontWeight.w400,
                fontSize: 24,
                fontFamily: ConstantText.fontName,
              ),
            ),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: 'From ',
                style: const TextStyle(
                  color: ConstantColor.pureBlack,
                  fontWeight: FontWeight.w400,
                  fontSize: 23,
                  fontFamily: ConstantText.fontName,
                ),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        timePicker(context, startTime, endTime);
                      },
                    text:
                        '$startTimeAsHourAndMinute  ${startTime.year}-${startTime.month}-${startTime.day}',
                    style: const TextStyle(
                      color: ConstantColor.normalYellow,
                      fontWeight: FontWeight.w400,
                      fontSize: 23,
                      fontFamily: ConstantText.fontName,
                    ),
                  ),
                  const TextSpan(text: ' \nto '),
                  TextSpan(
                    text:
                        '$endTimeAsHourAndMinute  ${endTime.year}-${endTime.month}-${endTime.day}',
                    style: const TextStyle(
                      color: ConstantColor.normalYellow,
                      fontWeight: FontWeight.w400,
                      fontSize: 23,
                      fontFamily: ConstantText.fontName,
                    ),
                  ),
                  //const TextSpan(text: ' today'),
                ],
              ),
            ),
            Material(
              color: ConstantColor.darkBrown,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () async {
                  for (var i = 0; i < notificationCount; i++) {
                    await notificationApi.showScheduledNotification(
                      id: i,
                      title: 'title $i',
                      body: 'body $i',
                      hours: i,
                      payload: 'payload $i',
                    );
                  }

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text("Notification Setup"),
                        content: const Text('Notifications adjusted!'),
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
          if (!end.isAfter(start)) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Time Selection Error"),
                  content: const Text('End time must be after Start Time!'),
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
            Provider.of<TimeRangeProvider>(context, listen: false)
                .changeTimeRange(start, end);
          }
        }).showPicker(context);
  }
}
