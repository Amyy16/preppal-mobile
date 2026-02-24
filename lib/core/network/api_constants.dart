/// API Constants for backend endpoints and configuration
class ApiConstants {
  static const String baseUrl = 'https://prepal-backend-p214-demosites.com';

  // ─── Authentication Endpoints ─────────────────────────
  static const String authRegister = '/api/v1/auth/register';
  static const String authLogin = '/api/v1/auth/login';
  static const String authVerifyEmail = '/api/v1/auth/verify-email';
  static const String authResendVerification =
      '/api/v1/auth/resend-verification-email';
  static const String authForgotPassword = '/api/v1/auth/forgot-password';
  static const String authResetPassword = '/api/v1/auth/reset-password';

  // ─── Business Endpoints ──────────────────────────────
  static const String businessRegister = '/api/v1/business/business-register';
  static const String businessGetAll =
      '/api/v1/business/get-all-user-businesses';
  static const String businessGetById =
      '/api/v1/business/get-businesses-by-id';
  static const String businessUpdate = '/api/v1/business/update-user-custom';
  static const String businessDelete = '/api/v1/business/delete-a-business';

  // ─── Sales Endpoints ────────────────────────────────
  static const String salesSubmit = '/api/v1/sales/daily-sales-entry';
  static const String salesGetAll = '/api/v1/sales/get-all-daily-sales';
  static const String salesGetReport = '/api/v1/sales/get-daily-sales-report';
  static const String salesUpdate = '/api/v1/sales/update-daily-sales';
  static const String salesDelete = '/api/v1/sales/delete-daily-sales';

  // ─── Timeouts ───────────────────────────────────────
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}
