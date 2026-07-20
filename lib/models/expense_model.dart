class ExpensePerson {
  final String id;
  final String name;
  final String? avatar;
  final int? share; 
  final bool isSettled; 

  ExpensePerson({
    required this.id,
    required this.name,
    this.avatar,
    this.share,
    this.isSettled = false,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory ExpensePerson.fromJson(Map<String, dynamic> json) {
    return ExpensePerson(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
     // name: json['name']?.toString() ?? '',
     name: json['name']?.toString() ?? json['user_name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      share: json['share'] is int
          ? json['share'] as int
          : json['amount_owed'] is int
              ? json['amount_owed'] as int
              : int.tryParse(
                  (json['share'] ?? json['amount_owed'])?.toString() ?? ''),
      isSettled: json['is_settled'] == true || json['settled'] == true,
    );
  }
}

class ExpenseModel {
  final String id;
  final String groupId;
  final String description;
  final int amount;
  final DateTime expenseDate;
  final DateTime? createdAt;
  final String splitType; 
  final bool? includePayer; 
  final ExpensePerson? paidBy;
  final List<ExpensePerson> participants;

  ExpenseModel({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.createdAt,
    this.splitType = 'equally',
    this.includePayer,
    this.paidBy,
    this.participants = const [],
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    ExpensePerson? paidBy;
final payerObj = json['payer'] ?? json['user'];
if (payerObj is Map<String, dynamic>) {
  paidBy = ExpensePerson.fromJson(payerObj);
} else if (json['payer_name'] != null) {
  paidBy = ExpensePerson(
    id: json['paid_by']?.toString() ?? '',
    name: json['payer_name'].toString(),
  );
}

    List<ExpensePerson> participants = [];
    final participantsJson =
        json['participants'] ?? json['splits'] ?? json['members'];
    if (participantsJson is List) {
      participants = participantsJson
          .whereType<Map<String, dynamic>>()
          .map((p) => ExpensePerson.fromJson(
              p['user'] is Map<String, dynamic>
                  ? p['user'] as Map<String, dynamic>
                  : p))
          .toList();
    }

    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: json['amount'] is int
          ? json['amount'] as int
          : int.tryParse(json['amount']?.toString() ?? '') ?? 0,
      expenseDate:
          DateTime.tryParse(json['expense_date']?.toString() ?? '') ??
              DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      splitType: json['split_type']?.toString() ?? 'equally',
      includePayer: json['include_payer'] is bool
          ? json['include_payer'] as bool
          : null,
      paidBy: paidBy,
      participants: participants,
    );
  }
}