import 'dart:async';

import 'package:flutter/services.dart';

class RampFlutter {
  static const MethodChannel _channel = MethodChannel('ramp_flutter');

  static Future<void> showRamp(
    Configuration configuration,
    Function(Purchase purchase) onPurchaseCreated,
    Function() onRampClosed,
    Function() onRampFailed,
  ) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onPurchaseCreated":
          print("on purchase created");
          break;
        case "onRampClosed":
          print("on ramp closed");
          break;
        case "onRampFailed":
          print("on ramp failed");
          break;
      }
      return Future(() => null);
    });

    await _channel.invokeMethod('showRamp', configuration.toMap());
  }
}

class Configuration {
  String? swapAsset;
  String? swapAmount;
  String? fiatCurrency;
  String? fiatValue;
  String? userAddress;
  String? hostLogoUrl;
  String? hostAppName;
  String? userEmailAddress;
  String? selectedCountryCode;
  String? defaultAsset;
  String? url;
  String? webhookStatusUrl;
  String? finalUrl;
  String? containerNode;
  String? hostApiKey;

  Map<String, dynamic> toMap() {
    return {
      'swapAsset': swapAsset,
      'swapAmount': swapAmount,
      'fiatCurrency': fiatCurrency,
      'fiatValue': fiatValue,
      'userAddress': userAddress,
      'hostLogoUrl': hostLogoUrl,
      'hostAppName': hostAppName,
      'userEmailAddress': userEmailAddress,
      'selectedCountryCode': selectedCountryCode,
      'defaultAsset': defaultAsset,
      'url': url,
      'webhookStatusUrl': webhookStatusUrl,
      'finalUrl': finalUrl,
      'containerNode': containerNode,
      'hostApiKey': hostApiKey,
    };
  }
}

class Purchase {}
