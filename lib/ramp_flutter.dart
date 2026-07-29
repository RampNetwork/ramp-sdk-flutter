import 'package:flutter/widgets.dart';
import 'package:ramp_flutter/src/configuration.dart';
import 'package:ramp_flutter/src/host_event.dart';
import 'package:ramp_flutter/src/ramp_webview.dart';
import 'package:ramp_flutter/src/signed_url.dart';
import 'package:ramp_flutter/src/widget_event.dart';

export 'package:ramp_flutter/src/configuration.dart';
export 'package:ramp_flutter/src/host_event.dart';
export 'package:ramp_flutter/src/widget_event.dart';

class RampFlutter {
  RampFlutter(Configuration configuration) : this._(configuration.buildWidgetUrl());

  factory RampFlutter.signed(String url) => RampFlutter._(validateRampSignedUrl(url));

  @visibleForTesting
  factory RampFlutter.uri(Uri widgetUrl) => RampFlutter._(widgetUrl);

  RampFlutter._(Uri widgetUrl) : _webView = RampWebView(widgetUrl);

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
