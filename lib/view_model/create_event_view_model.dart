import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:scheduler/components/date_time_selection.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/media_query_extension.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/color_provider.dart';
import 'package:scheduler/providers/date_time_provider.dart';
import 'package:scheduler/services/event_service.dart';
import 'package:scheduler/view/create_event_screen.dart';

abstract class CreateEventViewModel extends State<CreateEventScreen> {
  late TextEditingController titleTextController;
  late TextEditingController descTextController;
  late EventService eventService;
  final formKey = GlobalKey<FormState>();
  late Color pickerColor;

  @override
  void initState() {
    titleTextController = TextEditingController();
    descTextController = TextEditingController();
    eventService = EventService();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    pickerColor = Provider.of<ColorProvider>(context, listen: true).color;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    titleTextController.dispose();
    descTextController.dispose();
    super.dispose();
  }

  Future<dynamic> pickColor(BuildContext context, Color pickerColor) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        const List<Color> colors = [
          Colors.red,
          Colors.pink,
          Colors.purple,
          Colors.deepPurple,
          Colors.indigo,
          Colors.blue,
          Colors.lightBlue,
          Colors.cyan,
          Colors.teal,
          Colors.green,
          Colors.lightGreen,
          Colors.lime,
          Colors.yellow,
          Colors.amber,
          Colors.orange,
          Colors.deepOrange,
          Colors.brown,
          Colors.grey,
          Colors.blueGrey,
          Colors.indigoAccent,
        ];
        return AlertDialog(
          title: const Text('Colors'),
          content: BlockPicker(
            availableColors: colors,
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
        );
      },
    );
  }

  saveEvent(dynamic pickerColor) {
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

  Future<dynamic> pickDateTime(BuildContext context) {
    return showModalBottomSheet(
      barrierColor: Colors.black12.withOpacity(.5),
      backgroundColor: ConstantColor.pureWhite,
      constraints: BoxConstraints(
        minHeight: 100,
        maxHeight: context.height * .95,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(60),
      ),
      context: context,
      builder: (context) => const DateTimeSelection(),
    );
  }
}
