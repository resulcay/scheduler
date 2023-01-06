import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/providers/color_provider.dart';
import 'package:scheduler/providers/event_provider.dart';
import 'package:scheduler/providers/list_type_provider.dart';
import 'package:scheduler/screens/create_event_screen.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';

import '../components/custom_drawer.dart';
import '../components/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;

  static const Duration toggleDuration = Duration(milliseconds: 250);
  static const double maxSlide = 225;
  static const double minDragStartEdge = 60;
  static const double maxDragStartEdge = maxSlide - 16;

  bool _canBeDragged = false;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: _HomeScreenState.toggleDuration,
    );
    super.initState();
  }

  void close() => _animationController.reverse();

  void open() => _animationController.forward();

  void toggleDrawer() => _animationController.isCompleted ? close() : open();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<EventProvider>().getAllEvents();

    return WillPopScope(
      onWillPop: () async {
        if (_animationController.isCompleted) {
          close();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onTap: toggle,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            double animValue = _animationController.value;
            final slideAmount = maxSlide * animValue;
            final contentScale = 1.0 - (0.3 * animValue);
            return Stack(
              children: [
                const CustomDrawer(),
                Transform(
                  transform: Matrix4.identity()
                    ..translate(slideAmount)
                    ..scale(contentScale),
                  alignment: Alignment.bottomLeft,
                  child: Consumer<EventProvider>(
                    builder: (context, model, child) {
                      return Scaffold(
                        key: scaffoldKey,
                        appBar: _customAppBar(),
                        floatingActionButton: FloatingActionButton(
                          onPressed: () async {
                            Provider.of<ColorProvider>(context, listen: false)
                                .changeColor(randomColor());
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const CreateEventScreen()));
                          },
                          child: const Icon(Icons.add),
                        ),
                        body: model.items.isEmpty
                            ? const Center(
                                child: Text("There is no Event at the moment"))
                            : Provider.of<ListTypeProvider>(context).switchValue
                                ? Padding(
                                    padding: context.paddingLow,
                                    child: StackedCardCarousel(
                                        initialOffset: 0,
                                        spaceBetweenItems: 190,
                                        items: List.generate(model.items.length,
                                            (index) {
                                          List<String> values =
                                              _cardConfiguration(model, index);
                                          return GestureDetector(
                                            onTap: () {
                                              print(model
                                                  .items[index].eventTitle);
                                            },
                                            child: EventCard(
                                              title:
                                                  model.items[index].eventTitle,
                                              description: model.items[index]
                                                      .eventDescription!.isEmpty
                                                  ? "No Description"
                                                  : model.items[index]
                                                      .eventDescription
                                                      .toString(),
                                              date:
                                                  '${values[0]} - ${values[1]}',
                                              color:
                                                  Color(int.parse(values[2])),
                                            ),
                                          );
                                        })),
                                  )
                                : ListView.builder(
                                    padding: context.paddingLow,
                                    itemCount: model.items.length,
                                    itemBuilder: (context, index) {
                                      List<String> values =
                                          _cardConfiguration(model, index);
                                      return GestureDetector(
                                        onTap: () {
                                          print(model.items[index].eventTitle);
                                        },
                                        child: EventCard(
                                          title: model.items[index].eventTitle,
                                          description: model.items[index]
                                                  .eventDescription!.isEmpty
                                              ? "No Description"
                                              : model
                                                  .items[index].eventDescription
                                                  .toString(),
                                          date: '${values[0]} - ${values[1]}',
                                          color: Color(int.parse(values[2])),
                                        ),
                                      );
                                    },
                                  ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  AppBar _customAppBar() {
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
        )
      ],
    );
  }

  List<String> _cardConfiguration(EventProvider model, int index) {
    DateTime? eventDate = model.items[index].eventDate ?? DateTime.now();
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

  void toggle() => _animationController.isDismissed
      ? _animationController.forward()
      : _animationController.reverse();

  void _onDragStart(DragStartDetails details) {
    bool isDragOpenFromLeft = _animationController.isDismissed &&
        details.globalPosition.dx < minDragStartEdge;
    bool isDragCloseFromRight = _animationController.isCompleted &&
        details.globalPosition.dx > maxDragStartEdge;

    _canBeDragged = isDragOpenFromLeft || isDragCloseFromRight;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_canBeDragged) {
      double delta = details.primaryDelta! / maxSlide;
      _animationController.value += delta;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    double kMinFlingVelocity = 365.0;

    if (_animationController.isDismissed || _animationController.isCompleted) {
      return;
    }
    if (details.velocity.pixelsPerSecond.dx.abs() >= kMinFlingVelocity) {
      double visualVelocity = details.velocity.pixelsPerSecond.dx /
          MediaQuery.of(context).size.width;

      _animationController.fling(velocity: visualVelocity);
    } else if (_animationController.value < 0.5) {
      close();
    } else {
      open();
    }
  }
}
