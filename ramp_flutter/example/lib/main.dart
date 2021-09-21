import 'package:flutter/material.dart';

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
  Configuration configuration = Configuration();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ramp Demo in Flutter'),
        ),
        body: Form(
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(hintText: "Widget URL"),
                onChanged: (text) => configuration.url = text,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "User email"),
                onChanged: (text) => configuration.userEmailAddress = text,
              ),
              TextField(
                decoration: const InputDecoration(hintText: "User address"),
                onChanged: (text) => configuration.userAddress = text,
              ),
              TextButton(
                onPressed: () {
                  RampFlutter.showRamp(configuration, _onPurchaseCreated,
                      _onRampClosed, _onRampFailed);
                },
                child: const Text("Show Ramp"),
              )
            ],
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
