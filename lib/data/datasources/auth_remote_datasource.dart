import 'dart:convert';
import 'package:prepal2/core/network/api_client.dart';
import 'package:prepal2/core/network/api_constants.dart';

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

/// Implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authSignup,
      body: {
        'email': email,
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json;
    } else {
      throw Exception('Signup failed: ${response.body}');
    }
  }

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authLogin,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json['token'] != null) {
        await _apiClient.setAuthToken(json['token']);
      }

      return json;
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authVerifyEmail,
      body: {
        'email': email,
        'code': code, // change to 'otp' if backend expects otp
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Email verification failed: ${response.body}');
    }
  }

  @override
  Future<void> resendVerificationEmail(String email) async {
    final response = await _apiClient.post(
      ApiConstants.authResendVerification,
      body: {
        'email': email,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Resend verification failed: ${response.body}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiConstants.authForgotPassword,
      body: {
        'email': email,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Forgot password failed: ${response.body}');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.authResetPassword,
      body: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Reset password failed: ${response.body}');
    }
  }
}