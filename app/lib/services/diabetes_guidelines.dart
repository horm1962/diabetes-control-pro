import '../models/user_profile.dart';

class DiabetesGuidelines {
  static Map<String, double> targetRanges(DiabetesType type) {
    switch (type) {
      case DiabetesType.type1:
        return {'low': 70, 'high': 130, 'post_meal': 180};
      case DiabetesType.type2:
        return {'low': 80, 'high': 130, 'post_meal': 180};
      case DiabetesType.gestational:
        return {'low': 60, 'high': 95, 'post_meal': 120};
    }
  }

  static List<String> dailyTips(DiabetesType type) {
    switch (type) {
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
