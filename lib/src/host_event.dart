part 'host_events/request_crypto_account_result.dart';
part 'host_events/send_crypto_result.dart';

sealed class HostEvent {
  const HostEvent();

  String get type;

  Map<String, dynamic> payloadToJson();

  Map<String, dynamic> toJson() => {'type': type, 'payload': payloadToJson()};
}
