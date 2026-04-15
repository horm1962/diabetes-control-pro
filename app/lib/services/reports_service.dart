import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart';
import 'app_config.dart';

class ReportsService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  Map<String, dynamic>? _glucoseReport;

  ReportsService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  Map<String, dynamic>? get glucoseReport => _glucoseReport;

  Future<void> fetchGlucoseReport() async {
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/reports/glucose'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        _glucoseReport = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching glucose report: $e');
    }
  }
}
