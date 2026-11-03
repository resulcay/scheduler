import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/localization/texts.dart';
import 'package:scheduler/models/event_model.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event});

  final EventModel event;

  @override
  Widget build(BuildContext context) {
    final isPast = event.eventDate.isBefore(DateTime.now());
    final description = event.eventDescription ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: context.paddingLow,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isPast ? Colors.grey : eventColor(event),
        border: Border.all(color: Theme.of(context).disabledColor, width: 2),
      ),
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  event.eventTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ConstantColor.pureWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              if (event.notify && !isPast)
                const Icon(
                  Icons.notifications_active,
                  color: ConstantColor.pureWhite,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 35),
            child: Text(
              description.isEmpty ? LocaleKeys.noDescription.tr() : description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
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
              formatEventDate(event.eventDate, context.locale.toString()),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ConstantColor.pureWhite,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stored colours are ARGB hex; very old installs may hold `Color(0x...)`.
Color eventColor(EventModel event) {
  final hex = RegExp(r'[0-9a-fA-F]{6,8}').firstMatch(
    event.color.replaceFirst(RegExp(r'0x', caseSensitive: false), ''),
  )?[0];
  final value = hex == null ? null : int.tryParse(hex, radix: 16);
  if (value == null) return ConstantColor.normalBlue;
  return Color(hex!.length == 6 ? 0xFF000000 | value : value);
}
