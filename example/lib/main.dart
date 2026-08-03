import 'package:flutter/material.dart';

import 'package:ramp_flutter/ramp_flutter.dart';

import 'configuration_form.dart';
import 'signed_url_form.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RampFlutterApp());
}

enum LaunchMode { configuration, signedUrl }

class RampFlutterApp extends StatefulWidget {
  const RampFlutterApp({super.key});

  @override
  State<RampFlutterApp> createState() => _RampFlutterAppState();
}

class _RampFlutterAppState extends State<RampFlutterApp> {
  final _signedUrlKey = GlobalKey<SignedUrlFormState>();
  final _configurationKey = GlobalKey<ConfigurationFormState>();
  var _launchMode = LaunchMode.signedUrl;

  Future<void> _openRamp(BuildContext context) async {
    final RampFlutter ramp;
    try {
      ramp = switch (_launchMode) {
        LaunchMode.signedUrl => RampFlutter.signed(_signedUrlKey.currentState!.url),
        LaunchMode.configuration => RampFlutter(_configurationKey.currentState!.configuration),
      };
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$error')));
      return;
    }

    ramp.onWidgetEvent = (event) {
      debugPrint('Ramp event: $event');
      switch (event) {
        case SendCryptoRequested():
          ramp.postHostEvent(SendCryptoResult.txHash('demo-tx-hash'));
        case RequestCryptoAccount(:final payload):
          ramp.postHostEvent(
            RequestCryptoAccountResult.account(address: '0xabc', type: payload.type),
          );
        case WidgetClose():
          if (context.mounted) Navigator.of(context).maybePop();
        default:
          break;
      }
    };

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.sizeOf(sheetContext).height * 0.92,
        child: ramp.view,
      ),
    );

    ramp.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Ramp Network Flutter')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SegmentedButton<LaunchMode>(
                  expandedInsets: EdgeInsets.zero,
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: LaunchMode.signedUrl, label: Text('Signed URL')),
                    ButtonSegment(value: LaunchMode.configuration, label: Text('Configuration')),
                  ],
                  selected: {_launchMode},
                  onSelectionChanged: (selection) {
                    setState(() => _launchMode = selection.single);
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: IndexedStack(
                    index: _launchMode == LaunchMode.signedUrl ? 0 : 1,
                    children: [
                      SignedUrlForm(key: _signedUrlKey),
                      ConfigurationForm(key: _configurationKey),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _openRamp(context),
                    child: const Text('Open Ramp', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
