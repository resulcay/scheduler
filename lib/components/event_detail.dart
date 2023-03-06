import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/media_query_extension.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/services/event_service.dart';

class EventDetail extends StatelessWidget {
  final EventModel eventModel;
  final List<String> values;

  const EventDetail({
    super.key,
    required this.eventModel,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    EventService eventService = EventService();
    Color backgroundColor = Color(int.parse(values[2]));
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarColor: backgroundColor),
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
                      eventModel.eventDescription ?? 'No Description',
                      style: const TextStyle(
                        color: ConstantColor.pureWhite,
                        fontWeight: FontWeight.w200,
                        fontSize: 15,
                      ),
                    ),
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
              padding: context.paddingLarge,
              child: IconButton(
                onPressed: () {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.warning,
                    confirmBtnText: 'Yes',
                    text: 'Are you sure ?',
                    onConfirmBtnTap: () async {
                      Navigator.pop(context);
                      await eventService
                          .deleteEventById(eventModel.id)
                          .then((_) {
                        Navigator.pop(context);
                      });
                    },
                  );
                },
                icon: const Icon(
                  Icons.delete,
                  size: 35,
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
