import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'history_screen.dart';
import '../../providers/scan_provider.dart';
import 'result_screen.dart';

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
              FilledButton(onPressed: _onScan, child: const Text('Scan')),
            ],
          ),
        ),
      ),
    );
  }
}
