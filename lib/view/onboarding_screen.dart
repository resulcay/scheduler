import 'package:flutter/material.dart';
import 'package:scheduler/components/onboarding_content.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  callMethod.changeStep(value);
                },
                children: const [
                  OnboardingContent(
                    svgFileName: 'organize',
                    hintText: "Organize your events",
                  ),
                  OnboardingContent(
                    svgFileName: 'folders',
                    hintText: "Change Anytime",
                  ),
                  OnboardingContent(
                    svgFileName: 'pick-date',
                    hintText: "Set time for Furthermore",
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
