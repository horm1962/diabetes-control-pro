import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart';
import 'app_config.dart';

class LabResultsService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<dynamic> _logs = [];

  bool _isLoading = false;

  LabResultsService(this._authService);

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
        Uri.parse('$_baseUrl/lab-results'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        _logs = json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching lab results: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addLabResult({
    double? hba1c,
    double? cholesterolResult,
    double? triglycerides,
    double? creatinine,
    double? hemoglobin,
    double? urea,
    double? cystatinC,
    String? notes,
  }) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/lab-results'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({
          if (hba1c != null) 'hba1c': hba1c,
          if (cholesterolResult != null) 'cholesterolResult': cholesterolResult,
          if (triglycerides != null) 'triglycerides': triglycerides,
          if (creatinine != null) 'creatinine': creatinine,
          if (hemoglobin != null) 'hemoglobin': hemoglobin,
          if (urea != null) 'urea': urea,
          if (cystatinC != null) 'cystatinC': cystatinC,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        await fetchLogs();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al registrar resultados de laboratorio';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error adding lab result: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
