import 'package:prepal2/core/network/api_client.dart';
import 'package:prepal2/data/datasources/auth_remote_datasource.dart';
import 'package:prepal2/data/datasources/business_remote_datasource.dart';
import 'package:prepal2/data/datasources/daily_sales_remote_datasource.dart';

/// Service Locator (Dependency Injection Container)
/// Simple singleton pattern - no external DI library needed
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();

  factory ServiceLocator() {
    return _instance;
  }

  ServiceLocator._internal();

  // Singleton instances
  late ApiClient _apiClient;
  late AuthRemoteDataSource _authRemoteDataSource;
  late BusinessRemoteDataSource _businessRemoteDataSource;
  late DailySalesRemoteDataSource _dailySalesRemoteDataSource;

  /// Initialize all services
  /// Call this in main() before runApp()
  Future<void> init() async {
    // Initialize API Client first
    _apiClient = ApiClient();
    await _apiClient.init();

    // Initialize Remote Data Sources
    _authRemoteDataSource = AuthRemoteDataSourceImpl(_apiClient);
    _businessRemoteDataSource = BusinessRemoteDataSourceImpl(_apiClient);
    _dailySalesRemoteDataSource = DailySalesRemoteDataSourceImpl(_apiClient);
  }

  /// Get API Client instance
  ApiClient get apiClient => _apiClient;

  /// Get Auth Remote Data Source
  AuthRemoteDataSource get authRemoteDataSource => _authRemoteDataSource;

  /// Get Business Remote Data Source
  BusinessRemoteDataSource get businessRemoteDataSource =>
      _businessRemoteDataSource;

  /// Get Daily Sales Remote Data Source
  DailySalesRemoteDataSource get dailySalesRemoteDataSource =>
      _dailySalesRemoteDataSource;
}

/// Global instance for easy access
final serviceLocator = ServiceLocator();

/// Setup dependency injection
/// Call this in main() BEFORE runApp()
Future<void> setupServiceLocator() async {
  await serviceLocator.init();
}
