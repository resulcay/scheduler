import 'package:flutter/material.dart';
import 'package:scheduler/components/onboarding_content.dart';
import 'package:scheduler/constants/constant_colors.dart';
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
                children: const [
                  OnboardingContent(
                    svgFileName: 'schedule',
                    hintText: "Make every day a success!",
                  ),
                  OnboardingContent(
                    svgFileName: 'time',
                    hintText: "Never waste a moment again",
                  ),
                  OnboardingContent(
                    svgFileName: 'time-line',
                    hintText: "Visualize your timeline",
                  ),
                  OnboardingContent(
                    svgFileName: 'date-picker',
                    hintText: "Stop missing important deadlines",
                  ),
                  OnboardingContent(
                    svgFileName: 'organize',
                    hintText: "Keep everything in order",
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
