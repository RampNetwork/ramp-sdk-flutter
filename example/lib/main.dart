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
                child: _rampWidget(),
              );
            },
          );
        },
      ),
    );
  }

  Widget _rampWidget() {
    Configuration configuration = Configuration();
    RampController controller = RampController()
      ..setConfiguration(configuration);
    RampWidget widget = RampWidget(controller: controller);
    controller.start();
    return widget;
  }
}
