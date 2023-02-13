import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final Function() function;
  final Function() function2;
  const CustomAppBar(
      {super.key, required this.function, required this.function2});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        onPressed: function,
        splashRadius: 24,
        icon: const Icon(Icons.sort, size: 30),
      ),
      actions: [
        IconButton(
          onPressed: function2,
          splashRadius: 24,
          icon: const Icon(Icons.manage_search, size: 30),
        ),
      ],
    );
  }
}
