# Changelog

## 5.0.0

* Rewrite the SDK to load the Ramp widget in a Flutter WebView instead of the
  native iOS/Android Ramp SDKs. Published as a Dart Flutter package (no
  Android/iOS plugin shells).
* Breaking: host owns presentation (`ramp.view`); use sealed `WidgetEvent` /
  `HostEvent` instead of the old callbacks; `Configuration` is immutable and
  uses widget-2 params. See [MIGRATION.md](MIGRATION.md).
* Default base URL is now `https://app.rampnetwork.com`.
* Raise minimums: Flutter 3.44 / Dart 3.12, Android API 24, iOS 13.
* Off-widget / `target=_blank` navigations open in the system browser; Android
  file inputs use `file_picker` / `image_picker`.

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
