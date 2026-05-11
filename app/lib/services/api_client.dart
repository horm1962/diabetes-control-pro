import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiClient {
  final AuthService _authService;
  static const _timeout = Duration(seconds: 15);

  ApiClient(this._authService);

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final finalHeaders = headers ?? _authService.getAuthHeaders();
    debugPrint('[HTTP GET] $url');
    final authHeader = finalHeaders['Authorization'];
    if (authHeader != null && authHeader.length >= 15) {
      debugPrint('[HTTP Auth] ${authHeader.substring(0, 15)}...');
    } else {
      debugPrint('[HTTP Auth] $authHeader');
    }
    final response = await http.get(url, headers: finalHeaders).timeout(_timeout);
    return _checkUnauthorized(response);
  }

  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final finalHeaders = headers ?? _authService.getAuthHeaders();
    debugPrint('[HTTP POST] $url');
    final authHeader = finalHeaders['Authorization'];
    if (authHeader != null && authHeader.length >= 15) {
      debugPrint('[HTTP Auth] ${authHeader.substring(0, 15)}...');
    } else {
      debugPrint('[HTTP Auth] $authHeader');
    }
    final response = await http.post(url, headers: finalHeaders, body: body).timeout(_timeout);
    return _checkUnauthorized(response);
  }

  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body}) async {
    final finalHeaders = headers ?? _authService.getAuthHeaders();
    debugPrint('[HTTP PUT] $url');
    final response = await http.put(url, headers: finalHeaders, body: body).timeout(_timeout);
    return _checkUnauthorized(response);
  }

  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body}) async {
    final finalHeaders = headers ?? _authService.getAuthHeaders();
    debugPrint('[HTTP PATCH] $url');
    final response = await http.patch(url, headers: finalHeaders, body: body).timeout(_timeout);
    return _checkUnauthorized(response);
  }

  Future<http.Response> delete(Uri url, {Map<String, String>? headers}) async {
    final finalHeaders = headers ?? _authService.getAuthHeaders();
    debugPrint('[HTTP DELETE] $url');
    final response = await http.delete(url, headers: finalHeaders).timeout(_timeout);
    return _checkUnauthorized(response);
  }

  Future<http.Response> _checkUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      await _authService.logout();
    }
    return response;
  }
}
