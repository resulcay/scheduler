import 'package:flutter/material.dart';

class AlarmSection extends StatelessWidget {
  final String text;
  final IconData iconData;
  final VoidCallback function;
  const AlarmSection({
    super.key,
    required this.text,
    required this.iconData,
    required this.function,
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
              Text(
                textAlign: TextAlign.center,
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
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
