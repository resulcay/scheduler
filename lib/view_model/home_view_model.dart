import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scheduler/components/fade_out_builder.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/constants/constant_texts.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/providers/stand_alone_providers/color_provider.dart';
import 'package:scheduler/services/event_service.dart';
import 'package:scheduler/services/firebase_analytics.dart';
import 'package:scheduler/services/localization.dart';
import 'package:scheduler/services/path_service.dart';
import 'package:scheduler/services/rate_service.dart';
import 'package:scheduler/view/create_event_screen.dart';
import 'package:scheduler/view/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

abstract class HomeViewModel extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late bool isLocale;
  late EventService eventService;
  late RateService rateService;
  late AnimationController animationController;
  static const Duration splashAnimationDuration = Duration(milliseconds: 350);
  static const Duration splashDelay = Duration(milliseconds: 50);
  static const Duration toggleDuration = Duration(milliseconds: 250);
  static const double maxSlide = 225;
  static const double minDragStartEdge = 60;
  static const double maxDragStartEdge = maxSlide - 16;

  bool _canBeDragged = false;
  var rectGetterKey = RectGetter.createGlobalKey();
  Rect? rect;

  @override
  void initState() {
    super.initState();
    eventService = EventService();
    rateService = RateService();
    animationController = AnimationController(
      vsync: this,
      duration: HomeViewModel.toggleDuration,
    );
    checkRatingStatus();
  }

  @override
  void didChangeDependencies() {
    isLocale = context.locale == LocaleConstant.engLocale;
    // TODO : This Section causes high memory usage due to calling build method constantly.
    context.watch<EventService>().getAllEvents();

    super.didChangeDependencies();
    //
  }

  checkRatingStatus() {
    eventService.generateEventId().then((itemCount) {
      rateService.read().then((isRated) {
        if (itemCount > 1 && !isRated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              QuickAlert.show(
                context: context,
                type: QuickAlertType.info,
                title: LocaleKeys.rateMyApp.tr(),
                text: LocaleKeys.wouldYouPleaseRate.tr(),
                confirmBtnText: LocaleKeys.rate.tr(),
                cancelBtnText: LocaleKeys.later.tr(),
                showCancelBtn: true,
                onConfirmBtnTap: () {
                  rateService.write(true).then((_) {
                    final Uri url = Uri.parse(ConstantText.playStoreLink);
                    launchUrl(url, mode: LaunchMode.externalApplication)
                        .then((_) => Navigator.pop(context));
                  });
                  AnalyticsService.analytics
                      .logEvent(name: "rate", parameters: {"is_rated": "true"});
                },
              );
            });
          });
        }
      });
    });
  }

  void onColor() {
    Provider.of<ColorProvider>(context, listen: false)
        .changeColor(randomColor());
    onTapFloatingActionButton();
    AnalyticsService.analytics
        .logEvent(name: "floating_action_button", parameters: {
      "button_click": "true",
    });
  }

  void onTapFloatingActionButton() {
    setState(() => rect = RectGetter.getRectFromKey(rectGetterKey));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() =>
          rect = rect?.inflate(1.3 * MediaQuery.of(context).size.longestSide));
      await Future.delayed(
          splashAnimationDuration + splashDelay, _goToNextPage);
    });
  }

  FutureOr _goToNextPage() {
    Navigator.push(
        context,
        FadeRouteBuilder(
            page: CreateEventScreen(
          isLocale: isLocale,
        ))).then((_) => setState(() => rect = null));
  }

  void close() => animationController.reverse();

  void open() => animationController.forward();

  void toggleDrawer() => animationController.isCompleted ? close() : open();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  List<String> cardConfiguration(EventService model, int index) {
    DateTime eventDate = model.items[index].eventDate;
    initializeDateFormatting();
    String eventTimeAsHourAndMinute = DateFormat.Hm().format(eventDate);
    String eventTimeAsDayMonthYear = isLocale
        ? DateFormat.yMMMEd('en_EN').format(eventDate)
        : DateFormat.yMMMEd('tr_TR').format(eventDate);
    String value = model.items[index].color;
    value = _colorToString(value);

    return [eventTimeAsHourAndMinute, eventTimeAsDayMonthYear, value];
  }

  String _colorToString(String value) {
    if (value.length > 20) {
      var local = value.split(" ");
      value = local.last;
      value = value.substring(0, value.length - 1);
    }

    value = value.split("(")[1];
    value = value.split(")")[0];

    return value;
  }

  void toggle() => animationController.isDismissed
      ? animationController.forward()
      : animationController.reverse();

  void onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta! / maxSlide;
      animationController.value += delta;
    }
  }

  void onDragEnd(DragEndDetails details) {
    double kMinFlingVelocity = 365.0;

    if (animationController.isDismissed || animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      animationController.fling(velocity: visualVelocity);
    } else if (animationController.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  Widget splashWidget() {
    if (rect == null) {
      return Container();
    }
    return AnimatedPositioned(
      duration: splashAnimationDuration,
      left: rect?.left,
      right: MediaQuery.of(context).size.width - rect!.right,
      top: rect?.top,
      bottom: MediaQuery.of(context).size.height - rect!.bottom,
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: ConstantColor.normalOrange,
        ),
      ),
    );
  }

  Widget emptyScreen() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(child: const Text(LocaleKeys.thereIsNoEvent).tr()),
        Positioned(
          bottom: 50,
          right: 80,
          child: Column(
            children: [
              const Text(
                LocaleKeys.addFromHere,
                style: TextStyle(color: ConstantColor.transparentGrey),
              ).tr(),
              Image.asset(
                '${PathService.IMAGE_BASE_PATH}curly-arrow.png',
                scale: 1.5,
              )
            ],
          ),
        )
      ],
    );
  }

  deleteAll() {
    QuickAlert.show(
      title: LocaleKeys.areYouSure.tr(),
      text: LocaleKeys.allEventsWillBeDeleted.tr(),
      confirmBtnText: LocaleKeys.yes.tr(),
      onConfirmBtnTap: () {
        eventService.deleteAllEvents();
        Navigator.pop(context);
      },
      context: context,
      type: QuickAlertType.warning,
    );
  }
}
