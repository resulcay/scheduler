import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/scripts/locale_keys.g.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final Function() function;

  const CustomAppBar({super.key, required this.function});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: const Text(LocaleKeys.app_title).tr(),
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
