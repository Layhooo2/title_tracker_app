

import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [Container(
            color: Theme.of(context).colorScheme.primary,
            width: 40,
            height: 40,
          ),
            Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              width: 40,
              height: 40,
            ),
            Container(
              color: Theme.of(context).colorScheme.secondary,
              width: 40,
              height: 40,
            ),
            Container(
              color: Theme.of(context).colorScheme.secondaryContainer,
              width: 40,
              height: 40,
            ),
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              width: 40,
              height: 40,
            ),
            Container(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              width: 40,
              height: 40,
            ),
            Container(
              //color: Theme.of(context).colorScheme.error,
              width: 40,
              height: 40,
            ),
            Container(
              //color: Theme.of(context).colorScheme.errorContainer,
              width: 40,
              height: 40,
            ),
          ],
        ),
      )
    );
  }
}