# Changelog

## 5.0.0

* Rewrite the SDK to load the Ramp widget in a Flutter WebView instead of the
  native iOS/Android Ramp SDKs. Published as a Dart Flutter package (no
  Android/iOS plugin shells).
* Breaking: SDK no longer presents UI. Create `RampFlutter(configuration)`,
  embed `ramp.view` in your own route/sheet, and call `dispose` when done.
* Widget → host: sealed `WidgetEvent` via `onWidgetEvent` (includes
  `WidgetCloseRequest`). Host → widget: sealed `HostEvent`
  (`SendCryptoResult`, `RequestCryptoAccountResult`) via `postHostEvent`.
* Add `Configuration.offrampAsset` and build the widget URL in Dart
  (`Configuration.buildWidgetUrl`), including `sdkType` / `sdkVersion` /
  `variant`.
* Default base URL is now `https://app.rampnetwork.com`.
* Raise minimum platforms to Android 7.0 (API 24) and iOS 13.
* Raise minimum Flutter to 3.44 / Dart 3.12; update `webview_flutter`,
  `url_launcher`, and `flutter_lints`.
* Open `target=_blank` / `window.open` in the system browser via a forked
  `webview_flutter` platform package (`flutter_packages` /
  `webview-target-blank`).

## 4.0.1

* Updated package documentation

## 4.0.0

* Upgraded Android SDK dependency version to 4.0.+

## 3.0.0

* Regenerated plugin to fix platform specific dependencies
