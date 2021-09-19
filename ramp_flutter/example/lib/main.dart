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
              configuration.url = "https://ri-widget-staging.firebaseapp.com/";
              configuration.userEmailAddress =
                  "mateusz.mail.kontaktowy@gmail.com";
              configuration.userAddress =
                  "0x89205A3A3b2A69De6Dbf7f01ED13B2108B2c43e7";
              RampFlutter.showRamp(
                configuration,
                _onPurchaseCreated,
                _onRampClosed,
                _onRampFailed,
              );
            },
            child: const Text("GO GO GO!"),
          ),
        ),
      ),
    );
  }

  void _onPurchaseCreated(Purchase purchase) {
    print(purchase);
  }

  void _onRampClosed() {
    print("_onRampClosed");
  }

  void _onRampFailed() {
    print("_onRampFailed");
  }
}
