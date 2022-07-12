import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ramp_flutter/offramp_purchase.dart';
import 'package:ramp_flutter/purchase.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

import 'configuration.dart';

class RampFlutter {
  static const MethodChannel _channel = MethodChannel('ramp_flutter');

  static void setupCallbacks(
    Function() onWidgetConfigDone,
    Function(Purchase purchase, String purchaseViewToken, String apiUrl)
        onPurchaseCreated,
    Function(SendCryptoPayload payload) onOfframpRequested,
    Function(OfframpPurchase purchase, String purchaseViewToken, String apiUrl)
        onOfframpPurchaseCreated,
    Function() onRampClosed,
  ) {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onWidgetConfigDone":
          onWidgetConfigDone();
          break;
        case "onPurchaseCreated":
          Purchase purchase = Purchase.fromArguments(call.arguments[0]);
          String purchaseViewToken = call.arguments[1];
          String apiUrl = call.arguments[2];
          onPurchaseCreated(purchase, purchaseViewToken, apiUrl);
          break;
        case "onOfframpRequested":
          SendCryptoPayload payload = SendCryptoPayload();
          onOfframpRequested(payload);
          break;
        case "onOfframpPurchaseCreated":
          OfframpPurchase purchase =
              OfframpPurchase.fromArguments(call.arguments[0]);
          String purchaseViewToken = call.arguments[1];
          String apiUrl = call.arguments[2];
          onOfframpPurchaseCreated(purchase, purchaseViewToken, apiUrl);
          break;
        case "onRampClosed":
          onRampClosed();
          break;
      }
      return Future(() => null);
    });
  }

  static Future<void> showRamp(
    Configuration configuration,
  ) async {
    await _channel.invokeMethod('showRamp', configuration.toMap());
  }

  static Future<void> sendCrypto(String? transactionHash) async {
    await _channel.invokeMethod('sendCrypto', transactionHash);
  }
}
