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

import '../components/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    context.watch<EventProvider>().getAllEvents();

    return Consumer<EventProvider>(
      builder: (context, model, child) {
        return Scaffold(
          key: scaffoldKey,
          drawer: Drawer(
              child: ListView(
            children: [
              Switch(
                value: Provider.of<ListTypeProvider>(context).switchValue,
                onChanged: (value) {
                  Provider.of<ListTypeProvider>(context, listen: false)
                      .changeSwitch(value);
                },
              ),
            ],
          )),
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
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
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              Provider.of<ColorProvider>(context, listen: false)
                  .changeColor(randomColor());
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CreateEventScreen()));
            },
            child: const Icon(Icons.add),
          ),
          body: model.items.isEmpty
              ? const Center(child: Text("There is no Event at the moment"))
              : Provider.of<ListTypeProvider>(context).switchValue
                  ? Padding(
                      padding: context.paddingLow,
                      child: StackedCardCarousel(
                          initialOffset: 0,
                          spaceBetweenItems: 190,
                          items: List.generate(model.items.length, (index) {
                            List<String> values =
                                _cardConfiguration(model, index);
                            return EventCard(
                              title: model.items[index].eventTitle,
                              description:
                                  model.items[index].eventDescription!.isEmpty
                                      ? "No Description"
                                      : model.items[index].eventDescription
                                          .toString(),
                              date: '${values[0]} - ${values[1]}',
                              color: Color(int.parse(values[2])),
                            );
                          })),
                    )
                  : ListView.builder(
                      padding: context.paddingLow,
                      itemCount: model.items.length,
                      itemBuilder: (context, index) {
                        List<String> values = _cardConfiguration(model, index);
                        return EventCard(
                          title: model.items[index].eventTitle,
                          description: model
                                  .items[index].eventDescription!.isEmpty
                              ? "No Description"
                              : model.items[index].eventDescription.toString(),
                          date: '${values[0]} - ${values[1]}',
                          color: Color(int.parse(values[2])),
                        );
                      },
                    ),
        );
      },
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
}
