import 'package:flutter/material.dart';
import '../models/cycle_entry.dart';
import '../services/storage_service.dart';
import '../utils/theme.dart';
import 'log_period_screen.dart';

/// Lists all logged periods, newest first, with edit/delete actions.
class HistoryScreen extends StatefulWidget {
  final List<CycleEntry> entries;
  final StorageService storage;
  const HistoryScreen({super.key, required this.entries, required this.storage});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late List<CycleEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = [...widget.entries]
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> _edit(CycleEntry entry) async {
    final result = await showModalBottomSheet<CycleEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogPeriodSheet(existing: entry),
    );
    if (result != null) {
      setState(() {
        final idx = _entries.indexWhere((e) => e.id == entry.id);
        if (idx != -1) _entries[idx] = result;
      });
      await widget.storage.saveEntries(_entries);
    }
  }

  Future<void> _delete(CycleEntry entry) async {
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
    await widget.storage.saveEntries(_entries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _entries.isEmpty
          ? const Center(child: Text('No periods logged yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (context, i) {
                final e = _entries[i];
                return Dismissible(
                  key: ValueKey(e.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade300,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _delete(e),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      onTap: () => _edit(e),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.water_drop,
                            color: AppColors.primary, size: 20),
                      ),
                      title: Text(_formatRange(e)),
                      subtitle: Text(
                        [
                          '${e.periodLength} day${e.periodLength == 1 ? '' : 's'}',
                          e.flow,
                          if (e.symptoms.isNotEmpty) e.symptoms.join(', '),
                        ].join(' · '),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatRange(CycleEntry e) {
    final s = e.startDate;
    if (e.endDate == null) return '${s.day}/${s.month}/${s.year} - ongoing';
    final end = e.endDate!;
    return '${s.day}/${s.month}/${s.year} - ${end.day}/${end.month}/${end.year}';
  }
}
