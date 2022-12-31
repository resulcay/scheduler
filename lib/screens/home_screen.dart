import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scheduler/extensions/padding_extension.dart';
import 'package:scheduler/screens/create_event_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CreateEventScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: context.paddingLow,
        itemCount: 10,
        itemBuilder: (context, index) {
          double value = Random().nextDouble();
          if (value < .2) {
            value += .7;
          }
          var generatedColor = Random().nextInt(Colors.primaries.length);
          var finalColor = Colors.primaries[generatedColor].withOpacity(value);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: context.paddingLow,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: finalColor,
            ),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  "Event  Title",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 35),
                  child: Text(
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    "Some text here Some text  Some text here Some text here Some text here Some text here Some text here Some text here  Some text  Some text here Some text here Some text  Some text here Some text here Some text here here Some text here Some text here v",
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      fontSize: 14,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "5 March 1998",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
