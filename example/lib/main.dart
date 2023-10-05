import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'package:ramp/ramp_widget.dart';
import 'package:ramp/controller/event_delegate.dart';
import 'package:ramp/controller/ramp_controller.dart';
import 'package:ramp/model/configuration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late RampController rampController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('RampWidget example')),
        body: BottomSheetExample(),
      ),
    );
  }
}

class BottomSheetExample extends StatelessWidget {
  late final RampController rampController;

  BottomSheetExample({super.key}) {
    Configuration configuration = Configuration()
      ..hostAppName = "Mateusz Test"
      ..hostApiKey = "3qncr4yvxfpro6endeaeu6npkh8qc23e9uadtazq"
      ..enabledFlows = "ONRAMP,OFFRAMP"
      ..defaultFlow = "OFFRAMP"
      ..userEmailAddress = "mateusz.jablonski@ramp.network"
      ..fiatCurrency = "EUR"
      ..fiatValue = "2"
      ..swapAsset = "GOERLI_ETH"
      ..userAddress = "0x71C7656EC7ab88b098defB751B7401B5f6d8976F"
      ..useSendCryptoCallbackVersion = "1"
      ..url = "app.dev.ramp-network.org";
    rampController = RampController()
      ..configuration = configuration
      ..eventDelegate = EventDelegate(
        onRampClosed: () {
          developer.log("Widget closed");
        },
      );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('Show Ramp widget'),
        onPressed: () {
          rampController.start();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            enableDrag: false,
            useSafeArea: true,
            builder: (BuildContext context) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: RampWidget(
                  controller: rampController
                    ..eventDelegate?.onRampClosed =
                        () => Navigator.pop(context),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
