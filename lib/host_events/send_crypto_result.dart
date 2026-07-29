part of '../host_event.dart';

final class SendCryptoResult extends HostEvent {
  const SendCryptoResult._(this.payload);

  factory SendCryptoResult.txHash(String? txHash) => SendCryptoResult._({'txHash': txHash});

  factory SendCryptoResult.error([String? error]) => SendCryptoResult._({'error': error});

  final Map<String, dynamic> payload;

  @override
  String get type => 'SEND_CRYPTO_RESULT';

  @override
  Object? get jsonPayload => payload;
}
