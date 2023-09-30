class Configuration {
  // Documentation: https://docs.ramp.network/configuration

  static const defaultUrl = "app.ramp.network";
  static const mobileSdkVariant = "sdk-mobile";
  static const sdkType = "Flutter";
  static const sdkVersion = "0.0.1";

  String? containerNode;
  String? deepLinkScheme; // undocumented, mobile specific
  String? defaultAsset;
  String? defaultFlow;
  String? enabledFlows;
  String? fiatCurrency;
  String? fiatValue;
  String? finalUrl;
  String? hostApiKey;
  String? hostAppName;
  String? hostLogoUrl;
  String? offrampWebhookV3Url;
  String? selectedCountryCode;
  // String? sdkType; // undocumented, mobile specific, using constant value
  // String? sdkVersion; // undocumented, mobile specific, using constant value
  String? swapAmount;
  String? swapAsset;
  String? offrampAsset;
  String? url; // base URL (not a query parameter)
  String? userAddress;
  String? userEmailAddress;
  String? useSendCryptoCallbackVersion; // documented as useSendCryptoCallback
  // String? variant; // using constant value
  String? webhookStatusUrl;

  Map<String, dynamic> _queryParameters() {
    Map<String, dynamic> queryParameters = {
      "containerNode": containerNode,
      "deepLinkScheme": deepLinkScheme,
      "defaultAsset": defaultAsset,
      "defaultFlow": defaultFlow,
      "enabledFlows": enabledFlows,
      "fiatCurrency": fiatCurrency,
      "fiatValue": fiatValue,
      "finalUrl": finalUrl,
      "hostApiKey": hostApiKey,
      "hostAppName": hostAppName,
      "hostLogoUrl": hostLogoUrl,
      "offrampWebhookV3Url": offrampWebhookV3Url,
      "sdkType": Configuration.sdkType,
      "sdkVersion": Configuration.sdkVersion,
      "selectedCountryCode": selectedCountryCode,
      "swapAmount": swapAmount,
      "swapAsset": swapAsset,
      "offrampAsset": offrampAsset,
      "userAddress": userAddress,
      "userEmailAddress": userEmailAddress,
      "useSendCryptoCallbackVersion": useSendCryptoCallbackVersion,
      "variant": Configuration.mobileSdkVariant,
      "webhookStatusUrl": webhookStatusUrl,
    };
    queryParameters.removeWhere((key, value) => value == null);
    return queryParameters;
  }

  Uri configurationUrl() {
    return Uri(
      scheme: "https",
      host: url ?? Configuration.defaultUrl,
      queryParameters: _queryParameters(),
    );
  }
}
