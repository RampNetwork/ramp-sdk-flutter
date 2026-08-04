# Ramp Network Flutter

Official Flutter package for Ramp Network. \
Loads the Ramp widget in a Flutter
WebView on iOS and Android.

## Getting Started

Add the dependency:

```yaml
dependencies:
  ramp_flutter: ^5.0.0
```

Upgrading from 4.x? See [MIGRATION.md](MIGRATION.md).

### Host setup

- **Android:** `minSdkVersion` 24+. Declare `android.permission.CAMERA` for
  identity verification camera capture.
- **iOS:** deployment target 13+. Add `NSCameraUsageDescription` and photo
  library usage descriptions for identity verification and document upload.
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
    enabledFlows: [TransactionFlow.ONRAMP, TransactionFlow.OFFRAMP],
    outAsset: 'BTC_BTC',
  ),
)
  ..onWidgetEvent = (event) {
    switch (event) {
      case AppVersion():
        break;
      case PurchaseCreated(:final payload):
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

Partner **name** and **logo** are not SDK configuration fields. Ask Ramp
Network to set host features `PARTNER_NAME` / `PARTNER_LOGO_URL` for your
integration (for example via integrations@rampnetwork.com).

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
  `image_picker` for capture). Host apps must declare camera / photo library
  usage (see Getting Started). iOS WKWebView handles file inputs natively.
