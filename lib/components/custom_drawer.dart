import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/constants/constant_colors.dart';

import '../providers/list_type_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.indigo,
      child: SafeArea(
        child: Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: ListView(
            children: [
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
                  CupertinoSwitch(
                    activeColor: ConstantColor.normalBlue,
                    value: Provider.of<ListTypeProvider>(context).switchValue,
                    onChanged: (value) {
                      Provider.of<ListTypeProvider>(context, listen: false)
                          .changeSwitch(value);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
