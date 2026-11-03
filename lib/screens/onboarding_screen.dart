import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/screens/home_screen.dart';
import 'package:scheduler/services/path_service.dart';
import 'package:scheduler/stores/settings_store.dart';

const _pages = [
  ('schedule', LocaleKeys.makeEveryDaySuccess),
  ('time', LocaleKeys.neverWasteAMoment),
  ('time-line', LocaleKeys.visualizeYourTimeline),
  ('date-picker', LocaleKeys.stopMissingImportant),
  ('organize', LocaleKeys.keepEverythingInOrder),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.initialPage = 0});

  final int initialPage;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final _controller = PageController(initialPage: widget.initialPage);
  late int _page = widget.initialPage;

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!_isLast) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    await context.read<SettingsStore>().completeOnboarding();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (value) => setState(() => _page = value),
                children: [
                  for (final (svg, text) in _pages)
                    _OnboardingPage(svgFileName: svg, text: text.tr()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < _pages.length; i++)
                          Padding(
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                              backgroundColor: i == _page
                                  ? ConstantColor.darkBlack
                                  : ConstantColor.darkRed.withValues(
                                      alpha: .24,
                                    ),
                              radius: i == _page ? 7 : 4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: TextButton(
                      onPressed: _next,
                      child: Text(
                        (_isLast ? LocaleKeys.done : LocaleKeys.next).tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.svgFileName, required this.text});

  final String svgFileName;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: context.paddingLarge,
            child: SvgPicture.asset(
              '${PathService.IMAGE_BASE_PATH}$svgFileName.svg',
            ),
          ),
        ),
        Padding(
          padding: context.paddingNormal,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: ConstantColor.pureBlack,
              fontSize: 21,
            ),
          ),
        ),
      ],
    );
  }
}
