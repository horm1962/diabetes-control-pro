import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import '../models/glucose_log.dart';
import 'auth_service.dart';
import 'app_config.dart';

class GlucoseService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<GlucoseLog> _logs = [];
  GlucoseLog? _latestLog;

  GlucoseService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  List<GlucoseLog> get logs => _logs;
  GlucoseLog? get latestLog => _latestLog;

  bool get hasDataToday {
    if (_logs.isEmpty) return false;
    final now = DateTime.now();
    return _logs.any((log) =>
        log.timestamp.year == now.year &&
        log.timestamp.month == now.month &&
        log.timestamp.day == now.day);
  }

  Map<String, dynamic> calculateTIR(double low, double high) {
    if (_logs.isEmpty) return {'in_range': 0.0, 'high': 0.0, 'low': 0.0, 'total_logs': 0, 'low_episodes': 0, 'high_episodes': 0};

    int inRangeCount = 0;
    int highCount = 0;
    int lowCount = 0;

    for (var log in _logs) {
      if (log.value < low) {
        lowCount++;
      } else if (log.value > high) {
        highCount++;
      } else {
        inRangeCount++;
      }
    }

    int total = _logs.length;
    return {
      'in_range': (inRangeCount / total) * 100,
      'high': (highCount / total) * 100,
      'low': (lowCount / total) * 100,
      'total_logs': total,
      'low_episodes': lowCount,
      'high_episodes': highCount,
    };
  }

  String getInsight(double low, double high) {
    final tir = calculateTIR(low, high);
    if (tir['total_logs'] == 0) return 'Comienza a registrar para ver insights.';
    
    if (tir['low_episodes'] > 2) {
      return 'Hoy hubo ${tir['low_episodes']} episodios de baja; revisa tu comida o actividad.';
    }
    if (tir['high_episodes'] > 3) {
      return 'Niveles altos detectados (${tir['high_episodes']} veces). Considera ajustar tu hidratación o medicación.';
    }
    if (tir['in_range'] > 70) {
      return '¡Excelente! Estás en nivel ideal el ${tir['in_range'].toStringAsFixed(0)}% del tiempo.';
    }
    return 'Mantén la constancia en tus registros para mejorar el control.';
  }

  Future<void> fetchLogs() async {
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/glucose'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _logs = data.map((json) => GlucoseLog.fromJson(json)).toList();
        if (_logs.isNotEmpty) {
          _latestLog = _logs.first;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching logs: $e');
    }
  }

  Future<void> fetchLatestLog() async {
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/glucose/latest'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        _latestLog = GlucoseLog.fromJson(json.decode(response.body));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching latest log: $e');
    }
  }

  Future<bool> addLog(double value, GlucoseContext context, DateTime timestamp, String? notes) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/glucose'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({
          'value': value,
          'context': GlucoseLog.mapContextToJson(context),
          'timestamp': timestamp.toIso8601String(),
          'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        final newLog = GlucoseLog.fromJson(json.decode(response.body));
        _logs.insert(0, newLog);
        _latestLog = newLog;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al guardar el registro';
        if (data['message'] != null) {
          if (data['message'] is List) {
            errorMsg = (data['message'] as List).join(', ');
          } else {
            errorMsg = data['message'].toString();
          }
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error adding log: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
