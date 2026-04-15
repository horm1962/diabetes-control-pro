import '../models/activity_log.dart';

class ActivityItem {
  final String name;
  final double mets;
  final ActivityIntensity defaultIntensity;

  const ActivityItem({
    required this.name,
    required this.mets,
    required this.defaultIntensity,
  });
}

const List<ActivityItem> activityDatabase = [
  ActivityItem(name: 'Caminar (ritmo ligero)', mets: 3.0, defaultIntensity: ActivityIntensity.low),
  ActivityItem(name: 'Caminar rápido (ejercicio)', mets: 4.5, defaultIntensity: ActivityIntensity.medium),
  ActivityItem(name: 'Correr (trotar ligero)', mets: 7.0, defaultIntensity: ActivityIntensity.high),
  ActivityItem(name: 'Correr rápido', mets: 10.0, defaultIntensity: ActivityIntensity.high),
  ActivityItem(name: 'Bicicleta estática (suave)', mets: 5.5, defaultIntensity: ActivityIntensity.low),
  ActivityItem(name: 'Bicicleta estática (intensa)', mets: 8.0, defaultIntensity: ActivityIntensity.high),
  ActivityItem(name: 'Ciclismo al aire libre (paseo)', mets: 6.0, defaultIntensity: ActivityIntensity.medium),
  ActivityItem(name: 'Natación (estilo libre suave)', mets: 6.0, defaultIntensity: ActivityIntensity.medium),
  ActivityItem(name: 'Natación (intensa)', mets: 10.0, defaultIntensity: ActivityIntensity.high),
  ActivityItem(name: 'Yoga / Estiramientos', mets: 2.5, defaultIntensity: ActivityIntensity.low),
  ActivityItem(name: 'Pilates', mets: 3.0, defaultIntensity: ActivityIntensity.low),
  ActivityItem(name: 'Ejercicios de fuerza (pesas)', mets: 3.5, defaultIntensity: ActivityIntensity.medium),
  ActivityItem(name: 'Bailar (zumba, aeróbicos)', mets: 6.5, defaultIntensity: ActivityIntensity.medium),
  ActivityItem(name: 'Limpieza de casa (barrer, trapear)', mets: 3.5, defaultIntensity: ActivityIntensity.low),
  ActivityItem(name: 'Subir escaleras', mets: 8.0, defaultIntensity: ActivityIntensity.high),
  ActivityItem(name: 'Fútbol', mets: 7.0, defaultIntensity: ActivityIntensity.high),
  ActivityItem(name: 'Tenis', mets: 7.3, defaultIntensity: ActivityIntensity.high),
];
