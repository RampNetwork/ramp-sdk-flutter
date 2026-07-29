# Changelog

## 5.0.0

* Rewrite the SDK to load the Ramp widget in a Flutter WebView instead of the
  native iOS/Android Ramp SDKs. Published as a Dart Flutter package (no
  Android/iOS plugin shells).
* Breaking: `showRamp` now requires a `BuildContext` and pushes a fullscreen
  route (`showRamp(context, configuration)`).
* Add `Configuration.offrampAsset` and build the widget URL in Dart
  (`Configuration.buildWidgetUrl`), including `sdkType` / `sdkVersion` /
  `variant`.
* Default base URL is now `https://app.rampnetwork.com`.
* Raise minimum platforms to Android 7.0 (API 24) and iOS 13.
* Fix numeric event fields crashing on whole-number JSON values;
  `OnrampPurchase.fiatValue` is now `double?`.
* Remove unused `SendCryptoPayload.toMap` and `SendCryptoAssetInfo.toMap`.

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
