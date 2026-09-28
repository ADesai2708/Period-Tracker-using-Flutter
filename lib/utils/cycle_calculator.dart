import '../models/cycle_entry.dart';

/// Pure prediction logic, kept separate from UI/storage so it's easy
/// to test and reason about.
class CycleCalculator {
  final List<CycleEntry> entries;
  final CycleSettings settings;

  CycleCalculator(this.entries, this.settings);

  /// Entries sorted oldest -> newest, used for computing real averages.
  List<CycleEntry> get _sortedAsc =>
      [...entries]..sort((a, b) => a.startDate.compareTo(b.startDate));

  /// Computes the average cycle length from logged history when there
  /// are at least 2 periods; otherwise falls back to the user's setting.
  int get effectiveCycleLength {
    final asc = _sortedAsc;
    if (asc.length < 2) return settings.averageCycleLength;
    final gaps = <int>[];
    for (int i = 1; i < asc.length; i++) {
      gaps.add(asc[i].startDate.difference(asc[i - 1].startDate).inDays);
    }
    final avg = gaps.reduce((a, b) => a + b) / gaps.length;
    return avg.round();
  }

  int get effectivePeriodLength {
    final withEnd = entries.where((e) => e.endDate != null).toList();
    if (withEnd.isEmpty) return settings.averagePeriodLength;
    final avg = withEnd.map((e) => e.periodLength).reduce((a, b) => a + b) /
        withEnd.length;
    return avg.round();
  }

  CycleEntry? get lastPeriod {
    if (entries.isEmpty) return null;
    return _sortedAsc.last;
  }

  /// Predicted start date of the next period.
  DateTime? get nextPredictedStart {
    final last = lastPeriod;
    if (last == null) return null;
    return last.startDate.add(Duration(days: effectiveCycleLength));
  }

  /// Fertile window is typically ~14 days before the next period,
  /// with a few days of margin on either side.
  DateTimeRange? get fertileWindow {
    final next = nextPredictedStart;
    if (next == null) return null;
    final ovulation = next.subtract(const Duration(days: 14));
    return DateTimeRange(
      start: ovulation.subtract(const Duration(days: 4)),
      end: ovulation.add(const Duration(days: 1)),
    );
  }

  int? get currentCycleDay {
    final last = lastPeriod;
    if (last == null) return null;
    final today = DateTime.now();
    final normalizedLast = DateTime(last.startDate.year, last.startDate.month,
        last.startDate.day);
    final normalizedToday = DateTime(today.year, today.month, today.day);
    return normalizedToday.difference(normalizedLast).inDays + 1;
  }

  bool isPeriodDay(DateTime day) {
    for (final e in entries) {
      final start = DateTime(e.startDate.year, e.startDate.month, e.startDate.day);
      final end = e.endDate != null
          ? DateTime(e.endDate!.year, e.endDate!.month, e.endDate!.day)
          : start;
      final d = DateTime(day.year, day.month, day.day);
      if (!d.isBefore(start) && !d.isAfter(end)) return true;
    }
    return false;
  }

  bool isPredictedPeriodDay(DateTime day) {
    final next = nextPredictedStart;
    if (next == null) return false;
    final start = DateTime(next.year, next.month, next.day);
    final end = start.add(Duration(days: effectivePeriodLength - 1));
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  bool isFertileDay(DateTime day) {
    final window = fertileWindow;
    if (window == null) return false;
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(window.start) && !d.isAfter(window.end);
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  DateTimeRange({required this.start, required this.end});
}
