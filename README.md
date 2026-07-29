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

```dart
final ramp = RampFlutter(configuration)
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

- `target=_blank` / `window.open` use `NavigationDelegate.onCreateWindow`
  via a fork of `webview_flutter`
  ([mateusz-ramp/flutter_packages](https://github.com/mateusz-ramp/flutter_packages/tree/webview-target-blank)
  branch `webview-target-blank`), matching native `createWebView` /
  `onCreateWindow`. The SDK opens those URLs in the system browser. Host apps
  (and `example/`) must declare matching `dependency_overrides`:

```yaml
dependency_overrides:
  webview_flutter:
    git:
      url: https://github.com/mateusz-ramp/flutter_packages.git
      ref: webview-target-blank
      path: packages/webview_flutter/webview_flutter
  webview_flutter_android:
    git:
      url: https://github.com/mateusz-ramp/flutter_packages.git
      ref: webview-target-blank
      path: packages/webview_flutter/webview_flutter_android
  webview_flutter_wkwebview:
    git:
      url: https://github.com/mateusz-ramp/flutter_packages.git
      ref: webview-target-blank
      path: packages/webview_flutter/webview_flutter_wkwebview
  webview_flutter_platform_interface:
    git:
      url: https://github.com/mateusz-ramp/flutter_packages.git
      ref: webview-target-blank
      path: packages/webview_flutter/webview_flutter_platform_interface
```

- Android WebView `<input type="file">` uses `file_picker` (and the camera via
  `image_picker` when capture is requested). Host apps need camera / photo
  library usage descriptions (see Getting Started). iOS WKWebView handles file
  inputs natively.
- Server-signed widget URLs are not supported in this release; use
  `Configuration` fields so the SDK can build the widget URL.
