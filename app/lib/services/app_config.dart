class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://diabetes-control-pro-production.up.railway.app',
  );
}
