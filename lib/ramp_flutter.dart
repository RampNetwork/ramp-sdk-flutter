import 'package:flutter/widgets.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/host_event.dart';
import 'package:ramp_flutter/src/ramp_webview.dart';
import 'package:ramp_flutter/widget_event.dart';

export 'package:ramp_flutter/configuration.dart';
export 'package:ramp_flutter/host_event.dart';
export 'package:ramp_flutter/widget_event.dart';

class RampFlutter {
  RampFlutter(Uri widgetUrl) : _webView = RampWebView(widgetUrl);

  factory RampFlutter.fromConfiguration(Configuration configuration) =>
      RampFlutter(configuration.buildWidgetUrl());

  final RampWebView _webView;

  void Function(WidgetEvent event)? get onWidgetEvent => _webView.onWidgetEvent;

  set onWidgetEvent(void Function(WidgetEvent event)? callback) {
    _webView.onWidgetEvent = callback;
  }

  Widget get view => _webView.view;

  Future<void> postHostEvent(HostEvent event) => _webView.postHostEvent(event);

  void dispose() => _webView.dispose();

  @visibleForTesting
  void handleJavaScriptMessage(String message) => _webView.handleJavaScriptMessage(message);
}
