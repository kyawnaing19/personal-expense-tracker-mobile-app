class ApiConstants {
  static const String baseUrl = 'https://api.shweeshaungexpensetracker.website/api/v1';
  
  // Auth
  static const String googleLogin = '/auth/google';
  static const String me = '/auth/me';
  static const String logout = '/auth/logout';

  // Categories Endpoints
  static const String categories = '/categories';

  // Transactions Endpoints
  static const String transactions = '/transactions';
  static const String updateFcmToken = "https://api.shweeshaungexpensetracker.website/api/v1/auth/fcm-token";

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

  // Group Expense endpoints
  static const String groupExpenses = '/group-expenses';
  static String groupExpenseDetail(String id) => '/group-expenses/$id';
  static String groupExpensesList(String groupId) =>'/groups/$groupId/expenses';
  

  //Group member balance
  static String groupBalance(String id) => '/groups/$id/balance';
  static String groupMemberBalanceDetails(String groupId, String userId) =>'/groups/$groupId/balance/$userId/details';

 
  // Settle Debt Endpoints 
  static const String mySplits = '/groups/expenses/splits';
  static String claimPayment(String splitId) =>'/expense-splits/$splitId/claim-payment';
 
// Settlement / Debt Requests endpoints
  static const String settlementRequests = '/settlement-requests';
  static String confirmSettlementRequest(String id) =>'/settlement-requests/$id/confirm';
  static String rejectSettlementRequest(String id) =>'/settlement-requests/$id/reject';

//Settlement History
static String groupMemberBalanceHistory(String groupId, String userId) =>'/groups/$groupId/balance/$userId/history';
}