import 'package:flutter/material.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/internal/ramp_webview_controller.dart';
import 'package:ramp_flutter/internal/ramp_webview_page.dart';

/// Flutter API for presenting the Ramp Network widget.
class RampFlutter {
  RampWebViewController? _activeController;

  /// Fires for every widget JS event.
  Function(Map<String, dynamic> event)? onWidgetEvent;

  /// Builds the widget URL from [configuration] and presents it in a
  /// [showModalBottomSheet].
  ///
  /// Requires a [MaterialApp] (or other ancestor that provides
  /// [MaterialLocalizations]) above [context].
  ///
  /// `CLOSE` / `WIDGET_CLOSE` events dismiss the sheet automatically.
  Future<void> showRamp(
    BuildContext context,
    Configuration configuration,
  ) async {
    final widgetUrl = configuration.buildWidgetUrl();
    late final RampWebViewController controller;

    controller = RampWebViewController(widgetUrl)
      ..onWidgetEvent = (event) {
        onWidgetEvent?.call(event);
        final type = event['type'];
        if (type == 'CLOSE' || type == 'WIDGET_CLOSE') {
          final navigator = Navigator.of(context, rootNavigator: true);
          if (navigator.canPop()) {
            navigator.pop();
          }
        }
      };

    _activeController = controller;

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
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
  }

  /// Completes an off-ramp send-crypto request with an optional [transactionHash].
  Future<void> sendCrypto(String? transactionHash) async {
    await _activeController?.sendCrypto(transactionHash);
  }
}
