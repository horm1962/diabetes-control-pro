enum ActivityIntensity {
  low,
  medium,
  high
}

class ActivityLog {
  final String id;
  final String activityType;
  final int durationMinutes;
  final ActivityIntensity intensity;
  final int? caloriesBurned;
  final DateTime timestamp;
  final String? notes;

  ActivityLog({
    required this.id,
    required this.activityType,
    required this.durationMinutes,
    required this.intensity,
    this.caloriesBurned,
    required this.timestamp,
    this.notes,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      activityType: json['activityType'],
      durationMinutes: json['durationMinutes'],
      intensity: ActivityIntensity.values.byName(json['intensity']),
      caloriesBurned: json['caloriesBurned'],
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activityType': activityType,
      'durationMinutes': durationMinutes,
      'intensity': intensity.name,
      'caloriesBurned': caloriesBurned,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  String get intensityLabel {
    switch (intensity) {
      case ActivityIntensity.low: return 'Baja';
      case ActivityIntensity.medium: return 'Media';
      case ActivityIntensity.high: return 'Alta';
    }
  }
}
