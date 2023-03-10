import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scheduler/components/custom_app_bar.dart';
import 'package:scheduler/components/custom_drawer.dart';
import 'package:scheduler/components/event_card.dart';
import 'package:scheduler/components/event_detail.dart';
import 'package:scheduler/constants/constant_colors.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/providers/stand_alone_providers/event_provider.dart';
import 'package:scheduler/services/list_type_service.dart';
import 'package:scheduler/view_model/home_view_model.dart';
import 'package:stacked_card_carousel/stacked_card_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends HomeViewModel {
  @override
  Widget build(BuildContext context) {
    //////
    context.watch<EventProvider>().getAllEvents();
    context.watch<ListTypeService>().read();
    //////
    return WillPopScope(
      onWillPop: () async {
        if (animationController.isCompleted) {
          close();
          return false;
        }
        return true;
      },
      child: GestureDetector(
        onTap: toggle,
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            double animValue = animationController.value;
            final slideAmount = HomeViewModel.maxSlide * animValue;
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
                      return Consumer<ListTypeService>(
                        builder: (_, listTypeService, __) => Stack(
                          children: [
                            Scaffold(
                              key: scaffoldKey,
                              appBar: CustomAppBar(
                                functionForLeft: toggleDrawer,
                                functionForRight:
                                    model.items.isNotEmpty ? deleteAll : () {},
                              ),
                              floatingActionButton: RectGetter(
                                key: rectGetterKey,
                                child: FloatingActionButton(
                                  onPressed: onColor,
                                  child: const Icon(Icons.add),
                                ),
                              ),
                              body: model.items.isEmpty
                                  ? const EmptyScreen()
                                  : listTypeService.switchValue
                                      ? Padding(
                                          padding: context.paddingLow,
                                          child: StackedCardCarousel(
                                            initialOffset: 0,
                                            spaceBetweenItems: 190,
                                            items: List.generate(
                                              model.items.length,
                                              (index) {
                                                List<String> values =
                                                    cardConfiguration(
                                                  model,
                                                  index,
                                                );
                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            maintainState:
                                                                false,
                                                            builder:
                                                                (context) =>
                                                                    EventDetail(
                                                                      values:
                                                                          values,
                                                                      eventService:
                                                                          eventService,
                                                                    ),
                                                            settings: RouteSettings(
                                                                arguments: model
                                                                        .items[
                                                                    index])));
                                                  },
                                                  child: EventCard(
                                                    eventDate: model
                                                        .items[index].eventDate,
                                                    title: model.items[index]
                                                        .eventTitle,
                                                    description: model
                                                            .items[index]
                                                            .eventDescription!
                                                            .isEmpty
                                                        ? "No Description"
                                                        : model.items[index]
                                                            .eventDescription
                                                            .toString(),
                                                    date:
                                                        '${values[0]} - ${values[1]}',
                                                    color: Color(
                                                        int.parse(values[2])),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: context.paddingLow,
                                          itemCount: model.items.length,
                                          itemBuilder: (context, index) {
                                            List<String> values =
                                                cardConfiguration(model, index);
                                            return Hero(
                                              tag: index,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EventDetail(
                                                                values: values,
                                                                eventService:
                                                                    eventService,
                                                              ),
                                                          settings: RouteSettings(
                                                              arguments:
                                                                  model.items[
                                                                      index])));
                                                },
                                                child: EventCard(
                                                  eventDate: model
                                                      .items[index].eventDate,
                                                  title: model
                                                      .items[index].eventTitle,
                                                  description: model
                                                          .items[index]
                                                          .eventDescription!
                                                          .isEmpty
                                                      ? "No Description"
                                                      : model.items[index]
                                                          .eventDescription
                                                          .toString(),
                                                  date:
                                                      '${values[0]} - ${values[1]}',
                                                  color: Color(
                                                      int.parse(values[2])),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),
                            splashWidget(),
                          ],
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
}

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Center(child: Text("There is no Event at the moment")),
        Positioned(
          bottom: 70,
          right: 70,
          child: Column(
            children: [
              const Text("Add from here",
                  style: TextStyle(color: ConstantColor.transparentGrey)),
              Image.asset(
                'assets/images/curly-arrow.png',
                scale: 1.5,
              )
            ],
          ),
        )
      ],
    );
  }
}
