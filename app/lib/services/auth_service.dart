import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

import '../models/user_profile.dart';
import 'app_config.dart';

class AuthService with ChangeNotifier {
  static String get _baseUrl => AppConfig.baseUrl;
  static const _secureStorage = FlutterSecureStorage();
  String? _token;
  User? _user;
  UserProfile? _profile;

  User? get user => _user;
  UserProfile? get profile => _profile;
  bool get isAuthenticated => _token != null;
  bool _isNewRegistration = false;
  bool get isNewRegistration => _isNewRegistration;
  set isNewRegistration(bool value) {
    _isNewRegistration = value;
    notifyListeners();
  }

  AuthService() {
    _loadStoredToken();
  }

  Future<void> _loadStoredToken() async {
    _token = await _secureStorage.read(key: 'access_token');

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    final profileJson = prefs.getString('user_profile');

    if (userJson != null) {
      _user = User.fromJson(json.decode(userJson));
    }

    if (profileJson != null) {
      _profile = UserProfile.fromJson(json.decode(profileJson));
    }

    if (_token == 'null' || (_token?.isEmpty ?? true)) {
      _token = null;
    }
    if (_user != null) {
      notifyListeners();
      await fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    if (_token == null) return;
    try {
      final response = await ApiClient(this).get(
        Uri.parse('$_baseUrl/users/profile'),
        headers: getAuthHeaders(),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = json.decode(response.body);
        if (data != null) {
          _profile = UserProfile.fromJson(data);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_profile', response.body);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    try {
      final response = await ApiClient(this).post(
        Uri.parse('$_baseUrl/users/profile'),
        headers: getAuthHeaders(),
        body: json.encode(profile.toJson()),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 201 || response.statusCode == 200) {
        _profile = UserProfile.fromJson(json.decode(response.body));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile', response.body);
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error al actualizar el perfil';
        if (data['message'] != null) {
          errorMsg = data['message'] is List ? (data['message'] as List).join(', ') : data['message'].toString();
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiClient(this).post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _user = User.fromJson(data['user']);

        await _secureStorage.write(key: 'access_token', value: _token!);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(data['user']));
        _isNewRegistration = false;
        
        // Cargar perfil inmediatamente
        await fetchProfile();
        
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Credenciales inválidas');
      }
    } catch (e) {
      debugPrint('Error en login: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> register(String email, String password, {UserRole role = UserRole.patient}) async {
    try {
      final response = await ApiClient(this).post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'role': role.toString().split('.').last,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _token = data['access_token'];
        _user = User.fromJson(data['user']);

        await _secureStorage.write(key: 'access_token', value: _token!);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(data['user']));
        _isNewRegistration = true;
        _profile = null;
        notifyListeners();
        return true;
      } else {
        final data = json.decode(response.body);
        String errorMsg = 'Error desconocido en el servidor';
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
      debugPrint('Error en registro: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _profile = null;
    await _secureStorage.delete(key: 'access_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    await prefs.remove('user_profile');
    notifyListeners();
  }

  Map<String, String> getAuthHeaders() {
    // Si no hay token, no deberíamos intentar enviar cabeceras de autorización
    if (_token == null || _token!.isEmpty || _token == 'null') {
      debugPrint('[AuthService] ADVERTENCIA: Intentando obtener cabeceras sin token válido');
      return {
        'Content-Type': 'application/json',
      };
    }
    
    // Asegurarse de que el token no tenga espacios o saltos de línea accidentales
    final cleanToken = _token!.trim();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanToken',
    };
  }
}
