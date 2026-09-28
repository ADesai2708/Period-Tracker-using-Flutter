import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/cycle_entry.dart';
import '../services/storage_service.dart';
import '../utils/cycle_calculator.dart';
import '../utils/theme.dart';
import 'log_period_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  List<CycleEntry> _entries = [];
  CycleSettings _settings = CycleSettings();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _storage.loadEntries();
    final settings = await _storage.loadSettings();
    setState(() {
      _entries = entries;
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _openLogSheet({CycleEntry? existing}) async {
    final result = await showModalBottomSheet<CycleEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LogPeriodSheet(existing: existing),
    );
    if (result != null) {
      setState(() {
        if (existing != null) {
          final idx = _entries.indexWhere((e) => e.id == existing.id);
          if (idx != -1) _entries[idx] = result;
        } else {
          _entries.add(result);
        }
      });
      await _storage.saveEntries(_entries);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final calc = CycleCalculator(_entries, _settings);
    final cycleDay = calc.currentCycleDay;
    final nextStart = calc.nextPredictedStart;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cycle Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HistoryScreen(entries: _entries, storage: _storage),
              ));
              _load();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SettingsScreen(settings: _settings, storage: _storage),
              ));
              _load();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLogSheet(),
        icon: const Icon(Icons.add),
        label: const Text('Log Period'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _statusCard(cycleDay, nextStart),
            const SizedBox(height: 16),
            _calendarCard(calc),
            const SizedBox(height: 16),
            _legend(),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(int? cycleDay, DateTime? nextStart) {
    String title;
    String subtitle;
    if (_entries.isEmpty) {
      title = 'No periods logged yet';
      subtitle = 'Tap "Log Period" to get started';
    } else if (cycleDay != null && nextStart != null) {
      final daysToNext = nextStart.difference(DateTime.now()).inDays;
      title = 'Cycle day $cycleDay';
      subtitle = daysToNext >= 0
          ? 'Next period expected in $daysToNext day${daysToNext == 1 ? '' : 's'}'
          : 'Period may be a few days late';
    } else {
      title = 'Tracking started';
      subtitle = 'Log a full cycle to see predictions';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFFF48FB1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _calendarCard(CycleCalculator calc) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 180)),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
        },
        onPageChanged: (focused) => _focusedDay = focused,
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) =>
              _dayCell(day, calc, false),
          todayBuilder: (context, day, focusedDay) =>
              _dayCell(day, calc, true),
        ),
      ),
    );
  }

  Widget _dayCell(DateTime day, CycleCalculator calc, bool isToday) {
    Color? bg;
    Color textColor = AppColors.textDark;
    if (calc.isPeriodDay(day)) {
      bg = AppColors.primary;
      textColor = Colors.white;
    } else if (calc.isPredictedPeriodDay(day)) {
      bg = AppColors.predicted;
    } else if (calc.isFertileDay(day)) {
      bg = AppColors.fertileLight;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      alignment: Alignment.center,
      child: Text('${day.day}', style: TextStyle(color: textColor)),
    );
  }

  Widget _legend() {
    Widget dot(Color c, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        dot(AppColors.primary, 'Period'),
        dot(AppColors.predicted, 'Predicted'),
        dot(AppColors.fertileLight, 'Fertile window'),
      ],
    );
  }
}
