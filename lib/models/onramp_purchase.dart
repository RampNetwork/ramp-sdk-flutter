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

  static OnrampPurchase fromJson(Map<String, dynamic> json) {
    OnrampPurchase purchase = OnrampPurchase();
    purchase.id = json["id"];
    purchase.endTime = json["endTime"];
    purchase.asset = PurchaseAssetInfo.fromJson(json["asset"]);
    purchase.receiverAddress = json["receiverAddress"];
    purchase.cryptoAmount = json["cryptoAmount"];
    purchase.fiatCurrency = json["fiatCurrency"];
    purchase.fiatValue = json["fiatValue"].toDouble();
    purchase.assetExchangeRate = json["assetExchangeRate"];
    purchase.baseRampFee = json["baseRampFee"];
    purchase.networkFee = json["networkFee"];
    purchase.appliedFee = json["appliedFee"];
    purchase.paymentMethodType = json["paymentMethodType"];
    purchase.finalTxHash = json["finalTxHash"];
    purchase.createdAt = json["createdAt"];
    purchase.updatedAt = json["updatedAt"];
    purchase.status = json["status"];
    purchase.escrowAddress = json["escrowAddress"];
    purchase.escrowDetailsHash = json["escrowDetailsHash"];
    return purchase;
  }
}

class PurchaseAssetInfo {
  String? address;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static PurchaseAssetInfo fromJson(Map<String, dynamic> json) {
    PurchaseAssetInfo assetInfo = PurchaseAssetInfo();
    assetInfo.address = json["address"];
    assetInfo.decimals = json["decimals"];
    assetInfo.name = json["name"];
    assetInfo.symbol = json["symbol"];
    assetInfo.type = json["type"];
    return assetInfo;
  }
}
