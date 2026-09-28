import 'package:flutter/material.dart';
import '../models/cycle_entry.dart';
import '../utils/theme.dart';

const _symptomOptions = [
  'Cramps',
  'Headache',
  'Bloating',
  'Fatigue',
  'Mood swings',
  'Acne',
  'Backache',
  'Nausea',
];

/// Bottom sheet for logging a new period or editing an existing one.
/// Returns the created/updated CycleEntry via Navigator.pop, or null
/// if the user cancels.
class LogPeriodSheet extends StatefulWidget {
  final CycleEntry? existing;
  const LogPeriodSheet({super.key, this.existing});

  @override
  State<LogPeriodSheet> createState() => _LogPeriodSheetState();
}

class _LogPeriodSheetState extends State<LogPeriodSheet> {
  late DateTime _startDate;
  DateTime? _endDate;
  late String _flow;
  late Set<String> _symptoms;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _startDate = e?.startDate ?? DateTime.now();
    _endDate = e?.endDate;
    _flow = e?.flow ?? 'medium';
    _symptoms = {...(e?.symptoms ?? [])};
    _notesController = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _save() {
    final entry = CycleEntry(
      id: widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: _startDate,
      endDate: _endDate,
      symptoms: _symptoms.toList(),
      flow: _flow,
      notes: _notesController.text.trim(),
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isEditing ? 'Edit Period' : 'Log Period',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              _dateTile(
                label: 'Start date',
                date: _startDate,
                onTap: () => _pickDate(isStart: true),
              ),
              const SizedBox(height: 12),
              _dateTile(
                label: 'End date (optional)',
                date: _endDate,
                onTap: () => _pickDate(isStart: false),
                onClear: _endDate != null
                    ? () => setState(() => _endDate = null)
                    : null,
              ),
              const SizedBox(height: 20),
              Text('Flow', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Row(
                children: ['light', 'medium', 'heavy'].map((f) {
                  final selected = _flow == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(f[0].toUpperCase() + f.substring(1)),
                      selected: selected,
                      selectedColor: AppColors.primaryLight,
                      onSelected: (_) => setState(() => _flow = f),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Symptoms', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _symptomOptions.map((s) {
                  final selected = _symptoms.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: selected,
                    selectedColor: AppColors.primaryLight,
                    onSelected: (val) => setState(() {
                      if (val) {
                        _symptoms.add(s);
                      } else {
                        _symptoms.remove(s);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Text('Notes', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Anything else you want to remember...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Update' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateTile({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null
                    ? label
                    : '$label: ${date.day}/${date.month}/${date.year}',
                style: const TextStyle(color: AppColors.textDark),
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
