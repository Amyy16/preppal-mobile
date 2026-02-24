import 'package:flutter/material.dart';
import 'package:prepal2/core/di/service_locator.dart';

enum BusinessStatus { initial, loading, registered, error, success }

class BusinessProvider extends ChangeNotifier {
  BusinessStatus _status = BusinessStatus.initial;
  String? _errorMessage;

  BusinessStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == BusinessStatus.loading;

  /// Register business details
  Future<bool> registerBusiness({
    required String businessName,
    required String businessType,
    required String contactNumber,
    required String? contactAddress,
    required String? website,
  }) async {
    _status = BusinessStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final businessDataSource = serviceLocator.businessRemoteDataSource;
      
      // Call backend API to register business
      final response = await businessDataSource.registerBusiness(
        businessName: businessName,
        businessType: businessType,
        contactNumber: contactNumber,
        contactAddress: contactAddress ?? '',
        website: website ?? '',
      );

      _status = BusinessStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _status = BusinessStatus.error;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _cleanError(Object e) {
    return e.toString().replaceAll('Exception: ', '');
  }
}
