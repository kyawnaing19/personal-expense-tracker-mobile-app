class ApiConstants {
  // static const String baseUrl = 'http://192.168.20.161:8000/api/v1';
  static const String baseUrl = 'http://118.27.151.110/api/v1';
  
  // Auth
  static const String googleLogin = '/auth/google';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Categories Endpoints
  static const String categories = '/categories';

  // Transactions Endpoints 
  static const String transactions = '/transactions';
  static const String updateFcmToken = "http://118.27.151.110/api/v1/auth/fcm-token";

  static const String analytics = '/reports/category-breakdown';

  // Budgets Endpoints
static const String budgets = '/budgets';
static const String budgetsOverview = '/reports/budgets-overview';
}