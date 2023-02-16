import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/offramp_sale.dart';
import 'package:ramp_flutter/onramp_purchase.dart';
import 'package:ramp_flutter/ramp_flutter.dart';
import 'package:ramp_flutter/send_crypto_payload.dart';

void main() {
  runApp(const RampFlutterApp());
}

class RampFlutterApp extends StatefulWidget {
  const RampFlutterApp({Key? key}) : super(key: key);

  @override
  State<RampFlutterApp> createState() => _RampFlutterAppState();
}

class _RampFlutterAppState extends State<RampFlutterApp> {
  final GlobalKey<NavigatorState> _globalKey = GlobalKey();
  final Configuration _configuration = Configuration();
  final List<String> _predefinedEnvironments = [
    "https://ri-widget-dev2.firebaseapp.com",
    "https://ri-widget-staging.firebaseapp.com",
    "https://buy.ramp.network",
  ];

  int _selectedEnvironment = 1;
  bool _useFullCustomUrl = false;
  String _fullCustomUrl = "";

  @override
  void initState() {
    _configuration.fiatValue = "3";
    _configuration.fiatCurrency = "USD";
    _configuration.defaultAsset = "ETH";
    _configuration.userAddress = "0x4b7f8e04b82ad7f9e4b4cc9e1f81c5938e1b719f";
    _configuration.hostAppName = "Ramp Flutter";
    _configuration.selectedCountryCode = "en";
    // _configuration.deepLinkScheme = 'rampflutter';
    // _configuration.url = _predefinedEnvironments[_selectedEnvironment];

    _configuration.url = "https://ri-widget-dev2.firebaseapp.com/";
    _configuration.hostApiKey = "3qncr4yvxfpro6endeaeu6npkh8qc23e9uadtazq";
    _configuration.userEmailAddress = "mateusz.jablonski+us@ramp.network";
//        _configuration.defaultFlow = .onramp
    _configuration.useSendCryptoCallback = true;

    RampFlutter.setupCallbacks(
      onWidgetConfigDone,
      onOnrampPurchaseCreated,
      onSendCryptoRequested,
      onOfframpSaleCreated,
      onRampClosed,
    );

    super.initState();
  }

  void _selectEnvironment(int id) {
    _selectedEnvironment = id;
    _configuration.url = _predefinedEnvironments[_selectedEnvironment];
    setState(() => {});
  }

  void onWidgetConfigDone() {
    _showAlert("widget config done");
  }

  void onOnrampPurchaseCreated(
      OnrampPurchase purchase, String purchaseViewToken, String apiUrl) {
    _showAlert("purchase created");
  }

  void onSendCryptoRequested(SendCryptoPayload payload) {
    _showAlert("offramp requested");
  }

  void onOfframpSaleCreated(
      OfframpSale sale, String saleViewToken, String apiUrl) {
    _showAlert("offramp sale created");
  }

  void onRampClosed() {
    _showAlert("ramp closed");
  }

  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      navigatorKey: _globalKey,
      home: PlatformScaffold(
        appBar: PlatformAppBar(title: const Text('Ramp Flutter')),
        body: ListView(children: _formFields(context)),
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
        "Environment:",
        ["dev", "staging", "production"],
        _selectEnvironment,
      ),
      PlatformText(
        _predefinedEnvironments[_selectedEnvironment],
        style: const TextStyle(color: Color.fromRGBO(46, 190, 117, 1)),
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
          RampFlutter.showRamp(c);
        } else {
          RampFlutter.showRamp(_configuration);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }

  PlatformTextField _textField(String placeholder,
      void Function(String) onChanged, String? defaultValue) {
    return PlatformTextField(
      hintText: placeholder,
      onChanged: onChanged,
      controller: TextEditingController(text: defaultValue),
    );
  }

  void _showAlert(String text) {
    if (_globalKey.currentContext == null) return;
    BuildContext context = _globalKey.currentContext!;
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Alert'),
        content: Text(text),
        actions: <Widget>[
          PlatformDialogAction(
            child: PlatformText('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
