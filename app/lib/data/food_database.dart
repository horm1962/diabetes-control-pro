class FoodItem {
  final String name;
  final String portion;
  final double carbs;
  final double protein;
  final double fat;
  final double calories;

  const FoodItem({
    required this.name,
    required this.portion,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.calories,
  });
}

const List<FoodItem> foodDatabase = [
  FoodItem(name: 'Arroz blanco cocido', portion: '1 taza (158g)', carbs: 45.0, protein: 4.0, fat: 0.0, calories: 205.0),
  FoodItem(name: 'Arroz integral cocido', portion: '1 taza', carbs: 45.0, protein: 5.0, fat: 1.5, calories: 215.0),
  FoodItem(name: 'Pollo asado / a la plancha', portion: '1 porción (100g)', carbs: 0.0, protein: 31.0, fat: 3.6, calories: 165.0),
  FoodItem(name: 'Carne de res asada', portion: '1 porción (100g)', carbs: 0.0, protein: 26.0, fat: 15.0, calories: 250.0),
  FoodItem(name: 'Pescado (Tilapia / Salmón)', portion: '1 filete (100g)', carbs: 0.0, protein: 20.0, fat: 3.0, calories: 110.0),
  FoodItem(name: 'Manzana fresca', portion: '1 mediana', carbs: 25.0, protein: 0.5, fat: 0.3, calories: 95.0),
  FoodItem(name: 'Pan integral', portion: '1 rebanada', carbs: 12.0, protein: 4.0, fat: 1.0, calories: 69.0),
  FoodItem(name: 'Pan blanco', portion: '1 rebanada', carbs: 15.0, protein: 3.0, fat: 1.0, calories: 80.0),
  FoodItem(name: 'Huevo entero (frito o revuelto)', portion: '1 unidad', carbs: 1.0, protein: 6.0, fat: 7.0, calories: 90.0),
  FoodItem(name: 'Huevo cocido / duro', portion: '1 unidad', carbs: 1.0, protein: 6.0, fat: 5.0, calories: 78.0),
  FoodItem(name: 'Frijoles cocidos', portion: '1 taza', carbs: 40.0, protein: 15.0, fat: 1.0, calories: 227.0),
  FoodItem(name: 'Lentejas cocidas', portion: '1 taza', carbs: 40.0, protein: 18.0, fat: 1.0, calories: 230.0),
  FoodItem(name: 'Tortilla de maíz', portion: '1 unidad mediana', carbs: 11.0, protein: 1.5, fat: 0.5, calories: 52.0),
  FoodItem(name: 'Aguacate', portion: 'Medio aguacate', carbs: 9.0, protein: 2.0, fat: 15.0, calories: 160.0),
  FoodItem(name: 'Leche entera', portion: '1 vaso (240ml)', carbs: 12.0, protein: 8.0, fat: 8.0, calories: 150.0),
  FoodItem(name: 'Leche descremada', portion: '1 vaso (240ml)', carbs: 12.0, protein: 8.0, fat: 0.0, calories: 80.0),
  FoodItem(name: 'Banano / Plátano', portion: '1 unidad mediana', carbs: 27.0, protein: 1.0, fat: 0.3, calories: 105.0),
  FoodItem(name: 'Avena cocida', portion: '1 taza', carbs: 28.0, protein: 6.0, fat: 3.0, calories: 158.0),
  FoodItem(name: 'Papa cocida', portion: '1 mediana', carbs: 37.0, protein: 4.0, fat: 0.0, calories: 160.0),
  FoodItem(name: 'Ensalada verde (sin aderezo)', portion: '1 plato grande', carbs: 5.0, protein: 2.0, fat: 0.0, calories: 20.0),
  FoodItem(name: 'Queso fresco', portion: '1 rebanada (30g)', carbs: 1.0, protein: 5.0, fat: 7.0, calories: 85.0),
  FoodItem(name: 'Yogur natural', portion: '1 vaso (200g)', carbs: 10.0, protein: 8.0, fat: 3.0, calories: 100.0),
  FoodItem(name: 'Galletas de sal', portion: '4 galletas pequeñas', carbs: 10.0, protein: 1.0, fat: 2.0, calories: 60.0),
  FoodItem(name: 'Sopa de verduras', portion: '1 plato hondo', carbs: 15.0, protein: 4.0, fat: 2.0, calories: 80.0),
];
