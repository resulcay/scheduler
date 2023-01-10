import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/components/decorated_text_field.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/view_model/create_event_view_model.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends CreateEventViewModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
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
                  // onPressed: () async {
                  //   await Future.delayed(Duration.zero, () {
                  //     Navigator.of(context).pushAndRemoveUntil(
                  //         MaterialPageRoute(
                  //           builder: (context) => const DateTimeSelection(),
                  //         ),
                  //         (route) => false);
                  //   });
                  // },
                  onPressed: () {
                    showCustomModalBottomSheet(context);
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
                    QuickAlert.show(
                        title: 'Are you sure?',
                        text: 'All data will be deleted!',
                        confirmBtnText: 'Yes',
                        onConfirmBtnTap: () {
                          eventService.deleteAllEvents();
                          Navigator.pop(context);
                        },
                        context: context,
                        type: QuickAlertType.warning);
                  },
                  child: const Text('Delete All Events')),
              ElevatedButton(
                  onPressed: () {
                    saveEvent(pickerColor);
                  },
                  child: const Text('Save Event')),
            ],
          ),
        ),
      ),
    );
  }
}
