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

### Usage

The SDK provides the Ramp WebView; your app owns presentation (route, bottom
sheet, dialog, etc.) and must call `dispose` when it is dismissed.

```dart
final ramp = RampFlutter(configuration)
  ..onWidgetEvent = (event) {
    // Every widget JS event, e.g. PURCHASE_CREATED, SEND_CRYPTO, CLOSE, ...
    if (event['type'] == 'SEND_CRYPTO') {
      ramp.sendCrypto(txHash);
    }
    if (event['type'] == 'CLOSE' || event['type'] == 'WIDGET_CLOSE') {
      Navigator.of(context).pop();
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

```dart
final configuration = Configuration()
  ..hostApiKey = 'YOUR_API_KEY'
  ..hostAppName = 'My App'
  ..hostLogoUrl = 'https://example.com/logo.png'
  ..enabledFlows = ['ONRAMP', 'OFFRAMP'];
```

For more configuration parameters see
[Ramp Network Flutter documentation](https://docs.ramp.network/mobile/flutter-sdk/).

### Notes

- Android document file upload from the WebView is not wired in this SDK yet.
- Server-signed widget URLs are not supported in this release; use
  `Configuration` fields so the SDK can build the widget URL.
