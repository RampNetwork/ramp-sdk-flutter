# Changelog

## 5.0.0

* Rewrite the SDK to load the Ramp widget in a Flutter WebView instead of the
  native iOS/Android Ramp SDKs. Published as a Dart Flutter package (no
  Android/iOS plugin shells).
* Breaking: SDK no longer presents UI. Create `RampFlutter(Configuration)` or
  `RampFlutter.signed(url)`, embed `ramp.view` in your own route/sheet, and
  call `dispose` when done. `Configuration` is an immutable helper used only
  for the config-built entry point.
* Widget → host: sealed `WidgetEvent` via `onWidgetEvent` (includes
  `WidgetCloseRequest`). Host → widget: sealed `HostEvent`
  (`SendCryptoResult`, `RequestCryptoAccountResult`) via `postHostEvent`.
* `Configuration` builds widget URLs with widget-2 params (`inAsset` /
  `outAsset` / `inAssetValue` / `outAssetValue` / `enabledCryptoAssets` /
  `paymentMethodType`, plus `sdkType` / `sdkVersion`). `defaultFlow` /
  `enabledFlows` use `TransactionFlow`; `paymentMethodType` uses
  `PaymentMethodType`.
  Legacy params (`defaultAsset`, `fiatCurrency`, `fiatValue`, `swapAsset`,
  `offrampAsset`, `swapAmount`, `hostLogoUrl`, `containerNode`,
  `deepLinkScheme`, `variant`) are removed.
* `Configuration.buildWidgetUrl()` and `RampFlutter.signed` both require an
  `https` Ramp Network host (`*.ramp.network`, `*.rampnetwork.com`,
  `*.ramp-network.org`).
* Default base URL is now `https://app.rampnetwork.com`.
* Raise minimum platforms to Android 7.0 (API 24) and iOS 13.
* Raise minimum Flutter to 3.44 / Dart 3.12; update `webview_flutter`,
  `url_launcher`, and `flutter_lints`.
* Open off-widget navigations and `target=_blank` / `window.open` in the system
  browser (same-host stays in the WebView). Depends on a forked
  `webview_flutter` (`flutter_packages` / `webview-target-blank`) as a direct
  git dependency so hosts pick it up transitively.
* Android WebView file inputs use `file_picker`; capture requests use
  `image_picker` (camera).
* Queue `postHostEvent` until the widget page has finished loading.
* Public API is `package:ramp_flutter/ramp_flutter.dart` only (implementation under `lib/src/`).
* Add `RampFlutter.signed` for server-signed widget URLs (loaded verbatim).
  Config URL building rejects bases that already include a `signature` query
  parameter.

## 4.0.1

* Updated package documentation

## 4.0.0

* Upgraded Android SDK dependency version to 4.0.+

## 3.0.0

* Regenerated plugin to fix platform specific dependencies

## 2.0.2

* Update the default URL to the app

## 2.0.1

* Fix missing `onPurchaseFailed` callback

## 2.0.0

* Update native Ramp Network sdk to support off-ramp

## 1.0.2

* Fixed Purchase object decoding for Android
* Updated URL in README

## 1.0.1

* Fix `An operation is not implemented: Not yet implemented` exception

## 1.0.0

* Initial release.
