/// Person object ("user" or "payer") ဖော်ပြထားတဲ့ nested object တွေအတွက်
/// GET /groups/expenses/splits response ထဲက "user" / "group_expense.payer"
class ExpenseSplitPerson {
  final String id;
  final String name;
  final String? avatar;
  final String? email;

  ExpenseSplitPerson({
    required this.id,
    required this.name,
    this.avatar,
    this.email,
  });

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory ExpenseSplitPerson.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitPerson(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

/// GET /groups/expenses/splits ရဲ့ item တစ်ခုစီထဲက "group_expense" object
/// (group name + description + ငွေရှင်ကြိုတင်ကျခံသူ/payer)
///
/// CONFIRMED: backend response ထဲမှာ "description" field ကို
/// group_expense object ထဲက group_name အနားမှာ တကယ်ရှိပါတယ်
/// (e.g. "description": "testing 1") - Settle Debt card ပေါ်က
/// "Description : ..." line ကို ဒီနေရာကနေ တိုက်ရိုက်ပြပါတယ်။
class ExpenseSplitGroupExpense {
  final String id;
  final String groupId;
  final String groupName;
  final String? description;
  final ExpenseSplitPerson? payer; // "Owed to" ပြထားတဲ့ ငွေရှင်

  ExpenseSplitGroupExpense({
    required this.id,
    required this.groupId,
    required this.groupName,
    this.description,
    this.payer,
  });

  factory ExpenseSplitGroupExpense.fromJson(Map<String, dynamic> json) {
    final payerJson = json['payer'];
    return ExpenseSplitGroupExpense(
      id: json['id']?.toString() ?? '',
      groupId: json['group_id']?.toString() ?? '',
      groupName: json['group_name']?.toString() ?? '',
      description: json['description']?.toString(),
      payer: payerJson is Map<String, dynamic>
          ? ExpenseSplitPerson.fromJson(payerJson)
          : null,
    );
  }
}

/// GET /groups/expenses/splits ရဲ့ list item တစ်ခုစီ
/// (Profile > Settle Debt ကနေ ဝင်ရင် login ဝင်ထားသူ ကျန်နေသေးတဲ့
/// debt (split) အားလုံး, group အသီးသီးမှ)
class ExpenseSplitModel {
  final String id; // POST claim-payment ခေါ်တဲ့အခါသုံးမယ့် split id
  final String groupExpenseId;
  final String userId; // debt ကျခံနေရသူ (login ဝင်ထားသူကိုယ်တိုင်)
  final int amountOwed;
  final int amountPaid;
  final int remainingAmount;
  final bool isSettled;
  final DateTime? settledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ExpenseSplitPerson? user; // debtor (ကိုယ်တိုင်)
  final ExpenseSplitGroupExpense? groupExpense;

  /// claim-payment ခေါ်ပြီးစီးမှုမှလွဲလို့ backend ကနေ confirm ပြန်မရသေးတဲ့
  /// (ငွေရှင် ဘက်က approve ရန်ကျန်နေသေးတဲ့) claim ရှိမရှိ - UI ထဲမှာ
  /// "Pending" badge ပြဖို့သုံးမယ့် local/derived flag။ backend response
  /// ထဲမှာ ဒီလို flag တကယ်ရှိရင် json['has_pending_claim'] စသည်ဖြင့်
  /// ချိန်ပေးနိုင်ပါတယ်။
  final bool hasPendingClaim;

  ExpenseSplitModel({
    required this.id,
    required this.groupExpenseId,
    required this.userId,
    required this.amountOwed,
    required this.amountPaid,
    required this.remainingAmount,
    required this.isSettled,
    this.settledAt,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.groupExpense,
    this.hasPendingClaim = false,
  });

  String get description => groupExpense?.description ?? '';
  String get groupTitle => groupExpense?.groupName ?? '';
  String get owedToName => groupExpense?.payer?.name ?? '';

  double get progress =>
      amountOwed == 0 ? 0 : (amountPaid / amountOwed).clamp(0, 1).toDouble();
  int get progressPercent => (progress * 100).round();

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
  final userJson = json['user'];
  final groupExpenseJson = json['group_expense'];

  // backend ရဲ့ response နောက်ဆုံးနားက nested "settlement_requests"
  // object ({ "status": "pending" }) ကို ကြည့်ပြီး "Settle Now" ခလုတ်
  // ကို "Pending" ပြောင်းပြဖို့ flag တွက်ပေးမယ်
  final settlementRequestsJson = json['settlement_requests'];
  final settlementStatus = settlementRequestsJson is Map<String, dynamic>
      ? settlementRequestsJson['status']?.toString().toLowerCase()
      : null;

  return ExpenseSplitModel(
    id: json['id']?.toString() ?? '',
    groupExpenseId: json['group_expense_id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    amountOwed: _toInt(json['amount_owed']),
    amountPaid: _toInt(json['amount_paid']),
    remainingAmount: _toInt(json['remaining_amount']),
    isSettled: json['is_settled'] == true,
    settledAt: json['settled_at'] != null
        ? DateTime.tryParse(json['settled_at'].toString())
        : null,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString())
        : null,
    updatedAt: json['updated_at'] != null
        ? DateTime.tryParse(json['updated_at'].toString())
        : null,
    user: userJson is Map<String, dynamic>
        ? ExpenseSplitPerson.fromJson(userJson)
        : null,
    groupExpense: groupExpenseJson is Map<String, dynamic>
        ? ExpenseSplitGroupExpense.fromJson(groupExpenseJson)
        : null,
    // has_pending_claim (ရှိရင်) OR settlement_requests.status == "pending"
    // ၂ခုထဲက တစ်ခုခု true ဖြစ်ရင် pending သတ်မှတ်မယ်
    hasPendingClaim: json['has_pending_claim'] == true ||
        settlementStatus == 'pending',
  );
}

  // factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
  //   final userJson = json['user'];
  //   final groupExpenseJson = json['group_expense'];
  //   return ExpenseSplitModel(
  //     id: json['id']?.toString() ?? '',
  //     groupExpenseId: json['group_expense_id']?.toString() ?? '',
  //     userId: json['user_id']?.toString() ?? '',
  //     amountOwed: _toInt(json['amount_owed']),
  //     amountPaid: _toInt(json['amount_paid']),
  //     remainingAmount: _toInt(json['remaining_amount']),
  //     isSettled: json['is_settled'] == true,
  //     settledAt: json['settled_at'] != null
  //         ? DateTime.tryParse(json['settled_at'].toString())
  //         : null,
  //     createdAt: json['created_at'] != null
  //         ? DateTime.tryParse(json['created_at'].toString())
  //         : null,
  //     updatedAt: json['updated_at'] != null
  //         ? DateTime.tryParse(json['updated_at'].toString())
  //         : null,
  //     user: userJson is Map<String, dynamic>
  //         ? ExpenseSplitPerson.fromJson(userJson)
  //         : null,
  //     groupExpense: groupExpenseJson is Map<String, dynamic>
  //         ? ExpenseSplitGroupExpense.fromJson(groupExpenseJson)
  //         : null,
  //     hasPendingClaim: json['has_pending_claim'] == true,
  //   );
  // }

  ExpenseSplitModel copyWith({
    int? amountPaid,
    int? remainingAmount,
    bool? isSettled,
    DateTime? settledAt,
    bool? hasPendingClaim,
  }) {
    return ExpenseSplitModel(
      id: id,
      groupExpenseId: groupExpenseId,
      userId: userId,
      amountOwed: amountOwed,
      amountPaid: amountPaid ?? this.amountPaid,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user,
      groupExpense: groupExpense,
      hasPendingClaim: hasPendingClaim ?? this.hasPendingClaim,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}