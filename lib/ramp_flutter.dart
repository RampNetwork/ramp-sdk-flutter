import 'package:flutter/material.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/internal/ramp_webview_controller.dart';
import 'package:ramp_flutter/internal/ramp_webview_page.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

/// Flutter API for presenting the Ramp Network widget.
class RampFlutter {
  RampWebViewController? _activeController;

  Function(OnrampPurchase, String, String)? onOnrampPurchaseCreated;
  Function(SendCryptoPayload payload)? onSendCryptoRequested;
  Function(OfframpSale, String, String)? onOfframpSaleCreated;
  Function()? onRampClosed;

  /// Builds the widget URL from [configuration] and presents it in a
  /// [showModalBottomSheet].
  ///
  /// Requires a [MaterialApp] (or other ancestor that provides
  /// [MaterialLocalizations]) above [context].
  Future<void> showRamp(
    BuildContext context,
    Configuration configuration,
  ) async {
    final widgetUrl = configuration.buildWidgetUrl();
    final controller = RampWebViewController(widgetUrl)
      ..onOnrampPurchaseCreated = onOnrampPurchaseCreated
      ..onOfframpSaleCreated = onOfframpSaleCreated
      ..onSendCryptoRequested = onSendCryptoRequested;

    _activeController = controller;

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
        controller.onClosed = () {
          if (Navigator.of(sheetContext).canPop()) {
            Navigator.of(sheetContext).pop();
          }
        };

        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.92,
          child: Column(
            children: [
              const SizedBox(
                height: 28,
                child: Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                    child: SizedBox(width: 36, height: 4),
                  ),
                ),
              ),
              Expanded(child: RampWebViewPage(controller: controller)),
            ],
          ),
        );
      },
    );

    controller.dispose();
    if (identical(_activeController, controller)) {
      _activeController = null;
    }
    onRampClosed?.call();
  }

  /// Completes an off-ramp send-crypto request with an optional [transactionHash].
  Future<void> sendCrypto(String? transactionHash) async {
    await _activeController?.sendCrypto(transactionHash);
  }
}
