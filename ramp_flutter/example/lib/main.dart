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
  final Configuration _configuration = Configuration();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Ramp Demo in Flutter'),
        ),
        body: Builder(
          builder: (context) => Form(
            child: Column(children: _formFields(context)),
          ),
        ),
      ),
    );
  }

  List<Widget> _formFields(BuildContext context) {
    return [
      TextField(
        decoration: const InputDecoration(hintText: "Widget URL"),
        onChanged: (text) => _configuration.url = text,
      ),
      TextField(
        decoration: const InputDecoration(hintText: "User email"),
        onChanged: (text) => _configuration.userEmailAddress = text,
      ),
      TextField(
        decoration: const InputDecoration(hintText: "User address"),
        onChanged: (text) => _configuration.userAddress = text,
      ),
      TextButton(
        onPressed: () {
          RampFlutter.showRamp(
            _configuration,
            (purchase) => _showSnackBar(context, "Purchase created"),
            () => _showSnackBar(context, "Ramp widget closed"),
            () => _showSnackBar(context, "Ramp widget failed"),
          );
        },
        child: const Text("Show Ramp"),
      ),
    ];
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }
}
