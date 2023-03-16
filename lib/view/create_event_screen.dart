import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/components/period_drop_down_menu.dart';
import 'package:scheduler/components/alarm_section.dart';
import 'package:scheduler/components/decorated_text_field.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/view_model/create_event_view_model.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key, required this.isLocale});
  final bool isLocale;

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends CreateEventViewModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.chevron_left_outlined,
            size: 40,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
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
                        return LocaleKeys.canNotBeEmpty.tr();
                      }
                      return null;
                    },
                    controller: titleTextController,
                    hint: LocaleKeys.enterTitle.tr(),
                    maxLines: 1,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 10),
                  CustomTextField(
                    controller: descTextController,
                    hint: LocaleKeys.enterDescription.tr(),
                    maxLines: 6,
                    textInputAction: TextInputAction.done,
                  ),
                  Row(
                    children: [
                      const Text(LocaleKeys.setAlarm).tr(),
                      IconButton(
                        splashRadius: 18,
                        onPressed: () => QuickAlert.show(
                          title: LocaleKeys.alarm.tr(),
                          text: LocaleKeys.activatesSystemsAlarm.tr(),
                          confirmBtnText: LocaleKeys.confirmOk.tr(),
                          context: context,
                          type: QuickAlertType.info,
                        ),
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
                              '${LocaleKeys.firesAt.tr()}\n$eventTimeAsHourAndMinute\n$eventTimeAsDayMonthYear',
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
                      const Text(LocaleKeys.notifyMe).tr(),
                      IconButton(
                        splashRadius: 18,
                        onPressed: () => QuickAlert.show(
                            title: LocaleKeys.notification.tr(),
                            text: LocaleKeys.youWillBeNotified.tr(),
                            confirmBtnText: LocaleKeys.confirmOk.tr(),
                            context: context,
                            type: QuickAlertType.info),
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
                              isEnglish: widget.isLocale,
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
                  const SizedBox(height: 40),
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
                child: const Text(LocaleKeys.saveEvent).tr(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
