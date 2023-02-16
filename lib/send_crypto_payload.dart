class SendCryptoPayload {
  String? address;
  String? amount;
  SendCryptoAssetInfo? assetInfo;

  static SendCryptoPayload fromArguments(Map<String, dynamic> arguments) {
    SendCryptoPayload payload = SendCryptoPayload();
    payload.address = arguments["address"];
    payload.amount = arguments["amount"];
    payload.assetInfo =
        SendCryptoAssetInfo.fromArguments(arguments["assetInfo"]);
    return payload;
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'amount': amount,
      'assetInfo': assetInfo,
    };
  }
}

class SendCryptoAssetInfo {
  String? chain;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static SendCryptoAssetInfo fromArguments(Map<String, dynamic> arguments) {
    SendCryptoAssetInfo payload = SendCryptoAssetInfo();
    payload.chain = arguments["chain"];
    payload.decimals = arguments["decimals"];
    payload.name = arguments["name"];
    payload.symbol = arguments["symbol"];
    payload.type = arguments["type"];
    return payload;
  }

  Map<String, dynamic> toMap() {
    return {
      'chain': chain,
      'decimals': decimals,
      'name': name,
      'symbol': symbol,
      'type': type,
    };
  }
}
