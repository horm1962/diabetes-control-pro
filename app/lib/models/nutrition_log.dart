enum MealType {
  breakfast,
  lunch,
  dinner,
  snack
}

class NutritionLog {
  final String id;
  final MealType mealType;
  final double? carbsG;
  final double? proteinG;
  final double? fatG;
  final int? calories;
  final String? notes;
  final DateTime timestamp;

  NutritionLog({
    required this.id,
    required this.mealType,
    this.carbsG,
    this.proteinG,
    this.fatG,
    this.calories,
    this.notes,
    required this.timestamp,
  });

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    return NutritionLog(
      id: json['id'],
      mealType: MealType.values.byName(json['mealType']),
      carbsG: json['carbsG'] != null ? double.parse(json['carbsG'].toString()) : null,
      proteinG: json['proteinG'] != null ? double.parse(json['proteinG'].toString()) : null,
      fatG: json['fatG'] != null ? double.parse(json['fatG'].toString()) : null,
      calories: json['calories'],
      notes: json['notes'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType.name,
      'carbsG': carbsG,
      'proteinG': proteinG,
      'fatG': fatG,
      'calories': calories,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get mealLabel {
    switch (mealType) {
      case MealType.breakfast: return 'Desayuno';
      case MealType.lunch: return 'Almuerzo';
      case MealType.dinner: return 'Cena';
      case MealType.snack: return 'Snack';
    }
  }
}
