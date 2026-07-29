import 'package:ramp_flutter/src/models/json_map.dart';

class AssetInfo {
  const AssetInfo({
    this.uai,
    this.address,
    this.symbol,
    this.chain,
    this.type,
    this.name,
    this.decimals,
  });

  final String? uai;
  final String? address;
  final String? symbol;
  final String? chain;
  final String? type;
  final String? name;
  final int? decimals;

  factory AssetInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AssetInfo();
    }
    return AssetInfo(
      uai: json['uai'] as String?,
      address: json['address'] as String?,
      symbol: json['symbol'] as String?,
      chain: json['chain'] as String?,
      type: json['type'] as String?,
      name: json['name'] as String?,
      decimals: asInt(json['decimals']),
    );
  }
}
