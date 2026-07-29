import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/internal/ramp_webview_controller.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

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

    test('forwards purchase events with numeric coercion', () {
      OnrampPurchase? purchase;
      String? token;
      String? apiUrl;
      final controller = RampWebViewController(widgetUrl)
        ..onOnrampPurchaseCreated = (p, t, url) {
          purchase = p;
          token = t;
          apiUrl = url;
        };

      controller.handleJavaScriptMessage(jsonEncode({
        'type': 'PURCHASE_CREATED',
        'payload': {
          'purchase': {
            'id': 'purchase-id',
            'asset': {'decimals': 18, 'name': 'Ether', 'symbol': 'ETH'},
            'fiatValue': 100.5,
            'assetExchangeRate': 2,
          },
          'purchaseViewToken': 'view-token',
          'apiUrl': 'https://api.ramp.network',
        },
      }));

      expect(purchase?.id, 'purchase-id');
      expect(token, 'view-token');
      expect(apiUrl, 'https://api.ramp.network');
      expect(purchase?.fiatValue, 100.5);
      expect(purchase?.assetExchangeRate, 2.0);
    });

    test('forwards sale events with whole-number fiat amounts', () {
      OfframpSale? sale;
      final controller = RampWebViewController(widgetUrl)
        ..onOfframpSaleCreated = (s, token, url) => sale = s;

      controller.handleJavaScriptMessage(jsonEncode({
        'type': 'OFFRAMP_SALE_CREATED',
        'payload': {
          'sale': {
            'id': 'sale-id',
            'crypto': {
              'amount': '1000000000000000000',
              'assetInfo': {
                'chain': 'ETH',
                'decimals': 18,
                'name': 'Ether',
                'symbol': 'ETH',
              },
            },
            'fiat': {'amount': 100, 'currencySymbol': 'EUR'},
          },
          'saleViewToken': 'view-token',
          'apiUrl': 'https://api.ramp.network',
        },
      }));

      expect(sale?.id, 'sale-id');
      expect(sale?.fiat?.amount, 100.0);
      expect(sale?.crypto?.assetInfo?.chain, 'ETH');
    });

    test('forwards send crypto requests and both close events', () {
      SendCryptoPayload? payload;
      var closedCount = 0;
      final controller = RampWebViewController(widgetUrl)
        ..onSendCryptoRequested = (p) {
          payload = p;
        }
        ..onClosed = () => closedCount++;

      controller.handleJavaScriptMessage('not json');
      controller.handleJavaScriptMessage('42');
      controller.handleJavaScriptMessage(jsonEncode({
        'type': 'SEND_CRYPTO',
        'payload': {
          'address': '0xabc',
          'amount': '1',
          'assetInfo': {'chain': 'ETH'},
        },
      }));
      controller.handleJavaScriptMessage(jsonEncode({'type': 'CLOSE'}));
      controller.handleJavaScriptMessage(jsonEncode({'type': 'WIDGET_CLOSE'}));

      expect(payload?.address, '0xabc');
      expect(payload?.assetInfo?.chain, 'ETH');
      expect(closedCount, 2);
    });
  });
}
