import 'package:prepal2/core/network/api_client.dart';
import 'dart:convert';

abstract class BusinessRemoteDataSource {
  /// POST /api/v1/business/business-register
  /// Register a new business
  Future<Map<String, dynamic>> registerBusiness({
    required String businessName,
    required String businessType,
    required String contactAddress,
    required String contactNumber,
    String? website,
  });

  /// GET /api/v1/business/get-all-user-businesses
  /// Get all businesses for current user
  Future<List<Map<String, dynamic>>> getAllUserBusinesses();

  /// GET /api/v1/business/get-businesses-by-id/{id}
  /// Get specific business by ID
  Future<Map<String, dynamic>> getBusinessById(String businessId);

  /// PUT /api/v1/business/update-user-custom/{id}
  /// Update business details
  Future<Map<String, dynamic>> updateBusiness({
    required String businessId,
    required Map<String, dynamic> updates,
  });

  /// DELETE /api/v1/business/delete-a-business/{id}
  /// Delete a business
  Future<void> deleteBusiness(String businessId);
}

class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  final ApiClient _apiClient;

  BusinessRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> registerBusiness({
    required String businessName,
    required String businessType,
    required String contactAddress,
    required String contactNumber,
    String? website,
  }) async {
    try {
      final body = {
        'business_name': businessName,
        'business_type': businessType,
        'contact_address': contactAddress,
        'contact_number': contactNumber,
        if (website != null) 'website': website,
      };

      final response = await _apiClient.post(
        '/api/v1/business/business-register',
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? jsonResponse;
      } else {
        throw Exception('Failed to register business: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUserBusinesses() async {
    try {
      final response = await _apiClient.get(
        '/api/v1/business/get-all-user-businesses',
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> businesses = jsonResponse['data'] ?? [];
        return businesses.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get businesses: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getBusinessById(String businessId) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/business/get-businesses-by-id/$businessId',
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? jsonResponse;
      } else {
        throw Exception('Failed to get business: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateBusiness({
    required String businessId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/business/update-user-custom/$businessId',
        body: updates,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? jsonResponse;
      } else {
        throw Exception('Failed to update business: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteBusiness(String businessId) async {
    try {
      final response = await _apiClient.delete(
        '/api/v1/business/delete-a-business/$businessId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete business: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
