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
          child: Padding(
            padding: context.paddingNormalized,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                CustomTextField(
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
                const SizedBox(height: 10),
                CustomTextField(
                  controller: descTextController,
                  hint: "Enter Description",
                  maxLines: 6,
                  textInputAction: TextInputAction.done,
                ),
                Row(
                  children: [
                    const Text("Reminder Notifications"),
                    IconButton(
                      splashRadius: 18,
                      onPressed: () {
                        QuickAlert.show(
                            title: 'Warning',
                            text: 'You will be notified in one-hour periods',
                            context: context,
                            type: QuickAlertType.info);
                      },
                      icon: const Icon(Icons.info),
                    ),
                    customCheckBox(),
                  ],
                ),
                AnimatedSwitcher(
                  duration: const Duration(seconds: 1),
                  child: isChecked ? approachingNotification() : Container(),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                ),
                Row(
                  children: [
                    gradientButton(),
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
                      saveEvent();
                    },
                    child: const Text('Save Event')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
