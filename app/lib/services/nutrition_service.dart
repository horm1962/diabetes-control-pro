import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/nutrition_log.dart';
import 'auth_service.dart';
import 'app_config.dart';

class NutritionService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<NutritionLog> _logs = [];

  bool _isLoading = false;

  NutritionService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  List<NutritionLog> get logs => _logs;
  bool get isLoading => _isLoading;

  Future<void> fetchLogs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/nutrition'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logs = data.map((json) => NutritionLog.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching nutrition logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLog({
    required MealType mealType,
    double? carbsG,
    double? proteinG,
    double? fatG,
    int? calories,
    String? notes,
    required DateTime timestamp,
  }) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/nutrition'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({
          'mealType': mealType.name,
          'carbsG': carbsG,
          'proteinG': proteinG,
          'fatG': fatG,
          'calories': calories,
          'notes': notes,
          'timestamp': timestamp.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final newLog = NutritionLog.fromJson(json.decode(response.body));
        _logs.insert(0, newLog);
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al registrar nutrición';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error adding nutrition log: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
