import 'package:ramp/model/offramp_sale.dart';
import 'package:ramp/model/onramp_purchase.dart';
import 'package:ramp/model/send_crypto_payload.dart';

class EventDelegate {
  final Function(
    OnrampPurchase purchase,
    String purchaseViewToken,
    Uri apiUrl,
  )? onOnrampPurchaseCreated;

  final Function(SendCryptoPayload payload)? onSendCryptoRequested;

  final Function(
    OfframpSale sale,
    String saleViewToken,
    Uri apiUrl,
  )? onOfframpSaleCreated;

  final Function()? onRampClosed;

  const EventDelegate({
    this.onOnrampPurchaseCreated,
    this.onSendCryptoRequested,
    this.onOfframpSaleCreated,
    this.onRampClosed,
  });
}
