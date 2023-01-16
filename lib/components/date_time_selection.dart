import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../constants/constant_colors.dart';
import '../constants/constant_texts.dart';
import '../providers/date_time_provider.dart';
import '../services/local_notification_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateTimeSelection extends StatefulWidget {
  const DateTimeSelection({super.key});

  @override
  State<DateTimeSelection> createState() => _DateTimeSelectionState();
}

class _DateTimeSelectionState extends State<DateTimeSelection> {
  late final NotificationApi notificationApi;

  @override
  void initState() {
    // dismiss keyboard after search in case of active.
    FocusManager.instance.primaryFocus?.unfocus();
    Intl.defaultLocale = 'en_US';
    notificationApi = NotificationApi(context: context);
    notificationApi.initApi();
    initializeDateFormatting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime eventDate = Provider.of<DateTimeProvider>(context).eventDate;

    String eventTimeAsHourAndMinute = DateFormat.Hm().format(eventDate);
    String eventTimeAsDayMonthYear =
        DateFormat.yMMMEd('en_EN').format(eventDate);

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
            onTap: () async {
              selectDateTime(context, eventDate);
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
      ],
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
}

selectDateTime(BuildContext context, DateTime eventDate) {
  showModalBottomSheet(
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
