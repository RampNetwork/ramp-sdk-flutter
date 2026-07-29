# Ramp Network Flutter

Official Flutter package for Ramp Network. Loads the Ramp widget in a Flutter
WebView on iOS and Android (no native Ramp SDK or Flutter plugin shells).

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
- Native Ramp iOS/Android SDKs and empty Flutter plugin shells are **not**
  required (no CocoaPods `Ramp` pod, no JitPack `ramp-sdk-android`).
  Platform WebView support comes from `webview_flutter` / `url_launcher`.
- Requires Flutter 3.44+ / Dart 3.12+.

### Usage

The SDK provides the Ramp WebView; your app owns presentation (route, bottom
sheet, dialog, etc.) and must call `dispose` when it is dismissed.

**Configuration** (SDK builds the widget URL, including `sdkType` / `sdkVersion`):

```dart
import 'package:ramp_flutter/ramp_flutter.dart';

final ramp = RampFlutter(
  Configuration(
    hostApiKey: 'YOUR_API_KEY',
    hostAppName: 'My App',
    enabledFlows: [TransactionFlow.ONRAMP, TransactionFlow.OFFRAMP],
    outAsset: 'BTC_BTC',
  ),
)
  ..onWidgetEvent = (event) {
    switch (event) {
      case PurchaseCreated(:final payload):
        // payload.purchase, purchaseViewToken, apiUrl
        break;
      case OfframpSaleCreated(:final payload):
        break;
      case SendCryptoRequested(:final payload):
        ramp.postHostEvent(SendCryptoResult.txHash(txHash));
      case RequestCryptoAccount(:final payload):
        ramp.postHostEvent(
          RequestCryptoAccountResult.account(address: userAddress, type: payload.type),
        );
      case WidgetClose():
        Navigator.of(context).pop();
      case WidgetCloseRequest():
        // User tried to dismiss while widget is not closeable — confirm or ignore.
        break;
      case WidgetConfigDone():
      case WidgetConfigFailed():
        break;
    }
  };

await showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  builder: (_) => SizedBox(
    height: MediaQuery.sizeOf(context).height * 0.92,
    child: ramp.view,
  ),
);

ramp.dispose();
```

**Server-signed URL** (loaded verbatim — do not put this in `Configuration.url`):

```dart
final ramp = RampFlutter.signed(signedWidgetUrlFromYourBackend)
  ..onWidgetEvent = (event) { /* same switch as above */ };
```

Generate the signed URL on your backend (`hostApiKey`, `timestamp`, `signature`).
Keep signing keys out of the app.

For more configuration parameters see
[Ramp Network Flutter documentation](https://docs.ramp.network/mobile/flutter-sdk/).

### Notes

- Off-widget navigations (other https hosts, custom schemes, `intent:`) and
  `target=_blank` / `window.open` open in the system browser via
  `NavigationDelegate` and a forked `webview_flutter`
  ([mateusz-ramp/flutter_packages](https://github.com/mateusz-ramp/flutter_packages/tree/webview-target-blank)
  / commit `a37d157`), declared as a direct dependency of this package so hosts
  pick it up transitively (no host `dependency_overrides` required unless
  another package pins pub.dev `webview_flutter`).
- Android WebView `<input type="file">` uses `file_picker` (and the camera via
  `image_picker` when capture is requested). Host apps need camera / photo
  library usage descriptions (see Getting Started). iOS WKWebView handles file
  inputs natively.
