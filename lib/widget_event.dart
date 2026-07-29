import 'package:ramp_flutter/models/asset_info.dart';
import 'package:ramp_flutter/models/json_map.dart';
import 'package:ramp_flutter/models/purchase_details.dart';
import 'package:ramp_flutter/models/sale_details.dart';

export 'package:ramp_flutter/models/asset_info.dart';
export 'package:ramp_flutter/models/purchase_details.dart';
export 'package:ramp_flutter/models/sale_details.dart';

part 'events/offramp_sale_created.dart';
part 'events/purchase_created.dart';
part 'events/request_crypto_account.dart';
part 'events/send_crypto_requested.dart';
part 'events/widget_close.dart';
part 'events/widget_config_done.dart';
part 'events/widget_config_failed.dart';

sealed class WidgetEvent {
  const WidgetEvent({this.widgetInstanceId});

  final String? widgetInstanceId;

  static WidgetEvent? tryParse(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is! String) {
      return null;
    }
    final payload = asStringKeyedMap(json['payload']);
    final widgetInstanceId = json['widgetInstanceId'] as String?;

    try {
      switch (type) {
        case 'WIDGET_CONFIG_DONE':
          return WidgetConfigDone(widgetInstanceId: widgetInstanceId);
        case 'WIDGET_CONFIG_FAILED':
          return WidgetConfigFailed(widgetInstanceId: widgetInstanceId);
        case 'PURCHASE_CREATED':
          return PurchaseCreated(
            PurchaseCreatedPayload.fromJson(payload),
            widgetInstanceId: widgetInstanceId,
          );
        case 'OFFRAMP_SALE_CREATED':
          return OfframpSaleCreated(
            OfframpSaleCreatedPayload.fromJson(payload),
            widgetInstanceId: widgetInstanceId,
          );
        case 'SEND_CRYPTO':
          final version = json['eventVersion'];
          if (version != null && version != 1) {
            return null;
          }
          if (payload == null) {
            return null;
          }
          return SendCryptoRequested(
            SendCryptoPayload.fromJson(payload),
            widgetInstanceId: widgetInstanceId,
          );
        case 'REQUEST_CRYPTO_ACCOUNT':
          if (payload == null) {
            return null;
          }
          return RequestCryptoAccount(
            RequestCryptoAccountPayload.fromJson(payload),
            widgetInstanceId: widgetInstanceId,
          );
        case 'WIDGET_CLOSE':
        case 'CLOSE':
          return WidgetClose(
            payload: WidgetClosePayload.fromJson(payload),
            widgetInstanceId: widgetInstanceId,
          );
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }
}
