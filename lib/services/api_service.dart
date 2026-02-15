import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../models/inventory_item.dart';
import '../models/waste_log.dart';

class ApiService {
  // Configuration
  static const String baseUrl = 'http://localhost:5000'; // Change this to your backend URL
  static const Duration timeout = Duration(seconds: 30);

  // Token storage
  static String? _authToken;

  /// Get the authentication token
  static String? get authToken => _authToken;

  /// Set the authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear the authentication token (logout)
  static void clearAuthToken() {
    _authToken = null;
  }

  // ============ AUTHENTICATION ============

  /// Login with email and password
  /// Returns: {token: String, user: {id, email, businessName}}
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Mock delay to simulate network request
      await Future.delayed(const Duration(milliseconds: 800));

      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw ApiException('Email and password are required');
      }

      // Mock authentication logic
      if (!email.contains('@')) {
        throw ApiException('Invalid email format');
      }

      // Simulate successful login
      final mockToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
      _authToken = mockToken;

      return {
        'success': true,
        'token': mockToken,
        'user': {
          'id': 'user_123',
          'email': email,
          'businessName': email.split('@')[0],
        },
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Register new user
  /// Returns: {token: String, user: {id, email, businessName}}
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String businessName,
    required String phoneNumber,
    required String countryCode,
  }) async {
    try {
      // Mock delay to simulate network request
      await Future.delayed(const Duration(milliseconds: 1000));

      // Validation
      if (email.isEmpty ||
          password.isEmpty ||
          businessName.isEmpty ||
          phoneNumber.isEmpty) {
        throw ApiException('All fields are required');
      }

      if (!email.contains('@')) {
        throw ApiException('Invalid email format');
      }

      if (password.length < 8) {
        throw ApiException('Password must be at least 8 characters');
      }

      // Simulate successful registration
      final mockToken = 'token_${DateTime.now().millisecondsSinceEpoch}';
      _authToken = mockToken;

      return {
        'success': true,
        'token': mockToken,
        'user': {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'email': email,
          'businessName': businessName,
          'phoneNumber': '$countryCode$phoneNumber',
        },
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout user
  static Future<void> logout() async {
    try {
      _authToken = null;
      // In real API: await http.post('$baseUrl/auth/logout', headers: _getHeaders());
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 600));

      // Validation
      if (currentPassword.isEmpty || newPassword.isEmpty) {
        throw ApiException('Passwords are required');
      }

      if (newPassword != confirmPassword) {
        throw ApiException('New passwords do not match');
      }

      if (newPassword.length < 8) {
        throw ApiException('Password must be at least 8 characters');
      }

      return {'success': true, 'message': 'Password changed successfully'};
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get user account information
  static Future<Map<String, dynamic>> getAccount() async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Return mock user data
      return {
        'success': true,
        'user': {
          'id': 'user_123',
          'email': 'user@example.com',
          'businessName': 'My Business',
          'phoneNumber': '+234 XXX XXX XXXX',
          'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'notificationsEnabled': true,
          'expiryAlerts': true,
          'wasteReminders': true,
        },
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update account information
  static Future<Map<String, dynamic>> updateAccount({
    String? businessName,
    String? phoneNumber,
    bool? notificationsEnabled,
    bool? expiryAlerts,
    bool? wasteReminders,
  }) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 600));

      return {
        'success': true,
        'message': 'Account updated successfully',
        'user': {
          'businessName': businessName,
          'phoneNumber': phoneNumber,
          'notificationsEnabled': notificationsEnabled,
          'expiryAlerts': expiryAlerts,
          'wasteReminders': wasteReminders,
        },
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete user account
  static Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Validation
      if (password.isEmpty) {
        throw ApiException('Password is required to delete account');
      }

      // Clear token after deletion
      _authToken = null;

      return {
        'success': true,
        'message': 'Account deleted successfully',
      };
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ INVENTORY ============

  /// Get all inventory items for user
  static Future<List<InventoryItem>> getInventoryItems() async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data - in real app, parse from API response
      return [
        InventoryItem(
          id: 'inv_1',
          name: 'Tomatoes',
          category: 'Vegetables',
          quantity: 5,
          unit: 'kg',
          expiryDate: DateTime.now().add(const Duration(days: 3)),
          dateAdded: DateTime.now().subtract(const Duration(days: 2)),
          costPerUnit: 2.5,
          notes: 'Fresh from market',
        ),
      ];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Add inventory item
  static Future<InventoryItem> addInventoryItem({
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required DateTime expiryDate,
    required double costPerUnit,
    String? notes,
  }) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 700));

      final item = InventoryItem(
        id: 'inv_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
        dateAdded: DateTime.now(),
        costPerUnit: costPerUnit,
        notes: notes,
      );

      return item;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete inventory item
  static Future<void> deleteInventoryItem(String itemId) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 400));

      // In real API: await http.delete('$baseUrl/inventory/$itemId', headers: _getHeaders());
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Update inventory item
  static Future<InventoryItem> updateInventoryItem({
    required String itemId,
    required String name,
    required String category,
    required double quantity,
    required String unit,
    required DateTime expiryDate,
    required double costPerUnit,
    String? notes,
  }) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 700));

      return InventoryItem(
        id: itemId,
        name: name,
        category: category,
        quantity: quantity,
        unit: unit,
        expiryDate: expiryDate,
        dateAdded: DateTime.now(),
        costPerUnit: costPerUnit,
        notes: notes,
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ WASTE LOGGING ============

  /// Get all waste logs
  static Future<List<WasteLog>> getWasteLogs() async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 500));

      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Log waste
  static Future<WasteLog> logWaste({
    required String itemName,
    required String category,
    required double quantity,
    required String unit,
    required String reason,
    required double costLost,
    String? notes,
  }) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 700));

      final wasteLog = WasteLog(
        id: 'waste_${DateTime.now().millisecondsSinceEpoch}',
        itemName: itemName,
        category: category,
        quantity: quantity,
        unit: unit,
        reason: reason,
        costLost: costLost,
        dateLogged: DateTime.now(),
        notes: notes,
      );

      return wasteLog;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete waste log
  static Future<void> deleteWasteLog(String wasteId) async {
    try {
      _checkAuth();

      // Mock delay
      await Future.delayed(const Duration(milliseconds: 400));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ============ HELPER METHODS ============

  /// Check if user is authenticated
  static void _checkAuth() {
    if (_authToken == null) {
      throw ApiException('User not authenticated. Please login first.');
    }
  }

  /// Get request headers with auth token
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  /// Handle errors
  static ApiException _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }

    if (error is http.ClientException) {
      return ApiException('Network error: ${error.message}');
    }

    if (error is TimeoutException) {
      return ApiException('Request timeout. Please try again.');
    }

    return ApiException('An error occurred: ${error.toString()}');
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
