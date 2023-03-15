import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/media_query_extension.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/services/event_service.dart';

class EventDetail extends StatelessWidget {
  final EventService eventService;
  final List<String> values;

  const EventDetail({
    super.key,
    required this.eventService,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    final eventModel = ModalRoute.of(context)!.settings.arguments as EventModel;
    Color backgroundColor = Color(int.parse(values[2]));
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: context.paddingExtraLow,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: context.paddingLow,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: ConstantColor.deepTeal),
                ),
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: ConstantColor.elegantBlack),
                  child: const Icon(
                    Icons.chevron_left_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: backgroundColor,
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: context.paddingLow,
        child: Column(
          children: [
            SizedBox(
              height: context.height * .5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    eventModel.eventTitle,
                    style: const TextStyle(
                      color: ConstantColor.pureWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: context.paddingLow,
                    child: Text(
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      eventModel.eventDescription!.isEmpty
                          ? LocaleKeys.noDescription
                          : eventModel.eventDescription ?? "",
                      style: const TextStyle(
                        color: ConstantColor.pureWhite,
                        fontWeight: FontWeight.w200,
                        fontSize: 15,
                      ),
                    ).tr(),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      '${values[0]} - ${values[1]}',
                      style: const TextStyle(
                        color: ConstantColor.pureWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: context.paddingNormal,
              child: IconButton(
                onPressed: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    title: LocaleKeys.delete.tr(),
                    confirmBtnText: LocaleKeys.yes.tr(),
                    text: LocaleKeys.areYouSure.tr(),
                    onConfirmBtnTap: () async {
                      Navigator.pop(context);
                      await Future.delayed(const Duration(milliseconds: 200))
                          .then((_) => Navigator.pop(context));
                      await eventService.deleteEventById(eventModel.id);
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  size: 40,
                  color: ConstantColor.pureWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
