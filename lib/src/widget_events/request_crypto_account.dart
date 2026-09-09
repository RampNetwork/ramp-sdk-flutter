part of '../widget_event.dart';

final class RequestCryptoAccount extends WidgetEvent {
  const RequestCryptoAccount(this.payload, {super.widgetInstanceId});

  final RequestCryptoAccountPayload payload;
}

class RequestCryptoAccountPayload {
  const RequestCryptoAccountPayload({this.type, this.assetSymbol});

  final String? type;
  final String? assetSymbol;

  factory RequestCryptoAccountPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const RequestCryptoAccountPayload();
    }
    return RequestCryptoAccountPayload(type: json['type'] as String?, assetSymbol: json['assetSymbol'] as String?);
  }
}
