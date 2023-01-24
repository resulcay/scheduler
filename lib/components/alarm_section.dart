import 'package:flutter/material.dart';

class AlarmSection extends StatelessWidget {
  final IconData iconData;
  final VoidCallback function;
  final Widget widget;
  const AlarmSection({
    super.key,
    required this.iconData,
    required this.function,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              widget,
              SizedBox(
                height: 50,
                width: 100,
                child: ElevatedButton(
                  onPressed: function,
                  child: Icon(
                    iconData,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Theme.of(context).backgroundColor,
          thickness: .7,
        )
      ],
    );
  }
}
