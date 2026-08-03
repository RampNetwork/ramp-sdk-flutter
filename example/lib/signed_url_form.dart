import 'package:flutter/material.dart';

class SignedUrlForm extends StatefulWidget {
  const SignedUrlForm({super.key, this.initialUrl = ''});

  final String initialUrl;

  @override
  State<SignedUrlForm> createState() => SignedUrlFormState();
}

class SignedUrlFormState extends State<SignedUrlForm> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialUrl);

  String get url => _controller.text.trim();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsed = Uri.tryParse(url);
    final params = parsed?.queryParameters ?? const <String, String>{};
    final timestampMs = int.tryParse(params['timestamp'] ?? '');

    final checks = <(String, bool)>[
      ('https URL', parsed?.scheme == 'https'),
      ('hostApiKey', (params['hostApiKey'] ?? '').isNotEmpty),
      (timestampMs == null ? 'timestamp' : 'timestamp (${_formatLocal(timestampMs)})', timestampMs != null),
      ('signature', (params['signature'] ?? '').isNotEmpty),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          minLines: 6,
          maxLines: 12,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Signed widget URL',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            hintText: 'https://app.dev.ramp-network.org/?hostApiKey=...&timestamp=...&signature=...',
          ),
        ),
        const SizedBox(height: 8),
        for (final (label, ok) in checks)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.green : Colors.red, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(label)),
              ],
            ),
          ),
      ],
    );
  }

  String _formatLocal(int milliseconds) {
    final local = DateTime.fromMillisecondsSinceEpoch(milliseconds).toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}
