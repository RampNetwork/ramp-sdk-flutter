import 'package:flutter/widgets.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/internal/ramp_webview_controller.dart';
import 'package:ramp_flutter/internal/ramp_webview_page.dart';

/// Flutter API for embedding the Ramp Network widget.
///
/// The SDK provides the widget [view]; the host app owns presentation
/// (route, bottom sheet, dialog, etc.) and must call [dispose] when done.
class RampFlutter {
  RampFlutter(Configuration configuration)
      : _controller =
            RampWebViewController(configuration.buildWidgetUrl()) {
    _controller.onWidgetEvent = (event) => onWidgetEvent?.call(event);
  }

  final RampWebViewController _controller;

  /// Fires for every widget JS event.
  void Function(Map<String, dynamic> event)? onWidgetEvent;

  /// WebView that loads the Ramp widget. Embed this in your own UI.
  Widget get view => RampWebViewPage(controller: _controller);

  /// Completes an off-ramp send-crypto request with an optional [transactionHash].
  Future<void> sendCrypto(String? transactionHash) {
    return _controller.sendCrypto(transactionHash);
  }

  /// Releases the WebView. Call when your presentation is dismissed.
  void dispose() {
    _controller.dispose();
  }
}
