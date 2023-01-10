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

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
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
            const SizedBox(height: 100),
            Material(
              color: ConstantColor.darkBrown,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () async {
                  selectDateTime(context);
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
}

selectDateTime(BuildContext context) {
  DatePicker.showDateTimePicker(
    locale: LocaleType.en,
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
