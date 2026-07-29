part of '../widget_event.dart';

final class PurchaseCreated extends WidgetEvent {
  const PurchaseCreated(this.payload, {super.widgetInstanceId});

  final PurchaseCreatedPayload payload;
}

class PurchaseCreatedPayload {
  const PurchaseCreatedPayload({this.purchase, this.purchaseViewToken, this.apiUrl});

  final PurchaseDetails? purchase;
  final String? purchaseViewToken;
  final String? apiUrl;

  factory PurchaseCreatedPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PurchaseCreatedPayload();
    }
    return PurchaseCreatedPayload(
      purchase: PurchaseDetails.fromJson(asStringKeyedMap(json['purchase'])),
      purchaseViewToken: json['purchaseViewToken'] as String?,
      apiUrl: json['apiUrl'] as String?,
    );
  }
}
