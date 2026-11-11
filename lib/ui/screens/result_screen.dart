import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detector.dart';
import '../../providers/scan_provider.dart';
import '../../services/scan_service.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  Color _colorFor(Verdict v) => switch (v) {
    Verdict.likelySafe => Colors.green.shade700,
    Verdict.suspicious => Colors.orange.shade800,
    Verdict.highRisk => Colors.red.shade700,
  };

  IconData _iconFor(Verdict v) => switch (v) {
    Verdict.likelySafe => Icons.verified_user_outlined,
    Verdict.suspicious => Icons.warning_amber_rounded,
    Verdict.highRisk => Icons.gpp_bad_outlined,
  };

  String _summaryFor(Verdict v) => switch (v) {
    Verdict.likelySafe => 'We found no strong red flags.',
    Verdict.suspicious => 'Some parts of this look like a scam. Be careful.',
    Verdict.highRisk => 'This looks like a scam. Do not act on it.',
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroCard(
              score: result.score,
              label: verdict.label,
              summary: _summaryFor(verdict),
              color: color,
              icon: _iconFor(verdict),
            ),
            if (result.failedChecks > 0) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${result.failedChecks} check(s) could not run, so '
                          'this result may be incomplete. Be extra careful.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Why this score',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (result.findings.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.check_circle_outline),
                  title: Text('No red flags found by our rules.'),
                ),
              ),
            for (final f in result.findings)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _FindingCard(finding: f, color: color),
              ),
            const SizedBox(height: 16),
            _NextStepsCard(isSafe: verdict == Verdict.likelySafe),
          ],
        ),
      ),
    );
  }
}

/// Big card at the top: animated gauge, verdict and a one-line summary.
class _HeroCard extends StatelessWidget {
  final int score;
  final String label;
  final String summary;
  final Color color;
  final IconData icon;

  const _HeroCard({
    required this.score,
    required this.label,
    required this.summary,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 170,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The ring grows from 0 to the score when the screen opens.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: score / 100),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text('out of 100', style: textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            summary,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// One reason with its points.
class _FindingCard extends StatelessWidget {
  final Finding finding;
  final Color color;

  const _FindingCard({required this.finding, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: const Icon(Icons.flag_outlined),
        ),
        title: Text(finding.reason),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '+${finding.points}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// "What to do next" card. Shorter text when the result is likely safe.
class _NextStepsCard extends StatelessWidget {
  final bool isSafe;

  const _NextStepsCard({required this.isSafe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isSafe
            ? const Row(
                children: [
                  Icon(Icons.lightbulb_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No red flags found, but this is not a guarantee. '
                      'Never share OTP, PIN or CVV with anyone.',
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What to do next',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _Step(
                    icon: Icons.block,
                    text: 'Do not click links or share OTP, PIN or CVV.',
                  ),
                  const _Step(
                    icon: Icons.phone_disabled_outlined,
                    text: 'Do not call numbers given in the message.',
                  ),
                  const _Step(
                    icon: Icons.call_outlined,
                    text: 'If you lost money, call 1930 right away.',
                  ),
                  const _Step(
                    icon: Icons.report_outlined,
                    text: 'Report at cybercrime.gov.in.',
                  ),
                ],
              ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Step({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
