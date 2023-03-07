import 'package:flutter/material.dart';

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
          fontWeight: FontWeight.w400,
          fontSize: 18,
        ),
      ),
    );
  }
}
