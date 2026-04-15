import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/activity_log.dart';
import 'auth_service.dart';
import 'app_config.dart';

class ActivityService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<ActivityLog> _logs = [];

  ActivityService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  List<ActivityLog> get logs => _logs;

  Future<void> fetchLogs() async {
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/activity'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logs = data.map((json) => ActivityLog.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching activity logs: $e');
    }
  }

  Future<bool> addLog({
    required String activityType,
    required int durationMinutes,
    required ActivityIntensity intensity,
    int? caloriesBurned,
    required DateTime timestamp,
    String? notes,
  }) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/activity'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({
          'activityType': activityType,
          'durationMinutes': durationMinutes,
          'intensity': intensity.name,
          'caloriesBurned': caloriesBurned,
          'timestamp': timestamp.toIso8601String(),
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final newLog = ActivityLog.fromJson(json.decode(response.body));
        _logs.insert(0, newLog);
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al registrar actividad';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error adding activity log: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
