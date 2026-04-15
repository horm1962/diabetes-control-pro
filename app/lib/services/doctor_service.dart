import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'auth_service.dart';
import 'app_config.dart';

class DoctorService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  AuthService _authService;
  List<dynamic> _patients = [];
  bool _isLoading = false;

  DoctorService(this._authService);

  void updateAuth(AuthService authService) {
    _authService = authService;
  }

  List<dynamic> get patients => _patients;
  bool get isLoading => _isLoading;

  /// Médico: lista sus pacientes vinculados
  Future<void> fetchMyPatients() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/doctor/patients'),
        headers: _authService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        _patients = json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching patients: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Médico: obtener resumen clínico de un paciente
  Future<Map<String, dynamic>?> fetchPatientSummary(String patientId) async {
    try {
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/doctor/patient/$patientId/summary'),
        headers: _authService.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error fetching patient summary: $e');
    }
    return null;
  }

  /// Paciente: busca un médico por su correo
  Future<Map<String, dynamic>?> searchDoctorByEmail(String email) async {
    try {
      final encoded = Uri.encodeComponent(email);
      final response = await ApiClient(_authService).get(
        Uri.parse('$_baseUrl/doctor/search/$encoded'),
        headers: _authService.getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error searching doctor: $e');
    }
    return null;
  }

  /// Paciente: vincula al médico encontrado
  Future<bool> linkDoctor(String doctorId) async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/users/profile/link-doctor'),
        headers: _authService.getAuthHeaders(),
        body: json.encode({'doctorId': doctorId}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error desconocido');
      }
    } catch (e) {
      debugPrint('Error linking doctor: $e');
      throw Exception(e.toString());
    }
  }

  /// Paciente: desvincula al médico
  Future<bool> unlinkDoctor() async {
    try {
      final response = await ApiClient(_authService).post(
        Uri.parse('$_baseUrl/users/profile/unlink-doctor'),
        headers: _authService.getAuthHeaders(),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error unlinking doctor: $e');
      return false;
    }
  }
}
