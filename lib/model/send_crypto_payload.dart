class SendCryptoPayload {
  String? address;
  String? amount;
  SendCryptoAssetInfo? assetInfo;

  static SendCryptoPayload fromMap(Map<String, dynamic> map) {
    SendCryptoPayload payload = SendCryptoPayload();
    payload.address = map["address"];
    payload.amount = map["amount"];
    payload.assetInfo = SendCryptoAssetInfo.fromMap(map["assetInfo"]);
    return payload;
  }

  dynamic toMap() {
    return {
      "address": address,
      "amount": amount,
      "assetInfo": assetInfo,
    };
  }
}

class SendCryptoAssetInfo {
  String? chain;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static SendCryptoAssetInfo fromMap(Map<String, dynamic> map) {
    SendCryptoAssetInfo payload = SendCryptoAssetInfo();
    payload.chain = map["chain"];
    payload.decimals = map["decimals"];
    payload.name = map["name"];
    payload.symbol = map["symbol"];
    payload.type = map["type"];
    return payload;
  }

  dynamic toMap() {
    return {
      "chain": chain,
      "decimals": decimals,
      "name": name,
      "symbol": symbol,
      "type": type,
    };
  }
}
