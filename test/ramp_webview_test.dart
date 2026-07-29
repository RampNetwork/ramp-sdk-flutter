import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/internal/ramp_webview_controller.dart';

void main() {
  group('Configuration.buildWidgetUrl', () {
    test('uses default base URL and SDK metadata', () {
      final url = Configuration().buildWidgetUrl();

      expect(url.scheme, 'https');
      expect(url.host, 'app.rampnetwork.com');
      expect(url.queryParameters['sdkType'], 'FLUTTER');
      expect(url.queryParameters['sdkVersion'], '5.0.0');
      expect(url.queryParameters['variant'], 'sdk-mobile');
    });

    test('merges configuration fields and joins enabled flows', () {
      final url = (Configuration()
            ..url = 'https://app.dev.ramp-network.org/custom'
            ..hostApiKey = 'key'
            ..hostAppName = 'App'
            ..offrampAsset = 'ETH'
            ..offrampWebhookV3Url = 'https://example.com/hook'
            ..enabledFlows = ['ONRAMP', 'OFFRAMP']
            ..defaultFlow = 'OFFRAMP'
            ..useSendCryptoCallback = true
            ..variant = 'ignored')
          .buildWidgetUrl();

      expect(url.host, 'app.dev.ramp-network.org');
      expect(url.path, '/custom');
      expect(url.queryParameters['hostApiKey'], 'key');
      expect(url.queryParameters['hostAppName'], 'App');
      expect(url.queryParameters['offrampAsset'], 'ETH');
      expect(url.queryParameters['offrampWebhookV3Url'],
          'https://example.com/hook');
      expect(url.queryParameters['enabledFlows'], 'ONRAMP,OFFRAMP');
      expect(url.queryParameters['defaultFlow'], 'OFFRAMP');
      expect(url.queryParameters['useSendCryptoCallbackVersion'], '1');
      expect(url.queryParameters['variant'], 'sdk-mobile');
    });

    test('omits null and empty optional fields', () {
      final url = (Configuration()..hostApiKey = ''..fiatValue = null)
          .buildWidgetUrl();

      expect(url.queryParameters.containsKey('hostApiKey'), isFalse);
      expect(url.queryParameters.containsKey('fiatValue'), isFalse);
      expect(
        url.queryParameters.containsKey('useSendCryptoCallbackVersion'),
        isFalse,
      );
    });
  });

  group('RampWebViewController events', () {
    final widgetUrl = Uri.parse('https://app.rampnetwork.com/');

    test('forwards every widget event on onWidgetEvent', () {
      final events = <Map<String, dynamic>>[];
      final controller = RampWebViewController(widgetUrl)
        ..onWidgetEvent = events.add;

      controller.handleJavaScriptMessage('not json');
      controller.handleJavaScriptMessage('42');
      controller.handleJavaScriptMessage(jsonEncode({
        'type': 'WIDGET_CONFIG_DONE',
        'payload': {'ok': true},
      }));
      controller.handleJavaScriptMessage(jsonEncode({
        'type': 'PURCHASE_CREATED',
        'payload': {'purchase': {'id': 'purchase-id'}},
      }));
      controller.handleJavaScriptMessage(jsonEncode({'type': 'CLOSE'}));

      expect(events, [
        {'type': 'RAW', 'payload': 'not json'},
        {'type': 'RAW', 'payload': 42},
        {
          'type': 'WIDGET_CONFIG_DONE',
          'payload': {'ok': true},
        },
        {
          'type': 'PURCHASE_CREATED',
          'payload': {
            'purchase': {'id': 'purchase-id'},
          },
        },
        {'type': 'CLOSE'},
      ]);
    });
  });
}
