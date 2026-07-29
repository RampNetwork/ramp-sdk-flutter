import 'package:ramp_flutter/events/json_map.dart';

part 'events/offramp_sale_created.dart';
part 'events/purchase_created.dart';
part 'events/ramp_closed.dart';
part 'events/send_crypto_requested.dart';

/// Incoming widget events from the original Flutter SDK surface.
///
/// `PURCHASE_CREATED` / `OFFRAMP_SALE_CREATED` / `WIDGET_CLOSE` are signals
/// only (no payload decoding).
sealed class WidgetEvent {
  const WidgetEvent();

  static WidgetEvent? tryParse(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is! String) {
      return null;
    }
    final payload = asStringKeyedMap(json['payload']);

    try {
      switch (type) {
        case 'OFFRAMP_SALE_CREATED':
          return const OfframpSaleCreated();
        case 'PURCHASE_CREATED':
          return const PurchaseCreated();
        case 'SEND_CRYPTO':
          final version = json['eventVersion'];
          if (version != null && version != 1) {
            return null;
          }
          if (payload == null) {
            return null;
          }
          return SendCryptoRequested(SendCryptoPayload.fromJson(payload));
        case 'WIDGET_CLOSE':
        case 'CLOSE':
          return const RampClosed();
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }
}
