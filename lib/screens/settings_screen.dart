import 'package:flutter/material.dart';
import '../models/cycle_entry.dart';
import '../services/storage_service.dart';

/// Lets the user configure the fallback averages used for predictions
/// before enough history has been logged.
class SettingsScreen extends StatefulWidget {
  final CycleSettings settings;
  final StorageService storage;
  const SettingsScreen({super.key, required this.settings, required this.storage});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _cycleLength;
  late int _periodLength;

  @override
  void initState() {
    super.initState();
    _cycleLength = widget.settings.averageCycleLength;
    _periodLength = widget.settings.averagePeriodLength;
  }

  Future<void> _save() async {
    final settings = CycleSettings(
      averageCycleLength: _cycleLength,
      averagePeriodLength: _periodLength,
    );
    await widget.storage.saveSettings(settings);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Average cycle length', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Used for predictions until you have 2+ logged periods.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: _cycleLength.toDouble(),
            min: 21,
            max: 45,
            divisions: 24,
            label: '$_cycleLength days',
            onChanged: (v) => setState(() => _cycleLength = v.round()),
          ),
          Text('$_cycleLength days'),
          const SizedBox(height: 24),
          Text('Average period length', style: Theme.of(context).textTheme.titleLarge),
          Slider(
            value: _periodLength.toDouble(),
            min: 2,
            max: 10,
            divisions: 8,
            label: '$_periodLength days',
            onChanged: (v) => setState(() => _periodLength = v.round()),
          ),
          Text('$_periodLength days'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }
}
