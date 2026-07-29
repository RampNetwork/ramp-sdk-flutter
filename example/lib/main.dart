import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:ramp_flutter/ramp_flutter.dart';

import 'secrets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RampFlutterApp());
}

class RampFlutterApp extends StatefulWidget {
  const RampFlutterApp({super.key});

  @override
  State<RampFlutterApp> createState() => _RampFlutterAppState();
}

class _RampFlutterAppState extends State<RampFlutterApp> {
  final ValueNotifier<List<_DebugEvent>> _debugEvents = ValueNotifier<List<_DebugEvent>>(const []);
  var _nextDebugEventId = 0;

  final List<String> _predefinedEnvironments = [
    'https://app.dev.ramp-network.org',
    'https://app.demo.ramp.network',
    'https://app.rampnetwork.com',
  ];

  int _selectedEnvironment = 0;
  String? _userEmailAddress;
  String? _fiatValue;
  String? _fiatCurrency;
  String? _defaultAsset = 'BTC_BTC';
  String? _offrampAsset;
  String? _userAddress;
  String? _hostAppName = 'Ramp Network Flutter';
  String? _hostApiKey;
  String? _defaultFlow = 'ONRAMP';
  List<String> _enabledFlows = ['ONRAMP', 'OFFRAMP', 'SWAP'];

  @override
  void initState() {
    _applyEnvironment(_selectedEnvironment);
    super.initState();
  }

  @override
  void dispose() {
    _debugEvents.dispose();
    super.dispose();
  }

  void _selectEnvironment(int id) {
    _applyEnvironment(id);
    setState(() {});
  }

  void _applyEnvironment(int id) {
    _selectedEnvironment = id;
    _hostApiKey = id == 0 ? ExampleSecrets.hostApiKeyInternal : null;
  }

  Configuration _buildConfiguration() {
    return Configuration(
      url: _predefinedEnvironments[_selectedEnvironment],
      hostAppName: _hostAppName,
      hostLogoUrl: 'https://assets.rampnetwork.com/misc/ramp-network-logo.svg',
      defaultFlow: _defaultFlow,
      enabledFlows: List<String>.from(_enabledFlows),
      defaultAsset: _defaultAsset,
      offrampAsset: _offrampAsset,
      useSendCryptoCallback: true,
      deepLinkScheme: 'rampflutterdemo',
      hostApiKey: _hostApiKey,
      userEmailAddress: _userEmailAddress,
      fiatValue: _fiatValue,
      fiatCurrency: _fiatCurrency,
      userAddress: _userAddress,
    );
  }

  void _addDebugEvent(String label, [Map<String, Object?> data = const {}]) {
    final encoded = const JsonEncoder.withIndent('  ').convert({'event': label, ...data});
    debugPrint('Ramp example event:\n$encoded');
    _debugEvents.value = [..._debugEvents.value, _DebugEvent(_nextDebugEventId++, encoded)];
  }

  void _removeDebugEvent(int id) {
    _debugEvents.value = _debugEvents.value.where((e) => e.id != id).toList(growable: false);
  }

