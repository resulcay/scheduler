import 'package:flutter/material.dart';

import '../constants/constant_colors.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback function;
  const CustomTextButton({
    Key? key,
    required this.text,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: function,
      child: Text(
        text,
        style: const TextStyle(
          color: ConstantColor.velvetRed,
          fontWeight: FontWeight.w400,
          fontSize: 16,
        ),
      ),
    );
  }
}
