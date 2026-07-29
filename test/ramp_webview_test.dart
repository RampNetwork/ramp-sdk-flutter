import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/widget_event.dart';

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
      final url =
          (Configuration()
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
      expect(url.queryParameters['enabledFlows'], 'ONRAMP,OFFRAMP');
      expect(url.queryParameters['useSendCryptoCallbackVersion'], '1');
      expect(url.queryParameters['variant'], 'sdk-mobile');
    });

    test('omits null and empty optional fields', () {
      final url =
          (Configuration()
                ..hostApiKey = ''
                ..fiatValue = null)
              .buildWidgetUrl();

      expect(url.queryParameters.containsKey('hostApiKey'), isFalse);
      expect(url.queryParameters.containsKey('fiatValue'), isFalse);
    });
  });

  group('RampFlutter event parsing', () {
    final widgetUrl = Uri.parse('https://app.rampnetwork.com/');

    test('ignores non-JSON and unknown types', () {
      final events = <WidgetEvent>[];
      final ramp = RampFlutter.withWidgetUrl(widgetUrl)..onWidgetEvent = events.add;

      ramp.handleJavaScriptMessage('not json');
      ramp.handleJavaScriptMessage('42');
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'SHARE_LINK'}));
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'WIDGET_CONFIG_DONE'}));

      expect(events, isEmpty);
    });

    test('parses original SDK events', () {
      final events = <WidgetEvent>[];
      final ramp = RampFlutter.withWidgetUrl(widgetUrl)..onWidgetEvent = events.add;

      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'PURCHASE_CREATED',
          'payload': {
            'purchase': {'id': 'ignored'},
          },
        }),
      );
      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'OFFRAMP_SALE_CREATED',
          'payload': {
            'sale': {'id': 'ignored'},
          },
        }),
      );
      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'SEND_CRYPTO',
          'eventVersion': 1,
          'payload': {
            'address': '0xabc',
            'amount': '1',
            'assetInfo': {'chain': 'ETH', 'symbol': 'ETH', 'type': 'ETH'},
          },
        }),
      );
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'CLOSE'}));
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'WIDGET_CLOSE'}));

      expect(events, [
        isA<PurchaseCreated>(),
        isA<OfframpSaleCreated>(),
        isA<SendCryptoRequested>(),
        isA<RampClosed>(),
        isA<RampClosed>(),
      ]);
      final send = events[2] as SendCryptoRequested;
      expect(send.payload.address, '0xabc');
      expect(send.payload.assetInfo?.symbol, 'ETH');
    });

    test('rejects unsupported SEND_CRYPTO eventVersion', () {
      final events = <WidgetEvent>[];
      final ramp = RampFlutter.withWidgetUrl(widgetUrl)..onWidgetEvent = events.add;

      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'SEND_CRYPTO',
          'eventVersion': 2,
          'payload': {'address': '0xabc', 'amount': '1', 'assetInfo': {}},
        }),
      );

      expect(events, isEmpty);
    });
  });
}
