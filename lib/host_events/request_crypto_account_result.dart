part of '../host_event.dart';

final class RequestCryptoAccountResult extends HostEvent {
  const RequestCryptoAccountResult._(this.payload);

  factory RequestCryptoAccountResult.account({
    required String address,
    String? type,
    String? name,
    String? assetSymbol,
  }) => RequestCryptoAccountResult._({
    'address': address,
    'type': ?type,
    'name': ?name,
    'assetSymbol': ?assetSymbol,
  });

  factory RequestCryptoAccountResult.error([String? error]) =>
      RequestCryptoAccountResult._({'error': error});

  final Map<String, dynamic> payload;

  @override
  String get type => 'REQUEST_CRYPTO_ACCOUNT_RESULT';

  @override
  Object? get jsonPayload => payload;
}
