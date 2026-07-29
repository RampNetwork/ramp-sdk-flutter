import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'secrets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _setupNotifications();
  runApp(const RampFlutterApp());
}

final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _setupNotifications() async {
  const InitializationSettings settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await _localNotificationsPlugin.initialize(settings).then((_) {
    debugPrint('Local Notifications setup success');
  }).catchError((Object error) {
    debugPrint('Local Notifications setup error: $error');
  });
}

class RampFlutterApp extends StatefulWidget {
  const RampFlutterApp({Key? key}) : super(key: key);

  @override
  State<RampFlutterApp> createState() => _RampFlutterAppState();
}

class _RampFlutterAppState extends State<RampFlutterApp> {
  final ramp = RampFlutter();
  final Configuration _configuration = Configuration();

  final List<String> _predefinedEnvironments = [
    "https://app.dev.ramp-network.org",
    "https://app.demo.ramp.network",
    "https://app.rampnetwork.com",
  ];

  int _selectedEnvironment = 0;

  @override
  void initState() {
    _configuration.hostAppName = "Ramp Network Flutter";
    _configuration.hostLogoUrl =
        "https://assets.rampnetwork.com/misc/ramp-network-logo.svg";
    _configuration.defaultFlow = "ONRAMP";
    _configuration.enabledFlows = ["ONRAMP", "OFFRAMP", "SWAP"];
    _configuration.defaultAsset = "BTC_BTC";
    _configuration.useSendCryptoCallback = true;
    _configuration.deepLinkScheme = "rampflutterdemo";
    _applyEnvironment(_selectedEnvironment);

    ramp.onOnrampPurchaseCreated = onOnrampPurchaseCreated;
    ramp.onSendCryptoRequested = onSendCryptoRequested;
    ramp.onOfframpSaleCreated = onOfframpSaleCreated;
    ramp.onRampClosed = onRampClosed;

    super.initState();
  }

  void _selectEnvironment(int id) {
    _applyEnvironment(id);
    setState(() => {});
  }

  void _applyEnvironment(int id) {
    _selectedEnvironment = id;
    _configuration.url = _predefinedEnvironments[id];
    // Dev/internal key only; demo/prod need their own keys.
    _configuration.hostApiKey =
        id == 0 ? ExampleSecrets.hostApiKeyInternal : null;
  }

  void onOnrampPurchaseCreated(
    OnrampPurchase purchase,
    String purchaseViewToken,
    String apiUrl,
  ) {
    _showNotification("Ramp Network Notification", "onramp purchase created");
  }

  void onSendCryptoRequested(SendCryptoPayload payload) {
    _showNotification("Ramp Network Notification", "send crypto requested");
    ramp.sendCrypto("123");
  }

  void onOfframpSaleCreated(
    OfframpSale sale,
    String saleViewToken,
    String apiUrl,
  ) {
    _showNotification("Ramp Network Notification", "offramp sale created");
  }

  void onRampClosed() {
    _showNotification("Ramp Network Notification", "ramp closed");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Ramp Network Flutter'),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: ListView(
              children: _formFields(context),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _formFields(BuildContext context) {
    return [..._configurationForm(), _showRampButton(context), _appInfo()];
  }

  Widget _appInfo() {
    return PlatformText("App version: Flutter WebView");
  }

  List<Widget> _configurationForm() {
    return [
      _segmentedControl(
        "Env:",
        ["dev", "demo", "prod"],
        _selectEnvironment,
      ),
      PlatformText(
        _predefinedEnvironments[_selectedEnvironment],
        style: const TextStyle(
          color: Color.fromRGBO(46, 190, 117, 1),
        ),
      ),
      _textField(
        "User email address",
        (text) => _configuration.userEmailAddress = text,
        _configuration.userEmailAddress,
      ),
      _textField(
        "Fiat value",
        (text) => _configuration.fiatValue = text,
        _configuration.fiatValue,
      ),
      _textField(
        "Fiat currency",
        (text) => _configuration.fiatCurrency = text,
        _configuration.fiatCurrency,
      ),
      _textField(
        "Default asset",
        (text) => _configuration.defaultAsset = text,
        _configuration.defaultAsset,
      ),
      _textField(
        "Offramp asset",
        (text) => _configuration.offrampAsset = text,
        _configuration.offrampAsset,
      ),
      _textField(
        "User address",
        (text) => _configuration.userAddress = text,
        _configuration.userAddress,
      ),
      _textField(
        "Host app name",
        (text) => _configuration.hostAppName = text,
        _configuration.hostAppName,
      ),
      _textField(
        "Host API key",
        (text) => _configuration.hostApiKey = text,
        _configuration.hostApiKey,
      ),
      _segmentedControl(
        "Default flow:",
        ["ONRAMP", "OFFRAMP"],
        (index) {
          if (index == 0) {
            _configuration.defaultFlow = "ONRAMP";
          }
          if (index == 1) {
            _configuration.defaultFlow = "OFFRAMP";
          }
        },
      ),
      _enabledFlows(),
    ];
  }

  Widget _enabledFlows() {
    List<String> flows = _configuration.enabledFlows ?? [];
    PlatformSwitch onRamp = PlatformSwitch(
      value: flows.contains("ONRAMP"),
      onChanged: (enabled) {
        if (enabled) {
          flows.add("ONRAMP");
        } else {
          flows.remove("ONRAMP");
        }
        _configuration.enabledFlows = flows;
        setState(() => {});
      },
    );
    PlatformSwitch offRamp = PlatformSwitch(
      value: flows.contains("OFFRAMP"),
      onChanged: (enabled) {
        if (enabled) {
          flows.add("OFFRAMP");
        } else {
          flows.remove("OFFRAMP");
        }
        _configuration.enabledFlows = flows;
        setState(() => {});
      },
    );
    PlatformSwitch swap = PlatformSwitch(
      value: flows.contains("SWAP"),
      onChanged: (enabled) {
        if (enabled) {
          flows.add("SWAP");
        } else {
          flows.remove("SWAP");
        }
        _configuration.enabledFlows = flows;
        setState(() => {});
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PlatformText("Enabled flows:"),
        Row(children: [
          PlatformText("ONRAMP"),
          onRamp,
          PlatformText("OFFRAMP"),
          offRamp,
          PlatformText("SWAP"),
          swap,
        ]),
      ],
    );
  }

  Widget _showRampButton(BuildContext context) {
    return PlatformTextButton(
      onPressed: () => ramp.showRamp(context, _configuration),
      child: PlatformText("Show Ramp"),
    );
  }

  Row _segmentedControl(
      String title, List<String> options, void Function(int) itemSelected) {
    List<Widget> segments = options.asMap().entries.map((entry) {
      return PlatformTextButton(
        onPressed: () => itemSelected(entry.key),
        child: PlatformText(entry.value),
      );
    }).toList();
    List<Widget> children = [PlatformText(title)];
    children.addAll(segments);
    return Row(children: children);
  }

  PlatformTextField _textField(
    String placeholder,
    void Function(String) onChanged,
    String? defaultValue,
  ) {
    return PlatformTextField(
      hintText: placeholder,
      onChanged: onChanged,
      controller: TextEditingController(text: defaultValue),
    );
  }

  Future<void> _showNotification(String title, String message) async {
    const AndroidNotificationDetails android =
        AndroidNotificationDetails("channelId", "channelName");
    const NotificationDetails details = NotificationDetails(android: android);
    await _localNotificationsPlugin.show(
      1,
      title,
      message,
      details,
    );
  }
}
