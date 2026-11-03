import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:scheduler/app.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/screens/home_screen.dart';
import 'package:scheduler/services/path_service.dart';
import 'package:scheduler/stores/settings_store.dart';
import 'package:share_plus/share_plus.dart';

const _white = TextStyle(color: ConstantColor.pureWhite);

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    // tr() strings swap only once Localizations has loaded the new language,
    // so depend on that (context.locale fires too early).
    Localizations.localeOf(context);
    final isDark =
        settings.isDark ?? Theme.of(context).brightness == Brightness.dark;

    // Fills the whole screen; the shrunk page leaves the rest uncovered.
    return Material(
      color: ConstantColor.elegantBlack,
      child: SafeArea(
        minimum: context.paddingLow,
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            // Matches the 225px the home page slides away.
            width: 215,
            child: ListView(
              children: [
                _Row(
                  label: LocaleKeys.darkMode.tr(),
                  trailing: CupertinoSwitch(
                    activeTrackColor: ConstantColor.normalBlue,
                    value: isDark,
                    onChanged: settings.setDark,
                  ),
                ),
                _Row(
                  label: LocaleKeys.stackedListview.tr(),
                  info: () => QuickAlert.show(
                    context: context,
                    type: QuickAlertType.info,
                    title: LocaleKeys.listType.tr(),
                    text: LocaleKeys.enablingStackedList.tr(),
                    confirmBtnText: LocaleKeys.confirmOk.tr(),
                  ),
                  trailing: CupertinoSwitch(
                    activeTrackColor: ConstantColor.normalBlue,
                    value: settings.stackedList,
                    onChanged: settings.setStackedList,
                  ),
                ),
                const SizedBox(height: 8),
                Text(LocaleKeys.language.tr(), style: _white),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _LanguageButton(locale: trLocale, flag: 'tr', label: 'TR'),
                    const SizedBox(width: 12),
                    _LanguageButton(locale: enLocale, flag: 'us', label: 'EN'),
                  ],
                ),
                const SizedBox(height: 8),
                if (canRate)
                  _Row(
                    label: LocaleKeys.rate.tr(),
                    trailing: IconButton(
                      onPressed: openStoreReview,
                      tooltip: LocaleKeys.rate.tr(),
                      icon: const Icon(
                        Icons.rate_review,
                        color: ConstantColor.pureWhite,
                        size: 30,
                      ),
                    ),
                  ),
                _Row(
                  label: LocaleKeys.share.tr(),
                  trailing: Builder(
                    builder: (buttonContext) => IconButton(
                      onPressed: () => _share(buttonContext),
                      tooltip: LocaleKeys.share.tr(),
                      icon: const Icon(
                        Icons.share_outlined,
                        color: ConstantColor.pureWhite,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// iPad needs an anchor for the share popover or the sheet never shows.
  static void _share(BuildContext buttonContext) {
    final box = buttonContext.findRenderObject() as RenderBox?;
    SharePlus.instance.share(
      ShareParams(
        text: storeLink,
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.trailing, this.info});

  final String label;
  final Widget trailing;
  final VoidCallback? info;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: _white)),
        if (info != null)
          IconButton(
            color: ConstantColor.pureWhite,
            visualDensity: VisualDensity.compact,
            onPressed: info,
            icon: const Icon(Icons.info, size: 20),
          ),
        trailing,
      ],
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({
    required this.locale,
    required this.flag,
    required this.label,
  });

  final Locale locale;
  final String flag;
  final String label;

  @override
  Widget build(BuildContext context) {
    final selected = context.locale == locale;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => context.setLocale(locale),
        child: Container(
          padding: context.paddingLow,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? ConstantColor.pureWhite
                  : ConstantColor.pureWhite.withValues(alpha: .3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              SvgPicture.asset(
                '${PathService.IMAGE_BASE_PATH}$flag.svg',
                height: 40,
              ),
              Text(
                label,
                style: const TextStyle(color: ConstantColor.elegantGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
