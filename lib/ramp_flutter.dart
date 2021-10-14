import 'dart:async';

import 'package:flutter/services.dart';

class RampFlutter {
  static const MethodChannel _channel = MethodChannel('ramp_flutter');

  static Future<void> showRamp(
    Configuration configuration,
    Function(Purchase purchase, String purchaseViewToken, String apiUrl)
        onPurchaseCreated,
    Function() onRampClosed,
    Function() onRampFailed,
  ) async {
    _channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onPurchaseCreated":
          Purchase purchase = Purchase.fromArguments(call.arguments[0]);
          String purchaseViewToken = call.arguments[1];
          String apiUrl = call.arguments[2];
          onPurchaseCreated(purchase, purchaseViewToken, apiUrl);
          break;
        case "onRampClosed":
          onRampClosed();
          break;
        case "onRampFailed":
          onRampFailed();
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
  String? deepLinkScheme;

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
      'deepLinkScheme': deepLinkScheme,
    };
  }
}

class Purchase {
  String? id;
  String? endTime;
  AssetInfo? asset;
  String? receiverAddress;
  String? cryptoAmount;
  String? fiatCurrency;
  int? fiatValue;
  int? assetExchangeRate;
  int? baseRampFee;
  int? networkFee;
  int? appliedFee;
  String? paymentMethodType;
  String? finalTxHash;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? escrowAddress;
  String? escrowDetailsHash;

  static Purchase fromArguments(arguments) {
    return Purchase();
  }
}

class AssetInfo {
  String? address;
  String? symbol;
  String? type;
  String? name;
  int? decimals;
}
