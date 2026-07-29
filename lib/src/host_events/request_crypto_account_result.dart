part of '../host_event.dart';

final class RequestCryptoAccountResult extends HostEvent {
  const RequestCryptoAccountResult(this.payload);

  factory RequestCryptoAccountResult.account({
    required String address,
    String? type,
    String? name,
    String? assetSymbol,
  }) => RequestCryptoAccountResult(
    RequestCryptoAccountSuccessPayload(address: address, type: type, name: name, assetSymbol: assetSymbol),
  );

  factory RequestCryptoAccountResult.error([String? error]) =>
      RequestCryptoAccountResult(RequestCryptoAccountErrorPayload(error));

  final RequestCryptoAccountResultPayload payload;

  @override
  String get type => 'REQUEST_CRYPTO_ACCOUNT_RESULT';

  @override
  Map<String, dynamic> payloadToJson() => payload.toJson();
}

sealed class RequestCryptoAccountResultPayload {
  const RequestCryptoAccountResultPayload();

  Map<String, dynamic> toJson();
}

final class RequestCryptoAccountSuccessPayload extends RequestCryptoAccountResultPayload {
  const RequestCryptoAccountSuccessPayload({required this.address, this.type, this.name, this.assetSymbol});

  final String address;
  final String? type;
  final String? name;
  final String? assetSymbol;

  @override
  Map<String, dynamic> toJson() => {'address': address, 'type': ?type, 'name': ?name, 'assetSymbol': ?assetSymbol};
}

final class RequestCryptoAccountErrorPayload extends RequestCryptoAccountResultPayload {
  const RequestCryptoAccountErrorPayload([this.error]);

  final String? error;

  @override
  Map<String, dynamic> toJson() => {'error': error};
}
