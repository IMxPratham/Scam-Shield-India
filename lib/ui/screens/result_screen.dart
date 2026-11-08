import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/scan_provider.dart';
import '../../services/scan_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Color _colorFor(Verdict v) => switch (v) {
    Verdict.likelySafe => Colors.green,
    Verdict.suspicious => Colors.orange,
    Verdict.highRisk => Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();
    final result = provider.result;
    final verdict = provider.verdict;

    if (result == null || verdict == null) {
      return const Scaffold(body: Center(child: Text('No result yet.')));
    }

    final color = _colorFor(verdict);

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Gauge: a circle that fills up to score/100
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: result.score / 100,
                      strokeWidth: 12,
                      color: color,
                      backgroundColor: Colors.grey.shade300,
                    ),
                  ),
                  Text(
                    '${result.score}',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              verdict.label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Why:', style: TextStyle(fontWeight: FontWeight.bold)),
          if (result.findings.isEmpty)
            const ListTile(title: Text('No red flags found by our rules.')),
          for (final f in result.findings)
            ListTile(title: Text(f.reason), trailing: Text('+${f.points}')),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                verdict == Verdict.likelySafe
                    ? 'No red flags found, but this is not a guarantee. '
                          'Never share OTP, PIN or CVV with anyone.'
                    : 'What to do next:\n'
                          '1. Do not click links or share OTP/PIN/CVV.\n'
                          '2. Do not call numbers given in the message.\n'
                          '3. If you lost money, call 1930 right away.\n'
                          '4. Report at cybercrime.gov.in.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
