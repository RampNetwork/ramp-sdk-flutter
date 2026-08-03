import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ramp_flutter/ramp_flutter.dart';

void main() {
  group('Configuration.buildWidgetUrl', () {
    test('uses default base URL and SDK metadata', () {
      final url = const Configuration().buildWidgetUrl();

      expect(url.scheme, 'https');
      expect(url.host, 'app.rampnetwork.com');
      expect(url.queryParameters['sdkType'], 'FLUTTER');
      expect(url.queryParameters['sdkVersion'], '5.0.0');
      expect(url.queryParameters.containsKey('variant'), isFalse);
    });

    test('merges configuration fields and joins list params', () {
      final url = const Configuration(
        url: 'https://app.dev.ramp-network.org/custom',
        hostApiKey: 'key',
        hostAppName: 'App',
        enabledCryptoAssets: ['ETH_*', 'BTC_BTC'],
        inAsset: 'EUR',
        outAsset: 'ETH_ETH',
        inAssetValue: '10000',
        outAssetValue: '500000',
        finalUrl: 'https://example.com/done',
        webhookStatusUrl: 'https://example.com/purchase-hook',
        offrampWebhookV3Url: 'https://example.com/hook',
        selectedCountryCode: 'PL',
        userAddress: '0xabc',
        userEmailAddress: 'user@example.com',
        enabledFlows: [TransactionFlow.ONRAMP, TransactionFlow.OFFRAMP],
        defaultFlow: TransactionFlow.OFFRAMP,
        paymentMethodType: PaymentMethodType.CARD_PAYMENT,
        useSendCryptoCallback: true,
      ).buildWidgetUrl();

      expect(url.host, 'app.dev.ramp-network.org');
      expect(url.path, '/custom');
      expect(url.queryParameters['hostApiKey'], 'key');
      expect(url.queryParameters['hostAppName'], 'App');
      expect(url.queryParameters['enabledFlows'], 'ONRAMP,OFFRAMP');
      expect(url.queryParameters['enabledCryptoAssets'], 'ETH_*,BTC_BTC');
      expect(url.queryParameters['inAsset'], 'EUR');
      expect(url.queryParameters['outAsset'], 'ETH_ETH');
      expect(url.queryParameters['inAssetValue'], '10000');
      expect(url.queryParameters['outAssetValue'], '500000');
      expect(url.queryParameters['finalUrl'], 'https://example.com/done');
      expect(url.queryParameters['webhookStatusUrl'], 'https://example.com/purchase-hook');
      expect(url.queryParameters['offrampWebhookV3Url'], 'https://example.com/hook');
      expect(url.queryParameters['selectedCountryCode'], 'PL');
      expect(url.queryParameters['userAddress'], '0xabc');
      expect(url.queryParameters['userEmailAddress'], 'user@example.com');
      expect(url.queryParameters['defaultFlow'], 'OFFRAMP');
      expect(url.queryParameters['paymentMethodType'], 'CARD_PAYMENT');
      expect(url.queryParameters['useSendCryptoCallbackVersion'], '1');
    });

    test('omits null and empty optional fields', () {
      final url = const Configuration(
        hostApiKey: '',
        inAssetValue: null,
        enabledFlows: [],
        enabledCryptoAssets: [],
        url: '   ',
      ).buildWidgetUrl();

      expect(url.host, 'app.rampnetwork.com');
      expect(url.queryParameters.containsKey('hostApiKey'), isFalse);
      expect(url.queryParameters.containsKey('inAssetValue'), isFalse);
      expect(url.queryParameters.containsKey('enabledFlows'), isFalse);
      expect(url.queryParameters.containsKey('enabledCryptoAssets'), isFalse);
      expect(url.queryParameters.containsKey('useSendCryptoCallbackVersion'), isFalse);
    });

    test('rejects an untrusted base URL', () {
      expect(() => const Configuration(url: 'https://evil.example/').buildWidgetUrl(), throwsArgumentError);
      expect(() => const Configuration(url: 'http://app.rampnetwork.com/').buildWidgetUrl(), throwsArgumentError);
    });
  });

  group('RampFlutter event parsing', () {
    final widgetUrl = Uri.parse('https://app.rampnetwork.com/');

    test('ignores non-JSON and unknown types', () {
      final events = <WidgetEvent>[];
      final ramp = RampFlutter.uri(widgetUrl)..onWidgetEvent = events.add;

      ramp.handleJavaScriptMessage('not json');
      ramp.handleJavaScriptMessage('42');
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'SHARE_LINK'}));

      expect(events, isEmpty);
    });

    test('parses supported widget events', () {
      final events = <WidgetEvent>[];
      final ramp = RampFlutter.uri(widgetUrl)..onWidgetEvent = events.add;

      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'APP_VERSION',
          'payload': {'version': '2.0'},
          'widgetInstanceId': 'w0',
        }),
      );
      ramp.handleJavaScriptMessage(
        jsonEncode({'type': 'WIDGET_CONFIG_DONE', 'payload': null, 'widgetInstanceId': 'w1'}),
      );
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'WIDGET_CONFIG_FAILED', 'payload': null}));
      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'PURCHASE_CREATED',
          'payload': {
            'purchase': {
              'id': 'p1',
              'asset': {'symbol': 'ETH', 'chain': 'ETH', 'type': 'NATIVE', 'name': 'Ether', 'decimals': 18},
              'cryptoAmount': '100',
              'fiatValue': 50.5,
            },
            'purchaseViewToken': 'token',
            'apiUrl': 'https://api.example.com',
          },
        }),
      );
      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'OFFRAMP_SALE_CREATED',
          'payload': {
            'sale': {
              'id': 's1',
              'crypto': {
                'amount': '1',
                'status': 'RECEIVED',
                'assetInfo': {'symbol': 'ETH'},
              },
              'fiat': {'amount': '10', 'currencySymbol': 'EUR', 'status': 'initiated'},
              'fees': {'amount': '1', 'currencySymbol': 978},
              'exchangeRate': '10',
            },
            'saleViewToken': 'sale-token',
            'apiUrl': 'https://api.example.com',
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
            'assetInfo': {
              'uai': 'eip155:1/slip44:60',
              'address': null,
              'chain': 'ETH',
              'symbol': 'ETH',
              'type': 'NATIVE',
              'name': 'Ether',
              'decimals': 18,
            },
          },
        }),
      );
      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'REQUEST_CRYPTO_ACCOUNT',
          'payload': {'type': 'ETH', 'assetSymbol': 'ETH'},
        }),
      );
      ramp.handleJavaScriptMessage(
        jsonEncode({
          'type': 'WIDGET_CLOSE',
          'payload': {'showAlert': true, 'descriptionText': 'Leave?'},
        }),
      );
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'CLOSE'}));
      ramp.handleJavaScriptMessage(jsonEncode({'type': 'WIDGET_CLOSE_REQUEST', 'payload': null}));

      expect(events, [
        isA<AppVersion>(),
        isA<WidgetConfigDone>(),
        isA<WidgetConfigFailed>(),
        isA<PurchaseCreated>(),
        isA<OfframpSaleCreated>(),
        isA<SendCryptoRequested>(),
        isA<RequestCryptoAccount>(),
        isA<WidgetClose>(),
        isA<WidgetClose>(),
        isA<WidgetCloseRequest>(),
      ]);

      final appVersion = events[0] as AppVersion;
      expect(appVersion.widgetInstanceId, 'w0');
      expect(appVersion.payload.version, '2.0');
      expect(events[1].widgetInstanceId, 'w1');

      final purchase = events[3] as PurchaseCreated;
      expect(purchase.payload.purchase?.id, 'p1');
      expect(purchase.payload.purchase?.asset?.symbol, 'ETH');
      expect(purchase.payload.purchase?.fiatValue, 50.5);
      expect(purchase.payload.purchaseViewToken, 'token');

      final sale = events[4] as OfframpSaleCreated;
      expect(sale.payload.sale?.id, 's1');
      expect(sale.payload.sale?.fees?.currencySymbol, '978');
      expect(sale.payload.saleViewToken, 'sale-token');

      final send = events[5] as SendCryptoRequested;
      expect(send.payload.address, '0xabc');
      expect(send.payload.assetInfo?.uai, 'eip155:1/slip44:60');
      expect(send.payload.assetInfo?.symbol, 'ETH');

      final account = events[6] as RequestCryptoAccount;
      expect(account.payload.type, 'ETH');
      expect(account.payload.assetSymbol, 'ETH');

      final close = events[7] as WidgetClose;
      expect(close.payload.showAlert, isTrue);
      expect(close.payload.descriptionText, 'Leave?');
    });

    test('rejects unsupported SEND_CRYPTO eventVersion', () {
      final events = <WidgetEvent>[];
      final ramp = RampFlutter.uri(widgetUrl)..onWidgetEvent = events.add;

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

  group('HostEvent serialization', () {
    test('encodes SendCryptoResult and RequestCryptoAccountResult', () {
      expect(SendCryptoResult.txHash('0xhash').toJson(), {
        'type': 'SEND_CRYPTO_RESULT',
        'payload': {'txHash': '0xhash'},
      });
      expect(SendCryptoResult.error('failed').toJson(), {
        'type': 'SEND_CRYPTO_RESULT',
        'payload': {'error': 'failed'},
      });
      expect(SendCryptoResult.txHash('0xhash').payload, isA<SendCryptoResultTxHashPayload>());
      expect((SendCryptoResult.txHash('0xhash').payload as SendCryptoResultTxHashPayload).txHash, '0xhash');

      expect(RequestCryptoAccountResult.account(address: '0xabc', type: 'ETH').toJson(), {
        'type': 'REQUEST_CRYPTO_ACCOUNT_RESULT',
        'payload': {'address': '0xabc', 'type': 'ETH'},
      });
      expect(RequestCryptoAccountResult.error('denied').toJson(), {
        'type': 'REQUEST_CRYPTO_ACCOUNT_RESULT',
        'payload': {'error': 'denied'},
      });
      final account = RequestCryptoAccountResult.account(address: '0xabc', type: 'ETH');
      expect(account.payload, isA<RequestCryptoAccountSuccessPayload>());
      expect((account.payload as RequestCryptoAccountSuccessPayload).address, '0xabc');
    });
  });
}
