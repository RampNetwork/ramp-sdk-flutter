import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ramp_flutter/ramp_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: TextButton(
            onPressed: () {
              Configuration configuration = Configuration();
              configuration.userEmailAddress = "test@test.pl";
              RampFlutter.showRamp(
                configuration,
                (purchase) => null,
                () => null,
                () => null,
              );
            },
            child: const Text("GO GO GO!"),
          ),
        ),
      ),
    );
  }
}
