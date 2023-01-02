import 'package:flutter/material.dart';
import 'package:scheduler/extensions/padding_extension.dart';

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  const EventCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: context.paddingLow,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.red,
      ),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            title,
            style: const TextStyle(
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
