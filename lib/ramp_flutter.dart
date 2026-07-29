import 'package:flutter/widgets.dart';
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

  /// Builds the widget URL from [configuration] and pushes a fullscreen route.
  Future<void> showRamp(
    BuildContext context,
    Configuration configuration,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final widgetUrl = configuration.buildWidgetUrl();
    final controller = RampWebViewController(widgetUrl)
      ..onOnrampPurchaseCreated = onOnrampPurchaseCreated
      ..onOfframpSaleCreated = onOfframpSaleCreated
      ..onSendCryptoRequested = onSendCryptoRequested;

    _activeController = controller;

    controller.onClosed = () {
      if (navigator.canPop()) {
        navigator.pop();
      }
    };

    await navigator.push(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return RampWebViewPage(controller: controller);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
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
