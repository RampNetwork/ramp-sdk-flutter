import 'dart:core';

class SendCryptoPayload {
  String? assetSymbol;
  String? amount;
  String? address;

  static SendCryptoPayload fromArguments(Map<String, dynamic> arguments) {
    SendCryptoPayload payload = SendCryptoPayload();
    payload.assetSymbol = arguments["assetSymbol"];
    payload.amount = arguments["amount"];
    payload.address = arguments["address"];
    return payload;
  }

  Map<String, dynamic> toMap() {
    return {
      'assetSymbol': assetSymbol,
      'amount': amount,
      'address': address,
    };
  }
}
