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

class SaleDetails {
  const SaleDetails({this.id, this.createdAt, this.updatedAt, this.crypto, this.fiat, this.fees, this.exchangeRate});

  final String? id;
  final String? createdAt;
  final String? updatedAt;
  final SaleCrypto? crypto;
  final SaleFiat? fiat;
  final SaleFees? fees;
  final String? exchangeRate;

  factory SaleDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaleDetails();
    }
    return SaleDetails(
      id: json['id'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      crypto: SaleCrypto.fromJson(asStringKeyedMap(json['crypto'])),
      fiat: SaleFiat.fromJson(asStringKeyedMap(json['fiat'])),
      fees: SaleFees.fromJson(asStringKeyedMap(json['fees'])),
      exchangeRate: asString(json['exchangeRate']),
    );
  }
}

class SaleCrypto {
  const SaleCrypto({this.amount, this.status, this.assetInfo});

  final String? amount;
  final String? status;
  final AssetInfo? assetInfo;

  factory SaleCrypto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaleCrypto();
    }
    return SaleCrypto(
      amount: asString(json['amount']),
      status: json['status'] as String?,
      assetInfo: AssetInfo.fromJson(asStringKeyedMap(json['assetInfo'])),
    );
  }
}

class SaleFiat {
  const SaleFiat({this.amount, this.currencySymbol, this.status, this.payoutMethod});

  final String? amount;
  final String? currencySymbol;
  final String? status;
  final String? payoutMethod;

  factory SaleFiat.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaleFiat();
    }
    return SaleFiat(
      amount: asString(json['amount']),
      currencySymbol: asString(json['currencySymbol']),
      status: json['status'] as String?,
      payoutMethod: json['payoutMethod'] as String?,
    );
  }
}

class SaleFees {
  const SaleFees({this.amount, this.currencySymbol});

  final String? amount;
  final String? currencySymbol;

  factory SaleFees.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const SaleFees();
    }
    return SaleFees(amount: asString(json['amount']), currencySymbol: asString(json['currencySymbol']));
  }
}
