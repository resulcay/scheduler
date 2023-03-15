import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:scheduler/components/onboarding_content.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/view_model/onboarding_view_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends OnboardingViewModel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (value) {
                  callMethod.changeStep(value);
                },
                children: [
                  OnboardingContent(
                    svgFileName: 'schedule',
                    hintText: LocaleKeys.makeEveryDaySuccess.tr(),
                  ),
                  OnboardingContent(
                    svgFileName: 'time',
                    hintText: LocaleKeys.neverWasteAMoment.tr(),
                  ),
                  OnboardingContent(
                    svgFileName: 'time-line',
                    hintText: LocaleKeys.visualizeYourTimeline.tr(),
                  ),
                  OnboardingContent(
                    svgFileName: 'date-picker',
                    hintText: LocaleKeys.stopMissingImportant.tr(),
                  ),
                  OnboardingContent(
                    svgFileName: 'organize',
                    hintText: LocaleKeys.keepEverythingInOrder.tr(),
                  ),
                ],
              ),
            ),
            circleAvatarDots(selectedPage, context, pageController)
          ],
        ),
      ),
    );
  }
}
