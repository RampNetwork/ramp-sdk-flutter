class OnrampPurchase {
  String? id;
  String? endTime;
  PurchaseAssetInfo? asset;
  String? receiverAddress;
  String? cryptoAmount;
  String? fiatCurrency;
  double? fiatValue;
  double? assetExchangeRate;
  double? baseRampFee;
  double? networkFee;
  double? appliedFee;
  String? paymentMethodType;
  String? finalTxHash;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? escrowAddress;
  String? escrowDetailsHash;

  static OnrampPurchase fromMap(Map<String, dynamic> map) {
    OnrampPurchase purchase = OnrampPurchase();
    purchase.id = map["id"];
    purchase.endTime = map["endTime"];
    purchase.asset = PurchaseAssetInfo.fromMap(map["asset"]);
    purchase.receiverAddress = map["receiverAddress"];
    purchase.cryptoAmount = map["cryptoAmount"];
    purchase.fiatCurrency = map["fiatCurrency"];
    purchase.fiatValue = map["fiatValue"].toDouble();
    purchase.assetExchangeRate = map["assetExchangeRate"];
    purchase.baseRampFee = map["baseRampFee"];
    purchase.networkFee = map["networkFee"];
    purchase.appliedFee = map["appliedFee"];
    purchase.paymentMethodType = map["paymentMethodType"];
    purchase.finalTxHash = map["finalTxHash"];
    purchase.createdAt = map["createdAt"];
    purchase.updatedAt = map["updatedAt"];
    purchase.status = map["status"];
    purchase.escrowAddress = map["escrowAddress"];
    purchase.escrowDetailsHash = map["escrowDetailsHash"];
    return purchase;
  }
}

class PurchaseAssetInfo {
  String? address;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static PurchaseAssetInfo fromMap(Map<String, dynamic> map) {
    PurchaseAssetInfo assetInfo = PurchaseAssetInfo();
    assetInfo.address = map["address"];
    assetInfo.decimals = map["decimals"];
    assetInfo.name = map["name"];
    assetInfo.symbol = map["symbol"];
    assetInfo.type = map["type"];
    return assetInfo;
  }
}
