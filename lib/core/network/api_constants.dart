class ApiConstants {
  ApiConstants._(); // prevents creating an instance

  static const String baseUrl = 'https://prepal-backend-px1d.onrender.com';

  // ─── Authentication Endpoints ─────────────────────────
  static const String authSignup = '/api/v1/auth/signup';
  static const String authLogin = '/api/v1/auth/login';
  static const String authVerifyEmail = '/api/v1/auth/verify-email';
  static const String authResendVerification = '/api/v1/auth/resend-verification';
  static const String authForgotPassword = '/api/v1/auth/forgot-password';
  static const String authResetPassword = '/api/v1/auth/reset-password';

  // ─── Business Endpoints (from your backend doc) ───────
  static const String businessCreate = '/api/v1/business/create';
  static const String businessGetAll = '/api/v1/businesses';
  static const String businessGetById = '/api/v1/businesses/'; // + id
  static const String businessUpdate = '/api/v1/businesses/update/'; // + id
  static const String businessDelete = '/api/v1/businesses/'; // + id

  // ─── Daily Sales (based on doc) ───────────────────────
  static const String dailySales = '/api/v1/daily-sales';
  static const String dailySalesById = '/api/v1/daily-sales/'; // + id
  static const String dailySalesUpdate = '/api/v1/daily-sales/update/'; // + id

  // ─── Inventory ───────────────────────────────────────
  static const String inventory = '/api/v1/inventory';

  // ─── Timeouts (seconds) ──────────────────────────────
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;
}