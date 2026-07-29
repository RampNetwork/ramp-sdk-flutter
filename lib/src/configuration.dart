class Configuration {
  const Configuration({
    this.url,
    this.defaultFlow,
    this.enabledFlows,
    this.enabledCryptoAssets,
    this.inAsset,
    this.inAssetValue,
    this.outAsset,
    this.outAssetValue,
    this.finalUrl,
    this.hostApiKey,
    this.hostAppName,
    this.offrampWebhookV3Url,
    this.selectedCountryCode,
    this.userAddress,
    this.userEmailAddress,
    this.useSendCryptoCallback,
    this.webhookStatusUrl,
  });

  static const String defaultUrl = 'https://app.rampnetwork.com';
  static const String sdkType = 'FLUTTER';
  static const String sdkVersion = '5.0.0';

  final String? url;
  final String? defaultFlow;
  final List<String>? enabledFlows;
  final List<String>? enabledCryptoAssets;
  final String? inAsset;
  final String? inAssetValue;
  final String? outAsset;
  final String? outAssetValue;
  final String? finalUrl;
  final String? hostApiKey;
  final String? hostAppName;
  final String? offrampWebhookV3Url;
  final String? selectedCountryCode;
  final String? userAddress;
  final String? userEmailAddress;
  final bool? useSendCryptoCallback;
  final String? webhookStatusUrl;

  Uri buildWidgetUrl() {
    final base = Uri.parse((url != null && url!.trim().isNotEmpty) ? url!.trim() : defaultUrl);
    if (base.queryParameters['signature']?.isNotEmpty == true) {
      throw StateError(
        'Configuration.buildWidgetUrl() cannot be used with a signed URL. '
        'Use RampFlutter.signed(...) instead.',
      );
    }

    final queryParameters = <String, String>{
      ...base.queryParameters,
      if (_nonEmpty(defaultFlow)) 'defaultFlow': defaultFlow!,
      if (enabledFlows != null && enabledFlows!.isNotEmpty) 'enabledFlows': enabledFlows!.join(','),
      if (enabledCryptoAssets != null && enabledCryptoAssets!.isNotEmpty)
        'enabledCryptoAssets': enabledCryptoAssets!.join(','),
      if (_nonEmpty(inAsset)) 'inAsset': inAsset!,
      if (_nonEmpty(inAssetValue)) 'inAssetValue': inAssetValue!,
      if (_nonEmpty(outAsset)) 'outAsset': outAsset!,
      if (_nonEmpty(outAssetValue)) 'outAssetValue': outAssetValue!,
      if (_nonEmpty(finalUrl)) 'finalUrl': finalUrl!,
      if (_nonEmpty(hostApiKey)) 'hostApiKey': hostApiKey!,
      if (_nonEmpty(hostAppName)) 'hostAppName': hostAppName!,
      if (_nonEmpty(offrampWebhookV3Url)) 'offrampWebhookV3Url': offrampWebhookV3Url!,
      if (_nonEmpty(selectedCountryCode)) 'selectedCountryCode': selectedCountryCode!,
      if (_nonEmpty(userAddress)) 'userAddress': userAddress!,
      if (_nonEmpty(userEmailAddress)) 'userEmailAddress': userEmailAddress!,
      if (_nonEmpty(webhookStatusUrl)) 'webhookStatusUrl': webhookStatusUrl!,
      'sdkType': sdkType,
      'sdkVersion': sdkVersion,
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
