import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:scheduler/components/custom_app_bar.dart';
import 'package:scheduler/components/custom_drawer.dart';
import 'package:scheduler/components/event_card.dart';
import 'package:scheduler/components/event_detail.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/localization/locale_keys.g.dart';
import 'package:scheduler/services/event_service.dart';
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
                  child: Consumer<EventService>(
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
                                  ? emptyScreen()
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
                                                        ? LocaleKeys
                                                            .noDescription
                                                            .tr()
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
                                                      ? LocaleKeys.noDescription
                                                          .tr()
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
