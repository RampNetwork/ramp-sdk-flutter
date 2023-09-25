import 'package:flutter/material.dart';
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
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('RampWidget example')),
        body: RampWidget(
          onOnrampPurchaseCreated: (purchase, purchaseViewToken, apiUrl) =>
              // ignore: avoid_print
              print("Purchase created: $purchaseViewToken"),
          onOfframpSaleCreated: (sale, saleViewToken, apiUrl) =>
              // ignore: avoid_print
              print("Sale created: $saleViewToken"),
          onSendCryptoRequested: (payload) =>
              // ignore: avoid_print
              print("Send crypto requested: $payload"),
          onRampClosed: () =>
              // ignore: avoid_print
              print("Ramp closed"),
        ),
      ),
    );
  }
}
