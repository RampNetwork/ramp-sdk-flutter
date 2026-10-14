import 'package:flutter/foundation.dart';
import 'package:ramp_flutter/src/configuration.dart';
import 'package:ramp_flutter/src/models/asset_info.dart';
import 'package:ramp_flutter/src/models/json_map.dart';
import 'package:ramp_flutter/src/models/purchase_details.dart';
import 'package:ramp_flutter/src/models/sale_details.dart';

export 'package:ramp_flutter/src/models/asset_info.dart';
export 'package:ramp_flutter/src/models/purchase_details.dart';
export 'package:ramp_flutter/src/models/sale_details.dart';

part 'widget_events/app_version.dart';
part 'widget_events/offramp_sale_created.dart';
part 'widget_events/purchase_created.dart';
part 'widget_events/request_crypto_account.dart';
part 'widget_events/send_crypto_requested.dart';
part 'widget_events/widget_close.dart';
part 'widget_events/widget_close_request.dart';
part 'widget_events/widget_config_done.dart';
part 'widget_events/widget_config_failed.dart';

sealed class WidgetEvent {
  const WidgetEvent({this.widgetInstanceId});

  final String? widgetInstanceId;

  static WidgetEvent? tryParse(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is! String) {
      debugPrint('RampFlutter: drop widget event — missing or non-string type ($type)');
      return null;
    }
    final payload = asStringKeyedMap(json['payload']);
    final widgetInstanceId = json['widgetInstanceId'] as String?;

    try {
      switch (type) {
        case 'APP_VERSION':
          return AppVersion(AppVersionPayload.fromJson(payload), widgetInstanceId: widgetInstanceId);
        case 'WIDGET_CONFIG_DONE':
          return WidgetConfigDone(widgetInstanceId: widgetInstanceId);
        case 'WIDGET_CONFIG_FAILED':
          return WidgetConfigFailed(widgetInstanceId: widgetInstanceId);
        case 'PURCHASE_CREATED':
          return PurchaseCreated(PurchaseCreatedPayload.fromJson(payload), widgetInstanceId: widgetInstanceId);
        case 'OFFRAMP_SALE_CREATED':
          return OfframpSaleCreated(OfframpSaleCreatedPayload.fromJson(payload), widgetInstanceId: widgetInstanceId);
        case 'SEND_CRYPTO':
          final version = json['eventVersion'];
          if (version != null && version != Configuration.sendCryptoProtocolVersion) {
            debugPrint('RampFlutter: drop SEND_CRYPTO — unsupported eventVersion=$version');
            return null;
          }
          if (payload == null) {
            debugPrint('RampFlutter: drop SEND_CRYPTO — missing payload');
            return null;
          }
          return SendCryptoRequested(SendCryptoPayload.fromJson(payload), widgetInstanceId: widgetInstanceId);
        case 'REQUEST_CRYPTO_ACCOUNT':
          if (payload == null) {
            debugPrint('RampFlutter: drop REQUEST_CRYPTO_ACCOUNT — missing payload');
            return null;
          }
          return RequestCryptoAccount(
            RequestCryptoAccountPayload.fromJson(payload),
            widgetInstanceId: widgetInstanceId,
          );
        case 'WIDGET_CLOSE':
        case 'CLOSE':
          return WidgetClose(payload: WidgetClosePayload.fromJson(payload), widgetInstanceId: widgetInstanceId);
        case 'WIDGET_CLOSE_REQUEST':
          return WidgetCloseRequest(widgetInstanceId: widgetInstanceId);
        default:
          debugPrint('RampFlutter: drop widget event — unknown type=$type');
          return null;
      }
    } catch (error, stackTrace) {
      debugPrint('RampFlutter: drop widget event type=$type — parse error: $error\n$stackTrace');
      return null;
    }
  }
}
