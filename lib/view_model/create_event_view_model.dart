import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:scheduler/components/date_time_selection.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/providers/stand_alone_providers/date_time_provider.dart';
import 'package:scheduler/services/event_service.dart';
import 'package:scheduler/view/create_event_screen.dart';

abstract class CreateEventViewModel extends State<CreateEventScreen> {
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
  bool isTimerChecked = false;
  bool isNotificationChecked = false;

  @override
  void initState() {
    titleTextController = TextEditingController();
    descTextController = TextEditingController();
    eventService = EventService();
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
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      context: context,
      builder: (context) => const DateTimeSelection(),
    );
  }

  void saveEvent() {
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (formKey.currentState!.validate()) {
        EventModel model = EventModel(
          eventTitle: titleTextController.text,
          eventDescription: descTextController.text,
          eventDate:
              Provider.of<DateTimeProvider>(context, listen: false).eventDate,
          color: pickerColor.toString(),
        );

        eventService.storeEvent(model);

        if (isTimerChecked) {
          FlutterAlarmClock.createTimer(
            differenceAsSecond,
            title: titleTextController.text,
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

  Widget customTimerCheckBox() {
    return Checkbox(
      value: isTimerChecked,
      activeColor: Colors.indigo,
      onChanged: (value) {
        setState(() {
          isTimerChecked = value ?? false;
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
}
