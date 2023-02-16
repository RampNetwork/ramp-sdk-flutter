import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

import 'configuration.dart';

class RampFlutter {
  static const MethodChannel _channel = MethodChannel('ramp_flutter');

  static void setupCallbacks(
    Function() onWidgetConfigDone,
    Function(OnrampPurchase purchase, String purchaseViewToken, String apiUrl)
        onOnrampPurchaseCreated,
    Function(SendCryptoPayload payload) onSendCryptoRequested,
    Function(OfframpSale sale, String saleViewToken, String apiUrl)
        onOfframpSaleCreated,
    Function() onRampClosed,
  ) {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onOnrampPurchaseCreated":
          OnrampPurchase purchase =
              OnrampPurchase.fromArguments(call.arguments[0]);
          String purchaseViewToken = call.arguments[1];
          String apiUrl = call.arguments[2];
          onOnrampPurchaseCreated(purchase, purchaseViewToken, apiUrl);
          break;
        case "onSendCryptoRequested":
          SendCryptoPayload payload =
              SendCryptoPayload.fromArguments(call.arguments[0]);
          onSendCryptoRequested(payload);
          break;
        case "onOfframpSaleCreated":
          OfframpSale sale = OfframpSale.fromArguments(call.arguments[0]);
          String saleViewToken = call.arguments[1];
          String apiUrl = call.arguments[2];
          onOfframpSaleCreated(sale, saleViewToken, apiUrl);
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
