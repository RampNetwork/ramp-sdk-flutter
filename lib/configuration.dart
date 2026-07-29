class Configuration {
  static const String defaultUrl = 'https://app.rampnetwork.com';
  static const String sdkType = 'Flutter';
  static const String sdkVersion = '5.0.0';
  static const String mobileSdkVariant = 'sdk-mobile';

  /// Base widget URL (scheme + host + optional path). Query is built from fields below.
  String? url;

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
  String? offrampAsset;
  String? offrampWebhookV3Url;
  String? selectedCountryCode;
  String? swapAmount;
  String? swapAsset;
  String? userAddress;
  String? userEmailAddress;
  bool? useSendCryptoCallback;
  /// Ignored when building the URL; the SDK always sends [mobileSdkVariant].
  String? variant;
  String? webhookStatusUrl;

  /// Builds the widget URL from [url] and configuration query parameters.
  Uri buildWidgetUrl() {
    final base = Uri.parse(
      (url != null && url!.trim().isNotEmpty) ? url!.trim() : defaultUrl,
    );

    final queryParameters = <String, String>{
      ...base.queryParameters,
      if (_nonEmpty(containerNode)) 'containerNode': containerNode!,
      if (_nonEmpty(deepLinkScheme)) 'deepLinkScheme': deepLinkScheme!,
      if (_nonEmpty(defaultAsset)) 'defaultAsset': defaultAsset!,
      if (_nonEmpty(defaultFlow)) 'defaultFlow': defaultFlow!,
      if (enabledFlows != null && enabledFlows!.isNotEmpty)
        'enabledFlows': enabledFlows!.join(','),
      if (_nonEmpty(fiatCurrency)) 'fiatCurrency': fiatCurrency!,
      if (_nonEmpty(fiatValue)) 'fiatValue': fiatValue!,
      if (_nonEmpty(finalUrl)) 'finalUrl': finalUrl!,
      if (_nonEmpty(hostApiKey)) 'hostApiKey': hostApiKey!,
      if (_nonEmpty(hostAppName)) 'hostAppName': hostAppName!,
      if (_nonEmpty(hostLogoUrl)) 'hostLogoUrl': hostLogoUrl!,
      if (_nonEmpty(offrampAsset)) 'offrampAsset': offrampAsset!,
      if (_nonEmpty(offrampWebhookV3Url))
        'offrampWebhookV3Url': offrampWebhookV3Url!,
      if (_nonEmpty(selectedCountryCode))
        'selectedCountryCode': selectedCountryCode!,
      if (_nonEmpty(swapAmount)) 'swapAmount': swapAmount!,
      if (_nonEmpty(swapAsset)) 'swapAsset': swapAsset!,
      if (_nonEmpty(userAddress)) 'userAddress': userAddress!,
      if (_nonEmpty(userEmailAddress)) 'userEmailAddress': userEmailAddress!,
      if (_nonEmpty(webhookStatusUrl)) 'webhookStatusUrl': webhookStatusUrl!,
      'sdkType': sdkType,
      'sdkVersion': sdkVersion,
      'variant': mobileSdkVariant,
    };

    if (useSendCryptoCallback == true) {
      queryParameters['useSendCryptoCallbackVersion'] = '1';
    }

    return base.replace(
      scheme: base.scheme.isEmpty ? 'https' : base.scheme,
      path: base.path.isEmpty ? '/' : base.path,
      queryParameters: queryParameters,
    );
  }

  static bool _nonEmpty(String? value) => value != null && value.isNotEmpty;
}
