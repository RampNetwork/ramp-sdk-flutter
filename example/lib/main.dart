import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:ramp_flutter/configuration.dart';
import 'package:ramp_flutter/ramp_flutter.dart';

import 'secrets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RampFlutterApp());
}

class RampFlutterApp extends StatefulWidget {
  const RampFlutterApp({Key? key}) : super(key: key);

  @override
  State<RampFlutterApp> createState() => _RampFlutterAppState();
}

class _RampFlutterAppState extends State<RampFlutterApp> {
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final Configuration _configuration = Configuration();
  RampFlutter? _ramp;
  /// Messenger for the open sheet so snackbars appear above the WebView.
  GlobalKey<ScaffoldMessengerState>? _sheetMessengerKey;

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

  void _showEventToast(String message) {
    final messenger =
        _sheetMessengerKey?.currentState ?? _messengerKey.currentState;
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _onWidgetEvent(BuildContext context, Map<String, dynamic> event) {
    final encoded = const JsonEncoder.withIndent('  ').convert(event);
    debugPrint('Ramp example event:\n$encoded');
    _showEventToast(encoded);

    final type = event['type'];
    if (type == 'SEND_CRYPTO') {
      _ramp?.sendCrypto('123');
    }
    if (type == 'CLOSE' || type == 'WIDGET_CLOSE') {
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  Future<void> _showRamp(BuildContext context) async {
    final ramp = RampFlutter(_configuration)
      ..onWidgetEvent = (event) => _onWidgetEvent(context, event);
    final sheetMessengerKey = GlobalKey<ScaffoldMessengerState>();
    _ramp = ramp;
    _sheetMessengerKey = sheetMessengerKey;

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.92,
          child: ScaffoldMessenger(
            key: sheetMessengerKey,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                children: [
                  const SizedBox(
                    height: 28,
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                        child: SizedBox(width: 36, height: 4),
                      ),
                    ),
                  ),
                  Expanded(child: ramp.view),
                ],
              ),
            ),
          ),
        );
      },
    );

    ramp.dispose();
    if (identical(_ramp, ramp)) {
      _ramp = null;
    }
    if (identical(_sheetMessengerKey, sheetMessengerKey)) {
      _sheetMessengerKey = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _messengerKey,
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
      onPressed: () => _showRamp(context),
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
}
