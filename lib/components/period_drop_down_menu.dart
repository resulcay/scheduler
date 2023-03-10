import 'package:flutter/material.dart';
import 'package:scheduler/constants/constant_colors.dart';
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
  bool isEnglish = true;

  void _updatePeriod(String? period) {
    ///
    /// for English period initials. (last ...)
    ///
    if (period != null && period.startsWith('l')) {
      DateTime current = DateTime.now();
      String periodInitial = period[7];
      int periodInitialValue = int.parse(period[5]);

      switch (periodInitial) {
        // hour
        case 'h':
          var assumedDate =
              widget.dateTime.subtract(Duration(hours: periodInitialValue));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }

          break;
        // day
        case 'd':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: periodInitialValue));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        // week
        case 'w':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: periodInitialValue * 7));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        // month
        case 'm':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: periodInitialValue * 30));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        // year
        case 'y':
          var assumedDate = widget.dateTime
              .subtract(Duration(days: periodInitialValue * 365));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        default:
      }
    }

    ///
    /// for Turkish period initials. (son ...)
    ///
    if (period != null && period.startsWith('s')) {
      DateTime current = DateTime.now();
      String range = period[6];
      int rangeValue = int.parse(period[4]);

      switch (range) {
        // saat
        case 's':
          var assumedDate =
              widget.dateTime.subtract(Duration(hours: rangeValue));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }

          break;
        // gün
        case 'g':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: rangeValue));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        // hafta
        case 'h':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: rangeValue * 7));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        // ay
        case 'a':
          var assumedDate =
              widget.dateTime.subtract(Duration(days: rangeValue * 30));

          if (current.isBefore(assumedDate)) {
            setState(() {
              notificationPeriod = period;
            });
          }
          break;
        // yıl
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

    ///
    /// Callback function to provide a proper period.
    ///
    if (notificationPeriod != null) {
      widget.onPeriodSelected.call(notificationPeriod!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: const Text(
        "Select",
        style: TextStyle(color: ConstantColor.deepTeal),
      ),
      borderRadius: BorderRadius.circular(10),
      icon: const Icon(
        Icons.arrow_drop_down_circle_outlined,
        color: ConstantColor.deepTeal,
      ),
      dropdownColor: ConstantColor.deepTeal,
      value: notificationPeriod,
      items: (isEnglish
              ? ConstantText.notificationPeriods
              : ConstantText.notificationPeriodsInTurkish)
          .map((String period) {
        return DropdownMenuItem(
          value: period,
          child: Text(
            period,
          ),
        );
      }).toList(),
      onChanged: _updatePeriod,
    );
  }
}
