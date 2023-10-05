import 'package:ramp/model/offramp_sale.dart';
import 'package:ramp/model/onramp_purchase.dart';
import 'package:ramp/model/send_crypto_payload.dart';

class EventDelegate {
  Function(
    OnrampPurchase purchase,
    String purchaseViewToken,
    Uri apiUrl,
  )? onOnrampPurchaseCreated;

  Function(SendCryptoPayload payload)? onSendCryptoRequested;

  Function(
    OfframpSale sale,
    String saleViewToken,
    Uri apiUrl,
  )? onOfframpSaleCreated;

  Function()? onRampClosed;

  EventDelegate({
    this.onOnrampPurchaseCreated,
    this.onSendCryptoRequested,
    this.onOfframpSaleCreated,
    this.onRampClosed,
  });
}
