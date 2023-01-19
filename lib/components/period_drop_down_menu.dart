import 'package:flutter/material.dart';
import 'package:scheduler/constants/constant_texts.dart';

class PeriodDropDownMenu extends StatefulWidget {
  final void Function(String period) onPeriodSelected;
  final DateTime dateTime;
  const PeriodDropDownMenu({
    super.key,
    required this.onPeriodSelected,
    required this.dateTime,
  });

  @override
  State<PeriodDropDownMenu> createState() => _PeriodDropDownMenuState();
}

class _PeriodDropDownMenuState extends State<PeriodDropDownMenu> {
  String? notificationPeriod;

  void _updatePeriod(String? period) {
    if (period != null) {
      DateTime current = DateTime.now();
      String range = period[7];
      int rangeValue = int.parse(period[5]);

      switch (range) {
        case 'h':
          var assumedDate =
              widget.dateTime.subtract(Duration(hours: rangeValue));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }

          break;
        case 'd':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: rangeValue));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        case 'w':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: rangeValue * 7));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        case 'm':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: rangeValue * 30));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        case 'y':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: rangeValue * 365));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        default:
      }
    }

    if (notificationPeriod != null) {
      widget.onPeriodSelected.call(notificationPeriod!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: notificationPeriod,
      items: ConstantText.notificationPeriods.map((String period) {
        return DropdownMenuItem(
          value: period,
          child: Text(period),
        );
      }).toList(),
      onChanged: _updatePeriod,
    );
  }
}
