import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart';
import 'app_config.dart';

class AppointmentsService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<dynamic> _appointments = [];

  AppointmentsService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  List<dynamic> get appointments => _appointments;

  Future<void> fetchAppointments() async {
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/appointments'),
        headers: _authService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        _appointments = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
  }

  Future<bool> addAppointment({
    required String title,
    required DateTime dateTime,
    String? specialty,
    String? doctorName,
    String? notes,
  }) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/appointments'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({
          'title': title,
          'dateTime': dateTime.toIso8601String(),
          if (specialty != null) 'specialty': specialty,
          if (doctorName != null) 'doctorName': doctorName,
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201) {
        await fetchAppointments();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al agendar cita';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error adding appointment: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    try {
      final response = await ApiClient(_authService).patch(
        Uri.parse('$_baseUrl/appointments/$id/status'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await fetchAppointments();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al actualizar estado de la cita';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error updating appointment status: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
