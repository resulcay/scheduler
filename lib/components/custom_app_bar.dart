import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/localization/locale_keys.g.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final Function() functionForLeft;
  final Function() functionForRight;

  const CustomAppBar({
    super.key,
    required this.functionForLeft,
    required this.functionForRight,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: const Text(LocaleKeys.events).tr(),
      leading: IconButton(
        onPressed: functionForLeft,
        splashRadius: 24,
        icon: const Icon(Icons.sort, size: 30),
      ),
      actions: [
        PopupMenuButton(
          onSelected: (value) {
            switch (value) {
              case 0:
                functionForRight();
                break;
              default:
            }
          },
          color: ConstantColor.deepTeal,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          iconSize: 30,
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 0,
                child: const Text(
                  LocaleKeys.deleteAll,
                  style: TextStyle(color: ConstantColor.pureWhite),
                ).tr(),
              )
            ];
          },
        )
      ],
    );
  }
}
