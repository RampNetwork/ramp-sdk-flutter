import 'dart:core';

class SendCryptoPayload {
  String? assetSymbol;
  String? amount;
  String? address;

  Map<String, dynamic> toMap() {
    return {
      'assetSymbol': assetSymbol,
      'amount': amount,
      'address': address,
    };
  }
}
