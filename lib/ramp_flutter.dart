import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

import 'configuration.dart';

class RampFlutter {
  final MethodChannel _channel = const MethodChannel('ramp_flutter');

  Function(OnrampPurchase, String, String)? onOnrampPurchaseCreated;
  Function(SendCryptoPayload payload)? onSendCryptoRequested;
  Function(OfframpSale, String, String)? onOfframpSaleCreated;
  Function()? onRampClosed;

  void _handleOnOnrampPurchaseCreated(dynamic arguments) {
    dynamic payload = arguments[0];
    String purchaseViewToken = arguments[1];
    String apiUrl = arguments[2];
    OnrampPurchase purchase = OnrampPurchase.fromArguments(payload);
    onOnrampPurchaseCreated!(purchase, purchaseViewToken, apiUrl);
  }

  void _handleOnSendCryptoRequested(dynamic arguments) {
    dynamic payload = arguments[0];
    SendCryptoPayload sendCrypto = SendCryptoPayload.fromArguments(payload);
    onSendCryptoRequested!(sendCrypto);
  }

  void _handleOnOfframpSaleCreated(dynamic arguments) {
    dynamic payload = arguments[0];
    String saleViewToken = arguments[1];
    String apiUrl = arguments[2];
    OfframpSale sale = OfframpSale.fromArguments(payload);
    onOfframpSaleCreated!(sale, saleViewToken, apiUrl);
  }

  void _handleOnRampClosed() {
    onRampClosed!();
  }

  Future<void> _didRecieveMethodCall(MethodCall call) async {
    switch (call.method) {
      case "onOnrampPurchaseCreated":
        _handleOnOnrampPurchaseCreated(call.arguments);
        break;
      case "onSendCryptoRequested":
        _handleOnSendCryptoRequested(call.arguments);
        break;
      case "onOfframpSaleCreated":
        _handleOnOfframpSaleCreated(call.arguments);
        break;
      case "onRampClosed":
        _handleOnRampClosed();
        break;
    }
  }

  Future<void> showRamp(
    Configuration configuration,
  ) async {
    _channel.setMethodCallHandler(_didRecieveMethodCall);
    await _channel.invokeMethod('showRamp', configuration.toMap());
  }

  Future<void> sendCrypto(String? transactionHash) async {
    await _channel.invokeMethod('sendCrypto', transactionHash);
  }
}
