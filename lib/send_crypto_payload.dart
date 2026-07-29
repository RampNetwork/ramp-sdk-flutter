class SendCryptoPayload {
  String? address;
  String? amount;
  SendCryptoAssetInfo? assetInfo;

  static SendCryptoPayload fromArguments(dynamic arguments) {
    SendCryptoPayload payload = SendCryptoPayload();
    if (arguments == null) return payload;
    payload.address = arguments["address"];
    payload.amount = arguments["amount"];
    payload.assetInfo =
        SendCryptoAssetInfo.fromArguments(arguments["assetInfo"]);
    return payload;
  }
}

class SendCryptoAssetInfo {
  String? chain;
  int? decimals;
  String? name;
  String? symbol;
  String? type;

  static SendCryptoAssetInfo fromArguments(dynamic arguments) {
    SendCryptoAssetInfo payload = SendCryptoAssetInfo();
    if (arguments == null) return payload;
    payload.chain = arguments["chain"];
    payload.decimals = arguments["decimals"];
    payload.name = arguments["name"];
    payload.symbol = arguments["symbol"];
    payload.type = arguments["type"];
    return payload;
  }
}
