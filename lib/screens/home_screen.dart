import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/models/event_model.dart';
import 'package:scheduler/providers/color_provider.dart';
import 'package:scheduler/providers/event_provider.dart';
import 'package:scheduler/screens/create_event_screen.dart';
import 'package:scheduler/services/event_service.dart';

import '../components/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late EventService eventService;
  @override
  void initState() {
    eventService = EventService();
    eventService.getAllEvents();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<EventModel> items =
        Provider.of<EventProvider>(context, listen: true).items;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {},
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
        body: StreamBuilder(
          stream: eventService.getAllEvents().asStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                padding: context.paddingLow,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return EventCard(
                    title: snapshot.data![index].eventTitle,
                    description: snapshot.data![index].eventDescription ??
                        "Null but assigned",
                    date: snapshot.data![index].eventDate.toString(),
                  );
                },
              );
            }
            return Container(
              height: 100,
              width: 100,
              color: Colors.amber,
            );
          },
        ));
  }
}
