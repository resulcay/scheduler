import 'package:flutter/material.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final Color color;
  final DateTime eventDate;
  const EventCard(
      {Key? key,
      required this.title,
      required this.description,
      required this.date,
      required this.color,
      required this.eventDate})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOutOfDate = eventDate.isAfter(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: context.paddingLow,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isOutOfDate ? Colors.grey : color,
          border: Border.all(
            color: Theme.of(context).disabledColor,
            width: 2,
          )),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            title,
            style: const TextStyle(
              color: ConstantColor.pureWhite,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 35),
            child: Text(
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              description,
              style: const TextStyle(
                color: ConstantColor.pureWhite,
                fontWeight: FontWeight.w200,
                fontSize: 14,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              date,
              style: const TextStyle(
                color: ConstantColor.pureWhite,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          )
        ],
      ),
    );
  }
}
