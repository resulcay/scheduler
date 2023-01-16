import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scheduler/components/fade_out_builder.dart';
import 'package:scheduler/providers/event_provider.dart';
import 'package:scheduler/view/create_event_screen.dart';
import 'package:scheduler/view/home_screen.dart';

abstract class HomeViewModel extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
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
    animationController = AnimationController(
      vsync: this,
      duration: HomeViewModel.toggleDuration,
    );
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
    Navigator.push(context, FadeRouteBuilder(page: const CreateEventScreen()))
        .then((_) => setState(() => rect = null));
  }

  void close() => animationController.reverse();

  void open() => animationController.forward();

  void toggleDrawer() => animationController.isCompleted ? close() : open();

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  AppBar customAppBar() {
    return AppBar(
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          toggleDrawer();
        },
        splashRadius: 24,
        icon: const Icon(Icons.sort, size: 30),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          splashRadius: 24,
          icon: const Icon(Icons.manage_search, size: 30),
        ),
      ],
    );
  }

  List<String> cardConfiguration(EventProvider model, int index) {
    DateTime eventDate = model.items[index].eventDate;
    initializeDateFormatting();
    String eventTimeAsHourAndMinute = DateFormat.Hm().format(eventDate);
    String eventTimeAsDayMonthYear =
        DateFormat.yMMMEd('en_EN').format(eventDate);
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
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent.shade400,
        ),
      ),
    );
  }
}