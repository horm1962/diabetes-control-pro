enum DiabetesType {
  type1,
  type2,
  gestational
}

enum TherapyType {
  insulin,
  oral,
  combined,
  diet_only
}

class UserProfile {
  final String userId;
  final String firstName;
  final String lastName;
  final DiabetesType diabetesType;
  final TherapyType therapyType;
  final DateTime birthDate;
  final double weightKg;
  final double heightCm;
  final double targetGlucoseLow;
  final double targetGlucoseHigh;
  final String? insulinType;
  final String? medications;
  final String? allergies;

  UserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.diabetesType,
    required this.therapyType,
    required this.birthDate,
    required this.weightKg,
    required this.heightCm,
    required this.targetGlucoseLow,
    required this.targetGlucoseHigh,
    this.insulinType,
    this.medications,
    this.allergies,
  });

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    DiabetesType? diabetesType,
    TherapyType? therapyType,
    DateTime? birthDate,
    double? weightKg,
    double? heightCm,
    double? targetGlucoseLow,
    double? targetGlucoseHigh,
    String? insulinType,
    String? medications,
    String? allergies,
  }) {
    return UserProfile(
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      diabetesType: diabetesType ?? this.diabetesType,
      therapyType: therapyType ?? this.therapyType,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      targetGlucoseLow: targetGlucoseLow ?? this.targetGlucoseLow,
      targetGlucoseHigh: targetGlucoseHigh ?? this.targetGlucoseHigh,
      insulinType: insulinType ?? this.insulinType,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse dates regardless of format
    DateTime safeParseDate(dynamic value) {
      if (value == null) return DateTime(1990, 1, 1);
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime(1990, 1, 1);
      }
    }

    return UserProfile(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      firstName: (json['firstName'] ?? json['first_name'] ?? '').toString(),
      lastName: (json['lastName'] ?? json['last_name'] ?? '').toString(),
      diabetesType: DiabetesType.values.firstWhere(
        (e) => e.name == (json['diabetesType'] ?? json['diabetes_type']),
        orElse: () => DiabetesType.type2,
      ),
      therapyType: TherapyType.values.firstWhere(
        (e) => e.name == (json['therapyType'] ?? json['therapy_type']),
        orElse: () => TherapyType.diet_only,
      ),
      birthDate: safeParseDate(json['birthDate'] ?? json['birth_date']),
      weightKg: double.tryParse((json['weightKg'] ?? json['weight_kg'] ?? 0).toString()) ?? 0,
      heightCm: double.tryParse((json['heightCm'] ?? json['height_cm'] ?? 0).toString()) ?? 0,
      targetGlucoseLow: double.tryParse((json['targetGlucoseLow'] ?? json['target_glucose_low'] ?? 70).toString()) ?? 70,
      targetGlucoseHigh: double.tryParse((json['targetGlucoseHigh'] ?? json['target_glucose_high'] ?? 140).toString()) ?? 140,
      insulinType: json['insulinType']?.toString(),
      medications: json['medications']?.toString(),
      allergies: json['allergies']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'diabetesType': diabetesType.toString().split('.').last,
      'therapyType': therapyType.toString().split('.').last,
      'birthDate': birthDate.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'targetGlucoseLow': targetGlucoseLow,
      'targetGlucoseHigh': targetGlucoseHigh,
      'insulinType': insulinType ?? '',
      'medications': medications ?? '',
      'allergies': allergies ?? '',
    };
  }

  double get imc {
    if (heightCm <= 0) return 0;
    double heightInMeters = heightCm / 100;
    return weightKg / (heightInMeters * heightInMeters);
  }

  Map<String, double> get targetRanges {
    switch (diabetesType) {
      case DiabetesType.type1:
        return {'low': 70, 'high': 130, 'post_meal': 180};
      case DiabetesType.type2:
        return {'low': 80, 'high': 130, 'post_meal': 180};
      case DiabetesType.gestational:
        return {'low': 60, 'high': 95, 'post_meal': 120}; // Más estricto
    }
  }

  List<String> get dailyTips {
    switch (diabetesType) {
      case DiabetesType.type1:
        return [
          'Verifica tus niveles antes de cada comida.',
          'Lleva siempre carbohidratos de acción rápida para hipoglucemias.',
          'Ajusta tu dosis de insulina si planeas hacer ejercicio intenso.'
        ];
      case DiabetesType.type2:
        return [
          'Una caminata de 15 min después de comer ayuda a bajar la glucosa.',
          'Prioriza fibras y granos enteros en tu dieta.',
          'Mantén un peso saludable para mejorar la sensibilidad a la insulina.'
        ];
      case DiabetesType.gestational:
        return [
          'Sigue estrictamente el horario de comidas recomendado.',
          'Camina suavemente después de las comidas principales.',
          'Reporta a tu médico si tienes 2 o más valores altos seguidos.'
        ];
    }
  }
}
