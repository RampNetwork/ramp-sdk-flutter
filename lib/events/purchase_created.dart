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

class PurchaseDetails {
  const PurchaseDetails({
    this.id,
    this.endTime,
    this.asset,
    this.receiverAddress,
    this.cryptoAmount,
    this.fiatCurrency,
    this.fiatValue,
    this.assetExchangeRate,
    this.assetExchangeRateEur,
    this.fiatExchangeRateEur,
    this.baseRampFee,
    this.networkFee,
    this.appliedFee,
    this.paymentMethodType,
    this.finalTxHash,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.purchaseViewToken,
    this.hostFeeCut,
  });

  final String? id;
  final String? endTime;
  final AssetInfo? asset;
  final String? receiverAddress;
  final String? cryptoAmount;
  final String? fiatCurrency;
  final double? fiatValue;
  final double? assetExchangeRate;
  final double? assetExchangeRateEur;
  final double? fiatExchangeRateEur;
  final double? baseRampFee;
  final double? networkFee;
  final double? appliedFee;
  final String? paymentMethodType;
  final String? finalTxHash;
  final String? createdAt;
  final String? updatedAt;
  final String? status;
  final String? purchaseViewToken;
  final double? hostFeeCut;

  factory PurchaseDetails.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PurchaseDetails();
    }
    return PurchaseDetails(
      id: json['id'] as String?,
      endTime: json['endTime'] as String?,
      asset: AssetInfo.fromJson(asStringKeyedMap(json['asset'])),
      receiverAddress: json['receiverAddress'] as String?,
      cryptoAmount: asString(json['cryptoAmount']),
      fiatCurrency: json['fiatCurrency'] as String?,
      fiatValue: asDouble(json['fiatValue']),
      assetExchangeRate: asDouble(json['assetExchangeRate']),
      assetExchangeRateEur: asDouble(json['assetExchangeRateEur']),
      fiatExchangeRateEur: asDouble(json['fiatExchangeRateEur']),
      baseRampFee: asDouble(json['baseRampFee']),
      networkFee: asDouble(json['networkFee']),
      appliedFee: asDouble(json['appliedFee']),
      paymentMethodType: json['paymentMethodType'] as String?,
      finalTxHash: json['finalTxHash'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      status: json['status'] as String?,
      purchaseViewToken: json['purchaseViewToken'] as String?,
      hostFeeCut: asDouble(json['hostFeeCut']),
    );
  }
}
