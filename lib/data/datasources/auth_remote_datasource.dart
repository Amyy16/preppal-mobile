import 'package:prepal2/core/network/api_client.dart';
import 'package:prepal2/core/network/api_constants.dart';
import 'dart:convert';

/// Abstract interface for authentication remote data source
abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  });

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });

  Future<void> verifyEmail({
    required String email,
    required String code,
  });

  Future<void> resendVerificationEmail(String email);
  Future<void> forgotPassword(String email);

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  });
}

/// Implementation of authentication remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authRegister,
        body: {
          'email': email,
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? {};
      } else {
        throw Exception('Register failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authLogin,
        body: {
          'email': email,
          'password': password,
        },
        isFormData: true,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Save token in ApiClient for future requests
        if (json['data']['token'] != null) {
          await _apiClient.setAuthToken(json['data']['token']);
        }
        return json['data'] ?? {};
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authVerifyEmail,
        body: {
          'email': email,
          'code': code,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Email verification failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authResendVerification,
        body: {
          'email': email,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Resend verification failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authForgotPassword,
        body: {
          'email': email,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Forgot password request failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.authResetPassword,
        body: {
          'email': email,
          'token': token,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Password reset failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
