import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/components/period_drop_down_menu.dart';
import 'package:scheduler/components/alarm_section.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: context.paddingNormalized,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  CustomTextField(
                    function: (text) {
                      text = text?.trim();
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
                      const Text("Set Alarm"),
                      IconButton(
                        splashRadius: 18,
                        onPressed: () {
                          QuickAlert.show(
                            title: 'Warning',
                            text:
                                "Activates system's alarm app. Deletions must be done manually.",
                            context: context,
                            type: QuickAlertType.info,
                          );
                        },
                        icon: const Icon(Icons.info),
                      ),
                      customAlarmCheckBox(),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: isAlarmChecked
                        ? AlarmSection(
                            iconData: Icons.alarm,
                            function: () => selectDateTime(),
                            widget: Text(
                              textAlign: TextAlign.center,
                              'Fires at\n$eventTimeAsHourAndMinute\n$eventTimeAsDayMonthYear',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Container(),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                  Row(
                    children: [
                      const Text("Notify Me"),
                      IconButton(
                        splashRadius: 18,
                        onPressed: () {
                          QuickAlert.show(
                              title: 'Warning',
                              text: 'You will be notified on given period(s)',
                              context: context,
                              type: QuickAlertType.info);
                        },
                        icon: const Icon(Icons.info),
                      ),
                      customNotificationCheckBox(),
                    ],
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: isNotificationChecked
                        ? AlarmSection(
                            iconData: Icons.calendar_month,
                            function: () => showCustomModalBottomSheet(),
                            widget: PeriodDropDownMenu(
                              dateTime: eventDate,
                              onPeriodSelected: (String value) {
                                period = value;
                              },
                            ),
                          )
                        : Container(),
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
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: context.paddingSymmetricNormalized,
              child: ElevatedButton(
                onPressed: () {
                  saveEvent();
                },
                child: const Text('Save Event'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
