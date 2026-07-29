part of '../widget_event.dart';

final class SendCryptoRequested extends WidgetEvent {
  const SendCryptoRequested(this.payload, {super.widgetInstanceId});

  final SendCryptoPayload payload;
}

class SendCryptoPayload {
  const SendCryptoPayload({this.address, this.amount, this.assetInfo});

  final String? address;
  final String? amount;
  final AssetInfo? assetInfo;

  factory SendCryptoPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SendCryptoPayload();
    }
    return SendCryptoPayload(
      address: json['address'] as String?,
      amount: asString(json['amount']),
      assetInfo: AssetInfo.fromJson(asStringKeyedMap(json['assetInfo'])),
    );
  }
}
