part of '../widget_event.dart';

final class OfframpSaleCreated extends WidgetEvent {
  const OfframpSaleCreated(this.payload, {super.widgetInstanceId});

  final OfframpSaleCreatedPayload payload;
}

class OfframpSaleCreatedPayload {
  const OfframpSaleCreatedPayload({this.sale, this.saleViewToken, this.apiUrl});

  final SaleDetails? sale;
  final String? saleViewToken;
  final String? apiUrl;

  factory OfframpSaleCreatedPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const OfframpSaleCreatedPayload();
    }
    return OfframpSaleCreatedPayload(
      sale: SaleDetails.fromJson(asStringKeyedMap(json['sale'])),
      saleViewToken: json['saleViewToken'] as String?,
      apiUrl: json['apiUrl'] as String?,
    );
  }
}
