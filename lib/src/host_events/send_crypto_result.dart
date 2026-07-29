part of '../host_event.dart';

final class SendCryptoResult extends HostEvent {
  const SendCryptoResult(this.payload);

  factory SendCryptoResult.txHash(String? txHash) => SendCryptoResult(SendCryptoResultTxHashPayload(txHash));

  factory SendCryptoResult.error([String? error]) => SendCryptoResult(SendCryptoResultErrorPayload(error));

  final SendCryptoResultPayload payload;

  @override
  String get type => 'SEND_CRYPTO_RESULT';

  @override
  Map<String, dynamic> payloadToJson() => payload.toJson();
}

sealed class SendCryptoResultPayload {
  const SendCryptoResultPayload();

  Map<String, dynamic> toJson();
}

final class SendCryptoResultTxHashPayload extends SendCryptoResultPayload {
  const SendCryptoResultTxHashPayload(this.txHash);

  final String? txHash;

  @override
  Map<String, dynamic> toJson() => {'txHash': txHash};
}

final class SendCryptoResultErrorPayload extends SendCryptoResultPayload {
  const SendCryptoResultErrorPayload([this.error]);

  final String? error;

  @override
  Map<String, dynamic> toJson() => {'error': error};
}