  Future<void> _showRamp(BuildContext context) async {
    final ramp = RampFlutter.fromConfiguration(_buildConfiguration());

    ramp.onWidgetEvent = (event) {
      switch (event) {
        case WidgetConfigDone():
          _addDebugEvent('WIDGET_CONFIG_DONE');
        case WidgetConfigFailed():
          _addDebugEvent('WIDGET_CONFIG_FAILED');
        case PurchaseCreated(:final payload):
          _addDebugEvent('PURCHASE_CREATED', {
            'id': payload.purchase?.id,
            'asset': payload.purchase?.asset?.symbol,
          });
        case OfframpSaleCreated(:final payload):
          _addDebugEvent('OFFRAMP_SALE_CREATED', {'id': payload.sale?.id});
        case SendCryptoRequested(:final payload):
          _addDebugEvent('SEND_CRYPTO', {
            'address': payload.address,
            'amount': payload.amount,
            'asset': payload.assetInfo?.symbol,
          });
          ramp.postHostEvent(SendCryptoResult.txHash('123'));
        case RequestCryptoAccount(:final payload):
          _addDebugEvent('REQUEST_CRYPTO_ACCOUNT', {
            'type': payload.type,
            'assetSymbol': payload.assetSymbol,
          });
          ramp.postHostEvent(
            RequestCryptoAccountResult.account(
              address: '0xabc',
              type: payload.type,
              assetSymbol: payload.assetSymbol,
            ),
          );
        case WidgetClose(:final payload):
          _addDebugEvent('WIDGET_CLOSE', {'showAlert': payload.showAlert});
        case WidgetCloseRequest():
          _addDebugEvent('WIDGET_CLOSE_REQUEST');
      }
    };

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
          child: Material(
            color: Colors.white,
            child: Stack(
              children: [
                Column(
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
                Positioned(
                  left: 8,
                  right: 8,
                  top: 36,
                  child: _DebugEventList(
                    eventsListenable: _debugEvents,
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.45,
                    onDismiss: _removeDebugEvent,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    ramp.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Ramp Network Flutter')),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ListView(children: _formFields(context)),
              ),
              Positioned(
                left: 8,
                right: 8,
                top: 8,
                child: _DebugEventList(
                  eventsListenable: _debugEvents,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  onDismiss: _removeDebugEvent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _formFields(BuildContext context) {
    return [..._configurationForm(), _showRampButton(context), _appInfo()];
  }

  Widget _appInfo() {
    return const Text('App version: Flutter WebView');
  }

  List<Widget> _configurationForm() {
    return [
      _segmentedControl('Env:', ['dev', 'demo', 'prod'], _selectEnvironment),
      Text(
        _predefinedEnvironments[_selectedEnvironment],
        style: const TextStyle(color: Color.fromRGBO(46, 190, 117, 1)),
      ),
      _textField('User email address', (text) => _userEmailAddress = text, _userEmailAddress),
      _textField('Fiat value', (text) => _fiatValue = text, _fiatValue),
      _textField('Fiat currency', (text) => _fiatCurrency = text, _fiatCurrency),
      _textField('Default asset', (text) => _defaultAsset = text, _defaultAsset),
      _textField('Offramp asset', (text) => _offrampAsset = text, _offrampAsset),
      _textField('User address', (text) => _userAddress = text, _userAddress),
      _textField('Host app name', (text) => _hostAppName = text, _hostAppName),
      _textField('Host API key', (text) => _hostApiKey = text, _hostApiKey),
      _segmentedControl('Default flow:', ['ONRAMP', 'OFFRAMP'], (index) {
        if (index == 0) {
          _defaultFlow = 'ONRAMP';
        }
        if (index == 1) {
          _defaultFlow = 'OFFRAMP';
        }
        setState(() {});
      }),
      _enabledFlowsSection(),
    ];
  }

  Widget _enabledFlowsSection() {
    Widget flowSwitch(String name) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(name),
          Switch(
            value: _enabledFlows.contains(name),
            onChanged: (enabled) {
              setState(() {
                if (enabled) {
                  _enabledFlows = [..._enabledFlows, name];
                } else {
                  _enabledFlows = _enabledFlows.where((flow) => flow != name).toList();
                }
              });
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enabled flows:'),
        Row(children: [flowSwitch('ONRAMP'), flowSwitch('OFFRAMP'), flowSwitch('SWAP')]),
      ],
    );
  }

  Widget _showRampButton(BuildContext context) {
    return TextButton(onPressed: () => _showRamp(context), child: const Text('Show Ramp'));
  }

  Row _segmentedControl(String title, List<String> options, void Function(int) itemSelected) {
    final segments = options.asMap().entries.map((entry) {
      return TextButton(onPressed: () => itemSelected(entry.key), child: Text(entry.value));
    }).toList();
    return Row(children: [Text(title), ...segments]);
  }

  TextField _textField(String placeholder, void Function(String) onChanged, String? defaultValue) {
    return TextField(
      decoration: InputDecoration(hintText: placeholder),
      onChanged: onChanged,
      controller: TextEditingController(text: defaultValue),
    );
  }
}

class _DebugEvent {
  _DebugEvent(this.id, this.body);

  final int id;
  final String body;
}

class _DebugEventList extends StatelessWidget {
  const _DebugEventList({required this.eventsListenable, required this.maxHeight, required this.onDismiss});

  final ValueNotifier<List<_DebugEvent>> eventsListenable;
  final double maxHeight;
  final void Function(int id) onDismiss;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_DebugEvent>>(
      valueListenable: eventsListenable,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: events.length,
            separatorBuilder: (context, index) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final event = events[index];
              return Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF323232),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.body,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontFamily: 'Courier'),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                        onPressed: () => onDismiss(event.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
