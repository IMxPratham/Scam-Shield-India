import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/scan_record.dart';
import '../../data/scan_repository.dart';

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
    setState(() => _future = repo.getAll());
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
            return const Center(child: Text('No scans yet.'));
          }
          return ListView.separated(
            itemCount: records.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final r = records[i];
              return ListTile(
                title: Text(
                  r.inputPreview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${r.verdict} • ${DateFormat('d MMM, HH:mm').format(r.createdAt)}',
                ),
                trailing: Text(
                  '${r.score}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
