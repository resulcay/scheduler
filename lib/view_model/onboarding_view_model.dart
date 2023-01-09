import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/components/custom_text_button.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/providers/onboarding_step_provider.dart';
import 'package:scheduler/view/onboarding_screen.dart';

abstract class OnboardingViewModel extends State<OnboardingScreen> {
  late PageController pageController;
  late int selectedPage;
  late OnboardingStepProvider callMethod;

  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    callMethod = Provider.of<OnboardingStepProvider>(context, listen: false);
    selectedPage = Provider.of<OnboardingStepProvider>(context).onboardingStep;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Padding circleAvatarDots(
      int selectedPage, BuildContext context, PageController pageController) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    backgroundColor: selectedPage == index
                        ? ConstantColor.darkBlack
                        : ConstantColor.darkRed.withOpacity(.24),
                    radius: selectedPage == index ? 7 : 4,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CustomTextButton(
              text: selectedPage == 2 ? 'Done' : 'Next',
              function: () {
                onPageChanged(
                  selectedPage,
                  context,
                  pageController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  onPageChanged(
      int selectedPage, BuildContext context, PageController pageController) {
    if (selectedPage == 2) {
      writeIsCompleteDataToLocal();
      Navigator.pop(context);
      Navigator.pushNamed(context, 'main');
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  writeIsCompleteDataToLocal() {
    final onboardingBox = Hive.box(ConstantText.onboardingBoxName);
    onboardingBox.put(ConstantText.onboardingBoxKeyName, true);
  }
}
