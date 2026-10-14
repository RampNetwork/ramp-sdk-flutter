import 'package:ramp_flutter/src/enums.dart';
import 'package:ramp_flutter/src/signed_url.dart';

export 'package:ramp_flutter/src/enums.dart';

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
    this.hostApiKey,
    this.offrampWebhookV3Url,
    this.paymentMethodType,
    this.selectedCountryCode,
    this.userAddress,
    this.userEmailAddress,
    this.useSendCryptoCallback,
    this.webhookStatusUrl,
  });

  static const String defaultUrl = 'https://app.rampnetwork.com';
  static const String sdkType = 'FLUTTER';
  static const String sdkVersion = '5.0.0';
  static const int sendCryptoProtocolVersion = 1;

  final String? url;
  final TransactionFlow? defaultFlow;
  final List<TransactionFlow>? enabledFlows;
  final List<String>? enabledCryptoAssets;
  final String? inAsset;
  final String? inAssetValue;
  final String? outAsset;
  final String? outAssetValue;
  final String? hostApiKey;
  final String? offrampWebhookV3Url;
  final PaymentMethodType? paymentMethodType;
  final String? selectedCountryCode;
  final String? userAddress;
  final String? userEmailAddress;
  final bool? useSendCryptoCallback;
  final String? webhookStatusUrl;

  Uri buildWidgetUrl() {
    final trimmedUrl = url?.trim();
    final base = Uri.parse(_nonEmpty(trimmedUrl) ? trimmedUrl! : defaultUrl);
    if (base.queryParameters['signature']?.isNotEmpty == true) {
      throw StateError(
        'Configuration.buildWidgetUrl() cannot be used with a signed URL. '
        'Use RampFlutter.signed(...) instead.',
      );
    }
    if (!isTrustedRampWidgetUrl(base)) {
      throw ArgumentError.value(base.toString(), 'url', 'Untrusted Ramp Network URL');
    }

    return base.replace(
      path: base.path.isEmpty ? '/' : base.path,
      queryParameters: {
        ...base.queryParameters,
        if (defaultFlow != null) 'defaultFlow': defaultFlow!.name,
        if (enabledFlows != null && enabledFlows!.isNotEmpty)
          'enabledFlows': enabledFlows!.map((flow) => flow.name).join(','),
        if (enabledCryptoAssets != null && enabledCryptoAssets!.isNotEmpty)
          'enabledCryptoAssets': enabledCryptoAssets!.join(','),
        if (_nonEmpty(inAsset)) 'inAsset': inAsset!,
        if (_nonEmpty(inAssetValue)) 'inAssetValue': inAssetValue!,
        if (_nonEmpty(outAsset)) 'outAsset': outAsset!,
        if (_nonEmpty(outAssetValue)) 'outAssetValue': outAssetValue!,
        if (_nonEmpty(hostApiKey)) 'hostApiKey': hostApiKey!,
        if (_nonEmpty(offrampWebhookV3Url)) 'offrampWebhookV3Url': offrampWebhookV3Url!,
        if (paymentMethodType != null) 'paymentMethodType': paymentMethodType!.name,
        if (_nonEmpty(selectedCountryCode)) 'selectedCountryCode': selectedCountryCode!,
        if (_nonEmpty(userAddress)) 'userAddress': userAddress!,
        if (_nonEmpty(userEmailAddress)) 'userEmailAddress': userEmailAddress!,
        if (_nonEmpty(webhookStatusUrl)) 'webhookStatusUrl': webhookStatusUrl!,
        if (useSendCryptoCallback == true) 'useSendCryptoCallbackVersion': sendCryptoProtocolVersion.toString(),
        'sdkType': sdkType,
        'sdkVersion': sdkVersion,
      },
    );
  }

  static bool _nonEmpty(String? value) => value != null && value.isNotEmpty;
}
