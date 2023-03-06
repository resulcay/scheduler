import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final Function() function;

  const CustomAppBar({super.key, required this.function});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: Theme.of(context).primaryColor),
      elevation: 0,
      leading: IconButton(
        onPressed: function,
        splashRadius: 24,
        icon: const Icon(Icons.sort, size: 30),
      ),
      actions: [
        IconButton(
          onPressed: function,
          splashRadius: 24,
          icon: const Icon(Icons.manage_search, size: 30),
        ),
      ],
    );
  }
}
