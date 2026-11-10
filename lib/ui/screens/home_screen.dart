import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history_screen.dart';
import '../../providers/scan_provider.dart';
import 'result_screen.dart';
import 'package:flutter/services.dart';

// Class 1: the widget itself. It holds no logic.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Class 2: the state. ALL of the code below lives inside this class.
class _HomeScreenState extends State<HomeScreen> {
  static const int maxLength = 2000;
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

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paste a suspicious SMS or link. Everything is checked on '
                'your phone. Nothing is uploaded.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                maxLines: 8,
                maxLength: maxLength,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste message or link here',
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _onClear,
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FilledButton(onPressed: _onScan, child: const Text('Scan')),
            ],
          ),
        ),
      ),
    );
  }
}
