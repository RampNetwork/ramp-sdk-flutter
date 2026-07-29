# Ramp Network Flutter

Official Flutter SDK for Ramp Network. Loads the Ramp widget in a Flutter
WebView on iOS and Android.

## Getting Started

Add the dependency:

```yaml
dependencies:
  ramp_flutter: ^5.0.0
```

### Host setup

- **Android:** `minSdkVersion` 24+. Declare `android.permission.CAMERA` if you
  need KYC camera capture.
- **iOS:** deployment target 13+. Add `NSCameraUsageDescription` (and photo
  library usage if you rely on document upload).
- Native Ramp iOS/Android SDKs are **not** required (no CocoaPods `Ramp` pod,
  no JitPack `ramp-sdk-android`).

### Usage

```dart
final ramp = RampFlutter();
ramp.onOnrampPurchaseCreated = (purchase, token, apiUrl) {};
ramp.onOfframpSaleCreated = (sale, token, apiUrl) {};
ramp.onSendCryptoRequested = (payload) {
  // Send crypto, then:
  ramp.sendCrypto(txHash);
};
ramp.onRampClosed = () {};

final configuration = Configuration()
  ..hostApiKey = 'YOUR_API_KEY'
  ..hostAppName = 'My App'
  ..hostLogoUrl = 'https://example.com/logo.png'
  ..enabledFlows = ['ONRAMP', 'OFFRAMP'];

await ramp.showRamp(context, configuration);
```

`showRamp` requires a `BuildContext` with a `Navigator` and presents a
fullscreen WebView route.

For more configuration parameters see
[Ramp Network Flutter documentation](https://docs.ramp.network/mobile/flutter-sdk/).

### Notes

- Android document file upload from the WebView is not wired in this SDK yet.
- Server-signed widget URLs are not supported in this release; use
  `Configuration` fields so the SDK can build the widget URL.
