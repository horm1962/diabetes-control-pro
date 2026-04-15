import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart';
import 'app_config.dart';

class TreatmentService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<dynamic> _logs = [];

  TreatmentService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  List<dynamic> get logs => _logs;
  
  bool get hasDataToday {
    if (_logs.isEmpty) return false;
    final now = DateTime.now();
    return _logs.any((log) {
      final ts = DateTime.tryParse(log['timestamp'] ?? log['createdAt'] ?? '');
      if (ts == null) return false;
      return ts.year == now.year && ts.month == now.month && ts.day == now.day;
    });
  }

  Future<void> fetchLogs() async {
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/treatment'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        _logs = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching treatment logs: $e');
    }
  }

  Future<bool> addTreatment({
    required String type,
    required String medicationName,
    required double dosage,
    String? unit,
    String? notes,
  }) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/treatment'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({
          'type': type,
          'medicationName': medicationName,
          'dosage': dosage,
          'unit': unit,
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        await fetchLogs(); // Refresh the list
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al registrar tratamiento';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error adding treatment log: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
