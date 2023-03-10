import 'package:flutter/material.dart';

import '../constants/constant_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final int maxLines;
  final String hint;
  final TextInputAction textInputAction;

  final String? Function(String?)? function;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.maxLines,
    required this.hint,
    required this.textInputAction,
    this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: function,
      controller: controller,
      maxLines: maxLines,
      cursorColor: ConstantColor.darkYellow,
      cursorHeight: 20,
      textInputAction: textInputAction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: ConstantColor.normalGrey,
            width: 1,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            width: 2,
          ),
        ),
      ),
    );
  }
}
