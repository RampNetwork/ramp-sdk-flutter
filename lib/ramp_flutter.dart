import 'dart:async';

import 'package:flutter/services.dart';

/// Wrapper class for Ramp Flutter widget
class RampFlutter {
  static const MethodChannel _channel = MethodChannel('ramp_flutter');

  /// Presents Ramp widget on current context
  ///
  /// This function accepts four parameters:
  /// [Configuration] holds all settings for displaying the widget,
  /// [onPurchaseCreated] is called, when the purchase is created,
  /// [onRampClosed] is called, when Ramp widget is being closed,
  /// [onRampFailed] is called, when Ramp fails for any reason.
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
          Purchase purchase = Purchase._fromArguments(call.arguments[0]);
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

    await _channel.invokeMethod('showRamp', configuration._toMap());
  }
}

/// Ramp widget configuration
///
/// Widget will be populated with these parameters
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

  Map<String, dynamic> _toMap() {
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

/// Ramp purchase information
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

  static Purchase _fromArguments(arguments) {
    Purchase purchase = Purchase();
    purchase.id = arguments['id'];
    purchase.endTime = arguments['endTime'];
    purchase.asset = AssetInfo._fromArguments(arguments['asset']);
    purchase.receiverAddress = arguments['receiverAddress'];
    purchase.cryptoAmount = arguments['cryptoAmount'];
    purchase.fiatCurrency = arguments['fiatCurrency'];
    purchase.fiatValue = arguments['fiatValue'];
    purchase.assetExchangeRate = arguments['assetExchangeRate'];
    purchase.baseRampFee = arguments['baseRampFee'];
    purchase.networkFee = arguments['networkFee'];
    purchase.appliedFee = arguments['appliedFee'];
    purchase.paymentMethodType = arguments['paymentMethodType'];
    purchase.finalTxHash = arguments['finalTxHash'];
    purchase.createdAt = arguments['createdAt'];
    purchase.updatedAt = arguments['updatedAt'];
    purchase.status = arguments['status'];
    purchase.escrowAddress = arguments['escrowAddress'];
    purchase.escrowDetailsHash = arguments['escrowDetailsHash'];
    return purchase;
  }
}

class AssetInfo {
  String? address;
  String? symbol;
  String? type;
  String? name;
  int? decimals;

  static AssetInfo _fromArguments(arguments) {
    AssetInfo assetInfo = AssetInfo();
    assetInfo.address = arguments['address'];
    assetInfo.symbol = arguments['symbol'];
    assetInfo.type = arguments['type'];
    assetInfo.name = arguments['name'];
    assetInfo.decimals = arguments['decimals'];
    return assetInfo;
  }
}
