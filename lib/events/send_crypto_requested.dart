part of '../widget_event.dart';

final class SendCryptoRequested extends WidgetEvent {
  const SendCryptoRequested(this.payload);
  final SendCryptoPayload payload;
}

class SendCryptoPayload {
  const SendCryptoPayload({this.address, this.amount, this.assetInfo});

  final String? address;
  final String? amount;
  final SendCryptoAssetInfo? assetInfo;

  factory SendCryptoPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SendCryptoPayload();
    }
    return SendCryptoPayload(
      address: json['address'] as String?,
      amount: json['amount'] as String?,
      assetInfo: SendCryptoAssetInfo.fromJson(asStringKeyedMap(json['assetInfo'])),
    );
  }
}

class SendCryptoAssetInfo {
  const SendCryptoAssetInfo({this.chain, this.decimals, this.name, this.symbol, this.type});

  final String? chain;
  final int? decimals;
  final String? name;
  final String? symbol;
  final String? type;

  factory SendCryptoAssetInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SendCryptoAssetInfo();
    }
    return SendCryptoAssetInfo(
      chain: json['chain'] as String?,
      decimals: (json['decimals'] as num?)?.toInt(),
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      type: json['type'] as String?,
    );
  }
}
