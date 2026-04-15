enum GlucoseContext {
  fasting,
  preMeal,
  postMeal,
  beforeBed,
  other
}

class GlucoseLog {
  final String id;
  final double value; // mg/dL
  final GlucoseContext context;
  final DateTime timestamp;
  final String? notes;

  GlucoseLog({
    required this.id,
    required this.value,
    required this.context,
    required this.timestamp,
    this.notes,
  });

  factory GlucoseLog.fromJson(Map<String, dynamic> json) {
    return GlucoseLog(
      id: json['id'],
      value: json['value'].toDouble(),
      context: mapContextFromJson(json['context'] ?? 'other'),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'context': mapContextToJson(context),
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  static GlucoseContext mapContextFromJson(String value) {
    switch (value) {
      case 'pre_meal':
      case 'preMeal':
        return GlucoseContext.preMeal;
      case 'post_meal':
      case 'postMeal':
        return GlucoseContext.postMeal;
      case 'before_bed':
      case 'beforeBed':
        return GlucoseContext.beforeBed;
      case 'fasting':
        return GlucoseContext.fasting;
      case 'other':
      default:
        return GlucoseContext.other;
    }
  }

  static String mapContextToJson(GlucoseContext context) {
    switch (context) {
      case GlucoseContext.fasting:
        return 'fasting';
      case GlucoseContext.preMeal:
        return 'pre_meal';
      case GlucoseContext.postMeal:
        return 'post_meal';
      case GlucoseContext.beforeBed:
        return 'before_bed';
      case GlucoseContext.other:
        return 'other';
    }
  }

  String get contextLabel {
    switch (context) {
      case GlucoseContext.fasting:
        return 'Ayunas';
      case GlucoseContext.preMeal:
        return 'Antes de comer';
      case GlucoseContext.postMeal:
        return 'Después de comer';
      case GlucoseContext.beforeBed:
        return 'Antes de dormir';
      case GlucoseContext.other:
        return 'Otro';
    }
  }
}
