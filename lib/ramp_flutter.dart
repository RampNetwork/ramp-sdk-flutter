import 'package:flutter/widgets.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/host_event.dart';
import 'package:ramp_flutter/src/ramp_webview.dart';
import 'package:ramp_flutter/widget_event.dart';

class RampFlutter {
  RampFlutter(Configuration configuration) : _webView = RampWebView(configuration.buildWidgetUrl());

  /// Test-only: load a concrete widget URL without going through [Configuration].
  @visibleForTesting
  RampFlutter.withWidgetUrl(Uri widgetUrl) : _webView = RampWebView(widgetUrl);

  final RampWebView _webView;

  void Function(WidgetEvent event)? get onWidgetEvent => _webView.onWidgetEvent;

  set onWidgetEvent(void Function(WidgetEvent event)? callback) {
    _webView.onWidgetEvent = callback;
  }

  Widget get view => _webView.view;

  Future<void> postHostEvent(HostEvent event) => _webView.postHostEvent(event);

  Future<void> sendCrypto(String? transactionHash) => _webView.sendCrypto(transactionHash);

  void dispose() => _webView.dispose();

  @visibleForTesting
  void handleJavaScriptMessage(String message) => _webView.handleJavaScriptMessage(message);
}
