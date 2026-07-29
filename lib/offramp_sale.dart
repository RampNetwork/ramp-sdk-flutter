class OfframpSale {
  String? createdAt;
  OfframpCrypto? crypto;
  OfframpFiat? fiat;
  String? id;

  static OfframpSale fromArguments(dynamic arguments) {
    OfframpSale sale = OfframpSale();
    sale.createdAt = arguments["createdAt"];
    sale.crypto = OfframpCrypto.fromArguments(arguments['crypto']);
    sale.fiat = OfframpFiat.fromArguments(arguments['fiat']);
    sale.id = arguments["id"];
    return sale;
  }
}

class OfframpCrypto {
  String? amount;
  OfframpAssetInfo? assetInfo;

  static OfframpCrypto fromArguments(dynamic arguments) {
    OfframpCrypto crypto = OfframpCrypto();
    if (arguments == null) return crypto;
    crypto.amount = arguments["amount"];
    crypto.assetInfo = OfframpAssetInfo.fromArguments(arguments["assetInfo"]);
    return crypto;
  }
}

class OfframpAssetInfo {
  String? chain;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static OfframpAssetInfo fromArguments(dynamic arguments) {
    OfframpAssetInfo assetInfo = OfframpAssetInfo();
    if (arguments == null) return assetInfo;
    assetInfo.chain = arguments["chain"];
    assetInfo.decimals = arguments["decimals"];
    assetInfo.name = arguments["name"];
    assetInfo.symbol = arguments["symbol"];
    assetInfo.type = arguments["type"];
    return assetInfo;
  }
}

class OfframpFiat {
  double? amount;
  String? currencySymbol;

  static OfframpFiat fromArguments(dynamic arguments) {
    OfframpFiat fiat = OfframpFiat();
    if (arguments == null) return fiat;
    fiat.amount = (arguments["amount"] as num?)?.toDouble();
    fiat.currencySymbol = arguments["currencySymbol"];
    return fiat;
  }
}
