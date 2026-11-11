import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/scan_provider.dart';
import 'history_screen.dart';
import 'result_screen.dart';

// Class 1: the widget itself. It holds no logic.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Class 2: the state. It owns the text box controller and the button actions.
class _HomeScreenState extends State<HomeScreen> {
  static const int maxLength = 2000;

  // Fake examples written for testing. Tapping one fills the text box.
  static const List<(String, String)> _examples = [
    (
      'Fake KYC',
      'URGENT: Your KYC will expire today. '
          'Update KYC at http://sbi-kyc-update.xyz',
    ),
    (
      'Fake lottery',
      'You have won a lucky draw! Pay Rs 500 to claim your prize.',
    ),
    (
      'Fake OTP request',
      'Your account is blocked. Share OTP immediately to unblock it.',
    ),
    ('Normal message', 'Hi, are we meeting at 5 pm today?'),
  ];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScan() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paste a message or link first.')),
      );
      return;
    }
    context.read<ScanProvider>().scan(text);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }

  Future<void> _onPaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (!mounted) return; // the screen may have closed while we waited
    if (text == null || text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Clipboard is empty.')));
      return;
    }
    // Setting .text in code skips maxLength, so we cut it ourselves.
    _controller.text = text.length > maxLength
        ? text.substring(0, maxLength)
        : text;
  }

  void _onClear() => _controller.clear();

  void _useExample(String text) => _controller.text = text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ScamShield India'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _HeaderCard(),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Message or link',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLines: 7,
                        maxLength: maxLength,
                        decoration: InputDecoration(
                          hintText: 'Paste the suspicious SMS or link here',
                          filled: true,
                          fillColor: scheme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onPaste,
                              icon: const Icon(Icons.content_paste),
                              label: const Text('Paste'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _onClear,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: _onScan,
                        icon: const Icon(Icons.search),
                        label: const Text('Scan now'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Try a fake example',
                style: textTheme.titleSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (label, text) in _examples)
                    ActionChip(
                      avatar: const Icon(Icons.bolt, size: 18),
                      label: Text(label),
                      onPressed: () => _useExample(text),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      _Feature(
                        icon: Icons.sms_outlined,
                        title: 'Message wording',
                        subtitle:
                            'OTP requests, urgency, fake KYC, lottery bait',
                      ),
                      _Feature(
                        icon: Icons.link,
                        title: 'Link red flags',
                        subtitle: 'IP addresses, short links, odd endings',
                      ),
                      _Feature(
                        icon: Icons.copy_all_outlined,
                        title: 'Look-alike domains',
                        subtitle: 'Fake copies of well-known bank websites',
                      ),
                    ],
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

/// Gradient banner at the top of the home screen.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shield_outlined,
              color: scheme.onPrimary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Got a suspicious message?',
                  style: textTheme.titleLarge?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Checked on your phone. Nothing is uploaded.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in the "what we check" card.
class _Feature extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Feature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Icon(icon),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
