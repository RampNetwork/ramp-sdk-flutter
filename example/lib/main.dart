import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
    "https://ri-widget-staging.firebaseapp.com",
    "https://buy.ramp.network",
  ];

  int _selectedEnvironment = 1;
  bool _useFullCustomUrl = false;
  String _fullCustomUrl = "";

  @override
  void initState() {
    // _configuration.fiatValue = "3";
    // _configuration.fiatCurrency = "USD";
    // _configuration.defaultAsset = "ETH";
    // _configuration.userAddress = "0x4b7f8e04b82ad7f9e4b4cc9e1f81c5938e1b719f";
    _configuration.hostAppName = "Ramp Flutter";
    // _configuration.selectedCountryCode = "pl";
    // _configuration.deepLinkScheme = 'rampflutter';
    _configuration.url = _predefinedEnvironments[_selectedEnvironment];

    // _configuration.url = "https://app.dev.ramp-network.org";
    // _configuration.hostApiKey = "3qncr4yvxfpro6endeaeu6npkh8qc23e9uadtazq";
    // _configuration.userEmailAddress = "mateusz.jablonski+pl11@ramp.network";
    _configuration.enabledFlows = ["ONRAMP", "OFFRAMP"];
    _configuration.useSendCryptoCallback = true;

    ramp.onOnrampPurchaseCreated = onOnrampPurchaseCreated;
    ramp.onSendCryptoRequested = onSendCryptoRequested;
    ramp.onOfframpSaleCreated = onOfframpSaleCreated;
    ramp.onRampClosed = onRampClosed;

    super.initState();
  }

  void _selectEnvironment(int id) {
    _selectedEnvironment = id;
    _configuration.url = _predefinedEnvironments[_selectedEnvironment];
    setState(() => {});
  }

  void onOnrampPurchaseCreated(
    OnrampPurchase purchase,
    String purchaseViewToken,
    String apiUrl,
  ) {
    _showNotification("Ramp Notification", "onramp purchase created");
  }

  void onSendCryptoRequested(SendCryptoPayload payload) {
    _showNotification("Ramp Notification", "send crypto requested");
    ramp.sendCrypto("123");
  }

  void onOfframpSaleCreated(
    OfframpSale sale,
    String saleViewToken,
    String apiUrl,
  ) {
    _showNotification("Ramp Notification", "offramp sale created");
  }

  void onRampClosed() {
    _showNotification("Ramp Notification", "ramp closed");
  }

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      home: PlatformScaffold(
        appBar: PlatformAppBar(
          title: const Text('Ramp Flutter'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ListView(
            children: _formFields(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _formFields(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(_useFullCustomUrlToggle());
    if (_useFullCustomUrl) {
      widgets.addAll(_customUrlForm());
    } else {
      widgets.addAll(_configurationForm());
    }
    widgets.add(_showRampButton());
    widgets.add(_appInfo());
    return widgets;
  }

  Widget _appInfo() {
    return PlatformText("App version: Flutter");
  }

  List<Widget> _customUrlForm() {
    return [
      _textField(
        "Full custom URL",
        (text) => _fullCustomUrl = text,
        _fullCustomUrl,
      )
    ];
  }

  List<Widget> _configurationForm() {
    return [
      _segmentedControl(
        "Env:",
        ["dev", "staging", "prod"],
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
    return Row(children: [
      PlatformText("Enabled: "),
      PlatformText("ONRAMP"),
      onRamp,
      PlatformText("OFFRAMP"),
      offRamp,
    ]);
  }

  Widget _showRampButton() {
    return PlatformTextButton(
      onPressed: () {
        if (_useFullCustomUrl) {
          Configuration c = Configuration();
          c.url = _fullCustomUrl;
          ramp.showRamp(c);
        } else {
          ramp.showRamp(_configuration);
        }
      },
      child: PlatformText("Show Ramp"),
    );
  }

  Widget _useFullCustomUrlToggle() {
    return Row(
      children: [
        PlatformText("Use full custom URL"),
        const Spacer(),
        PlatformSwitch(
          value: _useFullCustomUrl,
          onChanged: (value) => setState(() => _useFullCustomUrl = value),
        )
      ],
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
