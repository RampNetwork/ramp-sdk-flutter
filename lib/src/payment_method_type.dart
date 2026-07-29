/// Host-facing payment method for widget URL `paymentMethodType`.
///
/// Values match widget-2 `PublicPaymentMethodName` (not internal types like `CARD`).
enum PaymentMethodType {
  MANUAL_BANK_TRANSFER,
  AUTO_BANK_TRANSFER,
  CARD_PAYMENT,
  APPLE_PAY,
  GOOGLE_PAY,
  PIX,
  ACH,
  PAYPAL,
}
