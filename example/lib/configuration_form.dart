import 'package:flutter/material.dart';

import 'package:ramp_flutter/ramp_flutter.dart';

class ConfigurationForm extends StatefulWidget {
  const ConfigurationForm({super.key, this.initialConfiguration});

  final Configuration? initialConfiguration;

  static Configuration defaults() => const Configuration(
    url: 'https://app.dev.ramp-network.org',
    hostAppName: 'Ramp Network Flutter',
    enabledFlows: [TransactionFlow.ONRAMP, TransactionFlow.OFFRAMP, TransactionFlow.SWAP],
    defaultFlow: TransactionFlow.ONRAMP,
    outAsset: 'BTC_BTC',
    useSendCryptoCallback: true,
  );

  @override
  State<ConfigurationForm> createState() => ConfigurationFormState();
}

class ConfigurationFormState extends State<ConfigurationForm> {
  static const _environments = [
    'https://app.dev.ramp-network.org',
    'https://app.demo.ramp.network',
    'https://app.rampnetwork.com',
  ];

  late final TextEditingController _hostApiKey;
  late final TextEditingController _hostAppName;
  late final TextEditingController _inAsset;
  late final TextEditingController _inAssetValue;
  late final TextEditingController _outAsset;
  late final TextEditingController _outAssetValue;
  late final TextEditingController _userEmailAddress;
  late final TextEditingController _userAddress;
  late String _url;
  late TransactionFlow _defaultFlow;
  late List<TransactionFlow> _enabledFlows;

  Configuration get configuration => _build();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialConfiguration ?? ConfigurationForm.defaults();
    _url = initial.url ?? _environments.first;
    _hostApiKey = TextEditingController(text: initial.hostApiKey ?? '');
    _hostAppName = TextEditingController(text: initial.hostAppName ?? '');
    _inAsset = TextEditingController(text: initial.inAsset ?? '');
    _inAssetValue = TextEditingController(text: initial.inAssetValue ?? '');
    _outAsset = TextEditingController(text: initial.outAsset ?? '');
    _outAssetValue = TextEditingController(text: initial.outAssetValue ?? '');
    _userEmailAddress = TextEditingController(text: initial.userEmailAddress ?? '');
    _userAddress = TextEditingController(text: initial.userAddress ?? '');
    _defaultFlow = initial.defaultFlow ?? TransactionFlow.ONRAMP;
    _enabledFlows = List<TransactionFlow>.from(
      initial.enabledFlows ?? const [TransactionFlow.ONRAMP, TransactionFlow.OFFRAMP, TransactionFlow.SWAP],
    );
  }

  List<TextEditingController> get _textControllers => [
    _hostApiKey,
    _hostAppName,
    _inAsset,
    _inAssetValue,
    _outAsset,
    _outAssetValue,
    _userEmailAddress,
    _userAddress,
  ];

  @override
  void dispose() {
    for (final controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _trimmed(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Configuration _build() => Configuration(
    url: _url,
    hostApiKey: _trimmed(_hostApiKey),
    hostAppName: _trimmed(_hostAppName),
    defaultFlow: _defaultFlow,
    enabledFlows: List<TransactionFlow>.from(_enabledFlows),
    inAsset: _trimmed(_inAsset),
    inAssetValue: _trimmed(_inAssetValue),
    outAsset: _trimmed(_outAsset),
    outAssetValue: _trimmed(_outAssetValue),
    userEmailAddress: _trimmed(_userEmailAddress),
    userAddress: _trimmed(_userAddress),
    useSendCryptoCallback: true,
  );

  Widget _field(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Environment'),
        SegmentedButton<String>(
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: const [
            ButtonSegment(value: 'https://app.dev.ramp-network.org', label: Text('dev')),
            ButtonSegment(value: 'https://app.demo.ramp.network', label: Text('demo')),
            ButtonSegment(value: 'https://app.rampnetwork.com', label: Text('prod')),
          ],
          selected: {_url},
          onSelectionChanged: (selection) => setState(() => _url = selection.single),
        ),
        const SizedBox(height: 12),
        _field(_hostApiKey, 'Host API key'),
        _field(_hostAppName, 'Host app name'),
        const Text('Enabled flows'),
        Row(
          children: [
            for (final flow in TransactionFlow.values)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(flow.name, textAlign: TextAlign.center),
                    ),
                    showCheckmark: false,
                    selected: _enabledFlows.contains(flow),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _enabledFlows = [..._enabledFlows, flow];
                        } else {
                          _enabledFlows = _enabledFlows.where((value) => value != flow).toList();
                        }
                      });
                    },
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Default flow'),
        SegmentedButton<TransactionFlow>(
          showSelectedIcon: false,
          expandedInsets: EdgeInsets.zero,
          segments: const [
            ButtonSegment(value: TransactionFlow.ONRAMP, label: Text('ONRAMP')),
            ButtonSegment(value: TransactionFlow.OFFRAMP, label: Text('OFFRAMP')),
            ButtonSegment(value: TransactionFlow.SWAP, label: Text('SWAP')),
          ],
          selected: {_defaultFlow},
          onSelectionChanged: (selection) => setState(() => _defaultFlow = selection.single),
        ),
        const SizedBox(height: 12),
        _field(_inAsset, 'In asset'),
        _field(_inAssetValue, 'In asset value'),
        _field(_outAsset, 'Out asset'),
        _field(_outAssetValue, 'Out asset value'),
        _field(_userEmailAddress, 'User email address'),
        _field(_userAddress, 'Wallet address'),
      ],
    );
  }
}
