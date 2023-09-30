class OfframpSale {
  String? createdAt;
  OfframpCrypto? crypto;
  OfframpFiat? fiat;
  String? id;

  static OfframpSale fromMap(Map<String, dynamic> map) {
    OfframpSale sale = OfframpSale();
    sale.createdAt = map["createdAt"];
    sale.crypto = OfframpCrypto.fromMap(map["crypto"]);
    sale.fiat = OfframpFiat.fromMap(map["fiat"]);
    sale.id = map["id"];
    return sale;
  }
}

class OfframpCrypto {
  String? amount;
  OfframpAssetInfo? assetInfo;

  static OfframpCrypto fromMap(Map<String, dynamic> map) {
    OfframpCrypto crypto = OfframpCrypto();
    crypto.amount = map["amount"];
    crypto.assetInfo = OfframpAssetInfo.fromMap(map["assetInfo"]);
    return crypto;
  }
}

class OfframpAssetInfo {
  String? chain;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static OfframpAssetInfo fromMap(Map<String, dynamic> map) {
    OfframpAssetInfo assetInfo = OfframpAssetInfo();
    assetInfo.chain = map["chain"];
    assetInfo.decimals = map["decimals"];
    assetInfo.name = map["name"];
    assetInfo.symbol = map["symbol"];
    assetInfo.type = map["type"];
    return assetInfo;
  }
}

class OfframpFiat {
  double? amount;
  String? currencySymbol;

  static OfframpFiat fromMap(Map<String, dynamic> map) {
    OfframpFiat fiat = OfframpFiat();
    fiat.amount = map["amount"];
    fiat.currencySymbol = map["currencySymbol"];
    return fiat;
  }
}
