import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'api_constants.dart';

/// HTTP Client for API communication with token management
class ApiClient {
  final http.Client httpClient;
  late SharedPreferences _prefs;
  String? _authToken;

  ApiClient({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  /// Initialize SharedPreferences and restore saved token
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _authToken = _prefs.getString('auth_token');
  }

  /// Set auth token (called after successful login)
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _prefs.setString('auth_token', token);
  }

  /// Get current auth token
  String? getAuthToken() => _authToken;

  /// Clear auth token (called on logout)
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _prefs.remove('auth_token');
  }

  /// Check if user is authenticated
  bool isAuthenticated() => _authToken != null;

  /// Build headers for HTTP requests
  Map<String, String> _getHeaders({bool isFormData = false}) {
    final headers = <String, String>{
      'Content-Type': isFormData
          ? 'application/x-www-form-urlencoded'
          : 'application/json',
    };

    // Add auth token if available
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// GET request
  Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await httpClient
          .get(url, headers: _getHeaders())
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      _logResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<http.Response> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool isFormData = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      String bodyString;
      if (isFormData) {
        bodyString = body.entries
            .map((e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
      } else {
        bodyString = jsonEncode(body);
      }

      final response = await httpClient
          .post(
            url,
            headers: _getHeaders(isFormData: isFormData),
            body: bodyString,
          )
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      _logResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(
    String endpoint, {
    required Map<String, dynamic> body,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await httpClient
          .put(
            url,
            headers: _getHeaders(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      _logResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await httpClient
          .delete(url, headers: _getHeaders())
          .timeout(const Duration(seconds: ApiConstants.connectionTimeout));

      _logResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Log API responses for debugging
  void _logResponse(http.Response response) {
    // Only log in debug mode
    if (response.statusCode >= 400) {
      print('❌ API Error ${response.statusCode}: ${response.body}');
    } else {
      print('✅ API Success ${response.statusCode}');
    }
  }
}
