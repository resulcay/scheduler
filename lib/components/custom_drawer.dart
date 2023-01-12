import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/services/list_type_service.dart';
import 'package:scheduler/services/theme_service.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>().readTheme();
    context.watch<ListTypeService>().readListType();
    return Material(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Dark Mode'),
                const Spacer(),
                Consumer<ThemeService>(
                  builder: (_, themeService, __) => CupertinoSwitch(
                    trackColor: Theme.of(context).disabledColor,
                    activeColor: ConstantColor.normalBlue,
                    value: themeService.isDark,
                    onChanged: (value) {
                      themeService.storeTheme(value);
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text('Stacked Listview'),
                    IconButton(
                      splashRadius: 18,
                      onPressed: () {
                        QuickAlert.show(
                            title: 'Warning',
                            text:
                                'Enabling Stacked listview can cause performance issues. In case of facing any problem please disable it.',
                            context: context,
                            type: QuickAlertType.info);
                      },
                      icon: const Icon(Icons.info),
                    ),
                  ],
                ),
                const Spacer(),
                Consumer<ListTypeService>(
                  builder: (_, value, __) => CupertinoSwitch(
                    trackColor: Theme.of(context).disabledColor,
                    activeColor: ConstantColor.normalBlue,
                    value: value.switchValue,
                    onChanged: (value) {
                      ListTypeService().storeListType(value);
                    },
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
