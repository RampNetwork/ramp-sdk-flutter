import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:ramp_flutter/ramp_flutter.dart';

void main() {
  runApp(const RampFlutterApp());
}

class RampFlutterApp extends StatefulWidget {
  const RampFlutterApp({Key? key}) : super(key: key);

  @override
  State<RampFlutterApp> createState() => _RampFlutterAppState();
}

class _RampFlutterAppState extends State<RampFlutterApp> {
  final Configuration _configuration = Configuration();
  final List<String> _environments = [
    "https://ri-widget-dev.firebaseapp.com",
    "https://ri-widget-staging.firebaseapp.com",
    "https://buy.ramp.network",
  ];

  int _selectedEnvironment = 0;

  @override
  void initState() {
    _configuration.fiatValue = "3";
    _configuration.fiatCurrency = "EUR";
    _configuration.defaultAsset = "ETH";
    _configuration.userAddress = "0x4b7f8e04b82ad7f9e4b4cc9e1f81c5938e1b719f";
    _configuration.hostAppName = "Ramp Flutter";
    _configuration.deepLinkScheme = 'rampflutter';

    super.initState();
  }

  void _selectEnvironment(int id) {
    setState(() => _selectedEnvironment = id);
  }

  @override
  Widget build(BuildContext context) {
    _configuration.url = _environments[_selectedEnvironment];

    return PlatformApp(
      home: PlatformScaffold(
        appBar: PlatformAppBar(title: const Text('Ramp Flutter')),
        body: Builder(
          builder: (context) => ListView(children: _formFields(context)),
        ),
        iosContentPadding: false,
        iosContentBottomPadding: false,
      ),
    );
  }

  List<Widget> _formFields(BuildContext context) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PlatformButton(
            onPressed: () => _selectEnvironment(0),
            child: const Text("dev"),
          ),
          PlatformButton(
            onPressed: () => _selectEnvironment(1),
            child: const Text("staging"),
          ),
          PlatformButton(
            onPressed: () => _selectEnvironment(2),
            child: const Text("production"),
          ),
        ],
      ),
      PlatformText(
        _environments[_selectedEnvironment],
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
      PlatformButton(
        onPressed: () {
          RampFlutter.showRamp(
            _configuration,
            (purchase, token, apiUrl) =>
                _showSnackBar(context, "Purchase created"),
            () => _showSnackBar(context, "Ramp widget closed"),
            () => _showSnackBar(context, "Ramp widget failed"),
          );
        },
        child: const Text("Show Ramp"),
      ),
    ];
  }

  PlatformTextField _textField(String placeholder,
      void Function(String) onChanged, String? defaultValue) {
    return PlatformTextField(
      hintText: placeholder,
      onChanged: onChanged,
      controller: TextEditingController(text: defaultValue),
    );
  }

  void _showSnackBar(BuildContext context, String text) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: const Text('Alert'),
        content: Text(text),
        actions: <Widget>[
          PlatformDialogAction(
            child: PlatformText('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
