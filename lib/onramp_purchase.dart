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

  static OnrampPurchase fromArguments(dynamic arguments) {
    OnrampPurchase purchase = OnrampPurchase();
    purchase.id = arguments["id"];
    purchase.endTime = arguments["endTime"];
    purchase.asset = PurchaseAssetInfo.fromArguments(arguments["asset"]);
    purchase.receiverAddress = arguments["receiverAddress"];
    purchase.cryptoAmount = arguments["cryptoAmount"];
    purchase.fiatCurrency = arguments["fiatCurrency"];
    purchase.fiatValue = _toDouble(arguments["fiatValue"]);
    purchase.assetExchangeRate = _toDouble(arguments["assetExchangeRate"]);
    purchase.baseRampFee = _toDouble(arguments["baseRampFee"]);
    purchase.networkFee = _toDouble(arguments["networkFee"]);
    purchase.appliedFee = _toDouble(arguments["appliedFee"]);
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

double? _toDouble(dynamic value) => (value as num?)?.toDouble();

class PurchaseAssetInfo {
  String? address;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static PurchaseAssetInfo fromArguments(dynamic arguments) {
    PurchaseAssetInfo assetInfo = PurchaseAssetInfo();
    if (arguments == null) return assetInfo;
    assetInfo.address = arguments["address"];
    assetInfo.decimals = arguments["decimals"];
    assetInfo.name = arguments["name"];
    assetInfo.symbol = arguments["symbol"];
    assetInfo.type = arguments["type"];
    return assetInfo;
  }
}
