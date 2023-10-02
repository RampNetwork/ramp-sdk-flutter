import 'package:flutter/material.dart';
import 'package:ramp/controller/ramp_controller.dart';
import 'package:ramp/model/configuration.dart';
import 'dart:async';

import 'package:ramp/ramp_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('RampWidget example')),
        body: const BottomSheetExample(),
      ),
    );
  }

  Widget rampWidget() {
    Configuration configuration = Configuration();
    RampController controller = RampController()
      ..setConfiguration(configuration);
    return RampWidget2(controller: controller);

    return RampWidget(
      onOnrampPurchaseCreated: (purchase, token, apiUrl) =>
          // ignore: avoid_print
          print("Purchase created: $token"),
      onOfframpSaleCreated: (sale, token, apiUrl) =>
          // ignore: avoid_print
          print("Sale created: $token"),
      onSendCryptoRequested: (payload) =>
          // ignore: avoid_print
          print("Send crypto requested: $payload"),
      onRampClosed: () =>
          // ignore: avoid_print
          print("Ramp closed"),
    );
  }
}

class BottomSheetExample extends StatelessWidget {
  const BottomSheetExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text('showModalBottomSheet'),
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            enableDrag: false,
            useSafeArea: true,
            builder: (BuildContext context) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: const RampWidget(),
              );
            },
          );
        },
      ),
    );
  }
}
