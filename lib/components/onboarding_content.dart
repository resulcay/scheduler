import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/services/path_service.dart';

class OnboardingContent extends StatefulWidget {
  final String svgFileName;
  final String hintText;

  const OnboardingContent({
    Key? key,
    required this.svgFileName,
    required this.hintText,
  }) : super(key: key);

  @override
  State<OnboardingContent> createState() => _OnboardingContentState();
}

class _OnboardingContentState extends State<OnboardingContent> {
  double opacity = 0;
  Alignment alignment = Alignment.centerRight;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        opacity = 1;
        alignment = Alignment.center;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 9,
          child: AnimatedOpacity(
            opacity: opacity,
            duration: const Duration(seconds: 1),
            child: Padding(
              padding: context.paddingLarge,
              child: SvgPicture.asset(
                  '${PathService.IMAGE_BASE_PATH}${widget.svgFileName}.svg'),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: AnimatedAlign(
            alignment: alignment,
            duration: const Duration(seconds: 1),
            child: Text(
              widget.hintText,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(color: ConstantColor.pureBlack, fontSize: 21),
            ),
          ),
        ),
      ],
    );
  }
}
