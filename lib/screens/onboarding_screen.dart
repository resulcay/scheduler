import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/extensions/padding_extension.dart';

import '../components/custom_text_button.dart';
import '../constants/constant_colors.dart';
import '../constants/constant_texts.dart';
import '../providers/onboarding_step_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController pageController;
  @override
  void initState() {
    pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    int selectedPage =
        Provider.of<OnboardingStepProvider>(context).onboardingStep;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (value) {
                  Provider.of<OnboardingStepProvider>(context, listen: false)
                      .changeStep(value);
                },
                children: const [
                  OnboardingContent(text: 'text 1'),
                  OnboardingContent(text: 'text 2'),
                  OnboardingContent(text: 'text 3'),
                ],
              ),
            ),
            _circleAvatarDots(selectedPage, context, pageController)
          ],
        ),
      ),
    );
  }

  Padding _circleAvatarDots(
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
                        ? ConstantColor.lightBrown
                        : ConstantColor.darkRed.withOpacity(.24),
                    radius: selectedPage == index ? 6 : 3,
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
                _onPageChanged(
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

  _onPageChanged(
      int selectedPage, BuildContext context, PageController pageController) {
    if (selectedPage == 2) {
      _writeIsCompleteDataToLocal();
      Navigator.pop(context);
      Navigator.pushNamed(context, 'main');
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  _writeIsCompleteDataToLocal() {
    final onboardingBox = Hive.box(ConstantText.onboardingBoxName);
    onboardingBox.put(ConstantText.onboardingBoxKeyName, true);
  }
}

class OnboardingContent extends StatelessWidget {
  final String text;
  const OnboardingContent({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.paddingLarge,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: text,
            style: const TextStyle(
              fontFamily: ConstantText.fontName,
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.6,
            ),
            children: const [
              TextSpan(
                text: ConstantText.onboardingText,
                style: TextStyle(
                  fontFamily: ConstantText.fontName,
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
