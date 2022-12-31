import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/extensions/media_query_extension.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/models/event_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: context.paddingLarge,
              child: CustomTextField(
                controller: titleTextController,
                hint: "Enter Title",
                maxLines: 1,
                textInputAction: TextInputAction.next,
              ),
            ),
            Padding(
              padding: context.paddingLarge,
              child: CustomTextField(
                controller: descTextController,
                hint: "Enter Description",
                maxLines: 8,
                textInputAction: TextInputAction.done,
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  // dismiss keyboard after search in case of active.
                  FocusManager.instance.primaryFocus?.unfocus();
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
            ElevatedButton(
                onPressed: () {
                  EventModel model = EventModel(
                      eventTitle: titleTextController.text,
                      eventDescription: descTextController.text,
                      eventDate:
                          Provider.of<DateTimeProvider>(context, listen: false)
                              .eventDate);

                  eventService.storeEvent(model);
                },
                child: const Text('Save Event'))
          ],
        ),
      ),
    );
  }
}
