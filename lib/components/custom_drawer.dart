import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/extensions/media_query_extension.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/services/list_type_service.dart';
import 'package:scheduler/services/localization.dart';
import 'package:scheduler/services/path_service.dart';
import 'package:scheduler/services/theme_service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeService>().read();
    context.watch<ListTypeService>().read();
    final Uri url = Uri.parse(ConstantText.playStoreLink);

    return Material(
      color: Theme.of(context).splashColor,
      child: SafeArea(
        minimum: context.paddingLow,
        child: ListView(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  LocaleKeys.darkMode,
                  style: TextStyle(color: ConstantColor.pureWhite),
                ).tr(),
                const Spacer(),
                Consumer<ThemeService>(
                  builder: (_, themeService, __) => CupertinoSwitch(
                    trackColor: Theme.of(context).disabledColor,
                    activeColor: ConstantColor.normalBlue,
                    value: themeService.isDark,
                    onChanged: (value) {
                      themeService.write(value);
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
                    const Text(
                      LocaleKeys.stackedListview,
                      style: TextStyle(color: ConstantColor.pureWhite),
                    ).tr(),
                    IconButton(
                      color: ConstantColor.pureWhite,
                      splashRadius: 18,
                      onPressed: () {
                        QuickAlert.show(
                            title: LocaleKeys.listType.tr(),
                            text: LocaleKeys.enablingStackedList.tr(),
                            confirmBtnText: LocaleKeys.confirmOk.tr(),
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
                      ListTypeService().write(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      LocaleKeys.language,
                      style: TextStyle(color: ConstantColor.pureWhite),
                    ).tr(),
                    IconButton(
                      color: ConstantColor.pureWhite,
                      splashRadius: 18,
                      onPressed: () {
                        QuickAlert.show(
                            title: LocaleKeys.language.tr(),
                            text: LocaleKeys.ifChangesHaveNotApplied.tr(),
                            context: context,
                            confirmBtnText: LocaleKeys.confirmOk.tr(),
                            type: QuickAlertType.info);
                      },
                      icon: const Icon(Icons.info),
                    ),
                  ],
                ),
                ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  isSelected: const [false, false],
                  children: [
                    Padding(
                      padding: context.paddingLow,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.setLocale(LocaleConstant.trLocale);
                            },
                            child: SvgPicture.asset(
                                height: 40,
                                '${PathService.IMAGE_BASE_PATH}tr.svg'),
                          ),
                          const Text(
                            'TR',
                            style: TextStyle(color: ConstantColor.elegantGrey),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: context.paddingLow,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              context.setLocale(LocaleConstant.engLocale);
                            },
                            child: SvgPicture.asset(
                                height: 40,
                                '${PathService.IMAGE_BASE_PATH}us.svg'),
                          ),
                          const Text(
                            'EN',
                            style: TextStyle(color: ConstantColor.elegantGrey),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  LocaleKeys.rate,
                  style: TextStyle(color: ConstantColor.pureWhite),
                ).tr(),
                const SizedBox(width: 5),
                IconButton(
                  onPressed: () =>
                      launchUrl(url, mode: LaunchMode.externalApplication),
                  icon: const Icon(
                    Icons.rate_review,
                    color: ConstantColor.pureWhite,
                    size: 30,
                  ),
                )
              ],
            ),
            Row(
              children: [
                const Text(
                  LocaleKeys.share,
                  style: TextStyle(color: ConstantColor.pureWhite),
                ).tr(),
                const SizedBox(width: 5),
                IconButton(
                  onPressed: () => Share.share(ConstantText.playStoreLink),
                  icon: const Icon(
                    Icons.share_outlined,
                    color: ConstantColor.pureWhite,
                    size: 30,
                  ),
                )
              ],
            ),
            SizedBox(height: context.height),
          ],
        ),
      ),
    );
  }
}
