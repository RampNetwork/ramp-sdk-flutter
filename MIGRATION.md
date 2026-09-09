# Migrating from 4.x to 5.x

Version 5.0.0 replaces the native iOS/Android Ramp SDKs with a Flutter WebView
that loads the Ramp widget. The package is a Dart Flutter package (no Android
or iOS plugin shells).

## Platform requirements

| | 4.x | 5.x |
| --- | --- | --- |
| Flutter / Dart | Flutter `>=3.3.0` / Dart `>=3.2.3 <4.0.0` | Flutter 3.44+ / Dart 3.12+ |
| Android | `minSdkVersion` 21 | `minSdkVersion` 24+ |
| iOS | deployment target 11.0 | deployment target 13+ |

Declare `android.permission.CAMERA`, `NSCameraUsageDescription`, and photo
library usage descriptions for identity verification and document upload.

## Presentation

**4.x:** the SDK presented its own UI (`showRamp` / similar).

**5.x:** create `RampFlutter(Configuration)` or `RampFlutter.signed(url)`,
embed `ramp.view` in your own route / sheet / dialog, and call `dispose` when
dismissed.

```dart
final ramp = RampFlutter(Configuration(/* ... */))
  ..onWidgetEvent = (event) { /* ... */ };

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

## Events

**4.x:** separate callbacks (`onOnrampPurchaseCreated`, `onSendCryptoRequested`,
`onOfframpSaleCreated`, `onRampClosed`, …).

**5.x:** one `onWidgetEvent` handler with sealed `WidgetEvent` subtypes, and
`postHostEvent` with sealed `HostEvent` subtypes (`SendCryptoResult`,
`RequestCryptoAccountResult`). Host events are queued until the widget page
has finished loading.

```dart
ramp.onWidgetEvent = (event) {
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
```

## Configuration

`Configuration` is an immutable helper used only for the config-built entry
point. It builds widget URLs with widget-2 params and always appends
`sdkType` / `sdkVersion`.

### Param mapping

| 4.x (removed) | 5.x |
| --- | --- |
| `defaultAsset` / `fiatCurrency` / `fiatValue` / `swapAsset` / `offrampAsset` / `swapAmount` | `inAsset` / `outAsset` / `inAssetValue` / `outAssetValue` / `enabledCryptoAssets` |
| `enabledFlows` / `defaultFlow` as strings | `TransactionFlow` enum |
| — | `paymentMethodType` (`PaymentMethodType` enum) |
| `hostLogoUrl`, `hostAppName`, `containerNode`, `deepLinkScheme`, `variant` | removed — partner name and logo are set by Ramp Network on the integration (`PARTNER_NAME` / `PARTNER_LOGO_URL`) |
| `finalUrl` | removed — hosted-mode redirect only; not used by the Flutter WebView SDK |

Default base URL is `https://app.rampnetwork.com`.

Both `Configuration.buildWidgetUrl()` and `RampFlutter.signed` require an
`https` Ramp Network host (`*.ramp.network`, `*.rampnetwork.com`,
`*.ramp-network.org`).

## Signed URLs

Use `RampFlutter.signed(url)` for server-signed widget URLs (loaded verbatim).
Do not put a signed URL in `Configuration.url` — `buildWidgetUrl()` rejects
bases that already include a `signature` query parameter.

## Public API surface

Import only `package:ramp_flutter/ramp_flutter.dart`. Implementation lives under
`lib/src/`.

## Further reading

See [README.md](README.md) for host setup and usage examples, and the
[Flutter SDK docs](https://docs.ramp.network/mobile/flutter-sdk/).
