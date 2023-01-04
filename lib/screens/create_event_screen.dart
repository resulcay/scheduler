import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/extensions/media_query_extension.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/color_provider.dart';
import 'package:scheduler/providers/date_time_provider.dart';
import 'package:scheduler/services/event_service.dart';

import '../components/date_time_selection.dart';
import '../components/decorated_text_field.dart';
import '../constants/constant_colors.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  late TextEditingController titleTextController;
  late TextEditingController descTextController;
  late EventService eventService;
  @override
  void initState() {
    titleTextController = TextEditingController();
    descTextController = TextEditingController();
    eventService = EventService();

    super.initState();
  }

  @override
  void dispose() {
    titleTextController.dispose();
    descTextController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Color pickerColor = Provider.of<ColorProvider>(context, listen: true).color;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: context.paddingNormalized,
                child: CustomTextField(
                  function: (text) {
                    if (text == null || text.isEmpty) {
                      return 'Can not be Empty';
                    }
                    return null;
                  },
                  controller: titleTextController,
                  hint: "Enter Title *",
                  maxLines: 1,
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: context.paddingNormalized,
                child: CustomTextField(
                  controller: descTextController,
                  hint: "Enter Description",
                  maxLines: 6,
                  textInputAction: TextInputAction.done,
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
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
                  },
                  child: const Text('Select Date and Time')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        pickColor(context, pickerColor);
                      },
                      child: const Text('Chose Color')),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: pickerColor,
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    eventService.deleteAllEvents();
                  },
                  child: const Text('Delete All Events')),
              ElevatedButton(
                  onPressed: () {
                    _saveEvent(pickerColor);
                  },
                  child: const Text('Save Event')),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> pickColor(BuildContext context, Color pickerColor) {
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
          Colors.black,
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

  _saveEvent(dynamic pickerColor) {
    try {
      if (_formKey.currentState!.validate()) {
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
}
