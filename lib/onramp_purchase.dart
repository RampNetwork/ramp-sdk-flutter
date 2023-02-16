class OnrampPurchase {
  String? id;
  String? endTime;
  PurchaseAssetInfo? asset;
  String? receiverAddress;
  String? cryptoAmount;
  String? fiatCurrency;
  int? fiatValue;
  int? assetExchangeRate;
  int? baseRampFee;
  int? networkFee;
  int? appliedFee;
  String? paymentMethodType;
  String? finalTxHash;
  String? createdAt;
  String? updatedAt;
  String? status;
  String? escrowAddress;
  String? escrowDetailsHash;

  static OnrampPurchase fromArguments(Map<String, dynamic> arguments) {
    OnrampPurchase purchase = OnrampPurchase();
    purchase.id = arguments["id"];
    purchase.endTime = arguments["endTime"];
    purchase.asset = PurchaseAssetInfo.fromArguments(arguments["asset"]);
    purchase.receiverAddress = arguments["receiverAddress"];
    purchase.cryptoAmount = arguments["cryptoAmount"];
    purchase.fiatCurrency = arguments["fiatCurrency"];
    purchase.fiatValue = arguments["fiatValue"];
    purchase.assetExchangeRate = arguments["assetExchangeRate"];
    purchase.baseRampFee = arguments["baseRampFee"];
    purchase.networkFee = arguments["networkFee"];
    purchase.appliedFee = arguments["appliedFee"];
    purchase.paymentMethodType = arguments["paymentMethodType"];
    purchase.finalTxHash = arguments["finalTxHash"];
    purchase.createdAt = arguments["createdAt"];
    purchase.updatedAt = arguments["updatedAt"];
    purchase.status = arguments["status"];
    purchase.escrowAddress = arguments["escrowAddress"];
    purchase.escrowDetailsHash = arguments["escrowDetailsHash"];
    return purchase;
  }
}

class PurchaseAssetInfo {
  String? address;
  String? symbol;
  String? type;
  String? name;
  int? decimals;

  static PurchaseAssetInfo fromArguments(Map<String, dynamic> arguments) {
    PurchaseAssetInfo assetInfo = PurchaseAssetInfo();
    assetInfo.address = arguments["address"];
    assetInfo.symbol = arguments["symbol"];
    assetInfo.type = arguments["type"];
    assetInfo.name = arguments["name"];
    assetInfo.decimals = arguments["decimals"];
    return assetInfo;
  }
}
