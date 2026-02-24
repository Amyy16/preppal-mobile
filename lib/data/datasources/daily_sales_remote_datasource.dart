import 'package:prepal2/core/network/api_client.dart';
import 'dart:convert';

abstract class DailySalesRemoteDataSource {
  /// POST /api/v1/sales/daily-sales-entry
  /// Submit daily sales data
  Future<Map<String, dynamic>> submitDailySales({
    required String businessId,
    required String date,
    required List<Map<String, dynamic>> salesData,
  });

  /// GET /api/v1/sales/get-all-daily-sales
  /// Get all daily sales records
  Future<List<Map<String, dynamic>>> getAllDailySales({
    String? businessId,
    String? startDate,
    String? endDate,
  });

  /// GET /api/v1/sales/get-daily-sales-report/{reportId}
  /// Get specific sales report
  Future<Map<String, dynamic>> getDailySalesReport(String reportId);

  /// PUT /api/v1/sales/update-daily-sales/{id}
  /// Update sales record
  Future<Map<String, dynamic>> updateDailySales({
    required String saleId,
    required Map<String, dynamic> updates,
  });

  /// DELETE /api/v1/sales/delete-daily-sales/{id}
  /// Delete sales record
  Future<void> deleteDailySales(String saleId);
}

class DailySalesRemoteDataSourceImpl implements DailySalesRemoteDataSource {
  final ApiClient _apiClient;

  DailySalesRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Map<String, dynamic>> submitDailySales({
    required String businessId,
    required String date,
    required List<Map<String, dynamic>> salesData,
  }) async {
    try {
      final body = {
        'business_id': businessId,
        'date': date,
        'sales_data': salesData,
      };

      final response = await _apiClient.post(
        '/api/v1/sales/daily-sales-entry',
        body: body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? jsonResponse;
      } else {
        throw Exception('Failed to submit sales: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllDailySales({
    String? businessId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String endpoint = '/api/v1/sales/get-all-daily-sales';
      
      final queryParams = <String, String>{};
      if (businessId != null) queryParams['business_id'] = businessId;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      if (queryParams.isNotEmpty) {
        final query = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        endpoint = '$endpoint?$query';
      }

      final response = await _apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> sales = jsonResponse['data'] ?? [];
        return sales.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to get sales: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getDailySalesReport(String reportId) async {
    try {
      final response = await _apiClient.get(
        '/api/v1/sales/get-daily-sales-report/$reportId',
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? jsonResponse;
      } else {
        throw Exception('Failed to get report: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateDailySales({
    required String saleId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/v1/sales/update-daily-sales/$saleId',
        body: updates,
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? jsonResponse;
      } else {
        throw Exception('Failed to update sales: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteDailySales(String saleId) async {
    try {
      final response = await _apiClient.delete(
        '/api/v1/sales/delete-daily-sales/$saleId',
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete sales: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
