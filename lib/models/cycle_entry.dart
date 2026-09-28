/// Represents a single logged period with its start and end date,
/// plus optional symptoms and flow intensity notes for each day logged.
class CycleEntry {
  final String id;
  final DateTime startDate;
  DateTime? endDate;
  List<String> symptoms;
  String flow; // light, medium, heavy
  String notes;

  CycleEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    List<String>? symptoms,
    this.flow = 'medium',
    this.notes = '',
  }) : symptoms = symptoms ?? [];

  /// Length of this period in days (inclusive). Falls back to 1 if
  /// the period hasn't been marked as ended yet.
  int get periodLength {
    if (endDate == null) return 1;
    return endDate!.difference(startDate).inDays + 1;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'symptoms': symptoms,
        'flow': flow,
        'notes': notes,
      };

  factory CycleEntry.fromJson(Map<String, dynamic> json) => CycleEntry(
        id: json['id'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null
            ? DateTime.parse(json['endDate'] as String)
            : null,
        symptoms: List<String>.from(json['symptoms'] ?? []),
        flow: json['flow'] as String? ?? 'medium',
        notes: json['notes'] as String? ?? '',
      );
}

/// User-configurable settings that drive cycle predictions.
class CycleSettings {
  int averageCycleLength; // days between period starts
  int averagePeriodLength; // days a period typically lasts

  CycleSettings({
    this.averageCycleLength = 28,
    this.averagePeriodLength = 5,
  });

  Map<String, dynamic> toJson() => {
        'averageCycleLength': averageCycleLength,
        'averagePeriodLength': averagePeriodLength,
      };

  factory CycleSettings.fromJson(Map<String, dynamic> json) => CycleSettings(
        averageCycleLength: json['averageCycleLength'] as int? ?? 28,
        averagePeriodLength: json['averagePeriodLength'] as int? ?? 5,
      );
}
