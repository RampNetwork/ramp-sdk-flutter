import 'dart:ffi';

class Configuration {
  // main URL
  String? url;

  // query params
  String? containerNode;
  String? deepLinkScheme;
  String? defaultAsset;
  String? defaultFlow;
  List<String>? enabledFlows;
  String? fiatCurrency;
  String? fiatValue;
  String? finalUrl;
  String? hostApiKey;
  String? hostAppName;
  String? hostLogoUrl;
  String? offrampWebhookV3Url;
  String? selectedCountryCode;
  String? swapAmount;
  String? swapAsset;
  String? userAddress;
  String? userEmailAddress;
  Bool? useSendCryptoCallback;
  String? variant;
  String? webhookStatusUrl;

  Map<String, dynamic> toMap() {
    return {
      'url': url, // main URL
      'containerNode': containerNode,
      'deepLinkScheme': deepLinkScheme,
      'defaultAsset': defaultAsset,
      'defaultFlow': defaultFlow,
      'enabledFlows': enabledFlows,
      'fiatCurrency': fiatCurrency,
      'fiatValue': fiatValue,
      'finalUrl': finalUrl,
      'hostApiKey': hostApiKey,
      'hostAppName': hostAppName,
      'hostLogoUrl': hostLogoUrl,
      'offrampWebhookV3Url': offrampWebhookV3Url,
      'selectedCountryCode': selectedCountryCode,
      'swapAmount': swapAmount,
      'swapAsset': swapAsset,
      'userAddress': userAddress,
      'userEmailAddress': userEmailAddress,
      'useSendCryptoCallback': useSendCryptoCallback,
      'variant': variant,
      'webhookStatusUrl': webhookStatusUrl,
    };
  }
}
