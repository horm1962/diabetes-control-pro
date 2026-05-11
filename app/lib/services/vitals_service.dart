import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart';
import 'app_config.dart';

class VitalsService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<dynamic> _logs = [];

  bool _isLoading = false;

  VitalsService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  List<dynamic> get logs => _logs;
  bool get isLoading => _isLoading;

  Future<void> fetchLogs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/vitals'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        _logs = json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching vitals logs: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVitalSign({
    required int systolic,
    required int diastolic,
    int? heartRate,
    String? notes,
  }) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/vitals'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({
          'systolic': systolic,
          'diastolic': diastolic,
          if (heartRate != null) 'heartRate': heartRate,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        await fetchLogs();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al registrar signos vitales';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error adding vital sign: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
