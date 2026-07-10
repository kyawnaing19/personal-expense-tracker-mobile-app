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
  static const String annualSummary = '/reports/annual-summary';

  // Budgets Endpoints
  static const String budgets = '/budgets';
  static const String budgetsOverview = '/reports/budgets-overview';

  static const String recurringTransactions = '/recurring-transactions';

  // recurring transaction rules, plus their accept/reject actions.
  static const String transactionsRecurring = '/transactions-recurring';
  static String acceptTransaction(String id) => '/transactions/$id/accept';
  static String rejectTransaction(String id) => '/transactions/$id/reject';
 

  // Groups Endpoints
  static const String groups = '/groups';
  static String groupDetail(String id) => '/groups/$id';
  static String groupMembers(String id) => '/groups/$id/members';
  static String groupMember(String id, String userId) =>'/groups/$id/members/$userId';
  static String groupJoinCode(String id) => '/groups/$id/join-code';
  static const String groupJoin = '/groups/join';

}