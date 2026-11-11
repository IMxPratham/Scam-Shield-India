import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/scan_record.dart';
import '../../data/scan_repository.dart';
import '../../services/scan_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<ScanRepository>().getAll();
  }

  /// History stores the verdict as text, so we map the text back to a colour.
  Color _colorFor(String verdictLabel) {
    if (verdictLabel == Verdict.highRisk.label) return Colors.red.shade700;
    if (verdictLabel == Verdict.suspicious.label) {
      return Colors.orange.shade800;
    }
    return Colors.green.shade700;
  }

  Future<void> _confirmDeleteAll() async {
    final repo = context.read<ScanRepository>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all history?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await repo.deleteAll();
    if (!mounted) return;
    setState(() {
      _future = repo.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete all',
            onPressed: _confirmDeleteAll,
          ),
        ],
      ),
      body: FutureBuilder<List<ScanRecord>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load history.'));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 72,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No scans yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  const Text('Scanned messages will appear here.'),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, i) {
              final r = records[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _HistoryCard(record: r, color: _colorFor(r.verdict)),
              );
            },
          );
        },
      ),
    );
  }
}

/// One saved scan. Tap to see the reasons.
class _HistoryCard extends StatelessWidget {
  final ScanRecord record;
  final Color color;

  const _HistoryCard({required this.record, required this.color});

  @override
  Widget build(BuildContext context) {
    final findings = record.findings;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Text(
            '${record.score}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          record.inputPreview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  record.verdict,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                DateFormat('d MMM, HH:mm').format(record.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        children: [
          if (findings.isEmpty)
            const Text('No red flags found by our rules.')
          else
            for (final f in findings)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(f.reason)),
                    Text(
                      '+${f.points}',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
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
